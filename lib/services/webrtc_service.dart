import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/collaborative_operation.dart';

// WebRTC Configuration
const Map<String, dynamic> _configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ],
  'sdpSemantics': 'unified-plan',
};

const Map<String, dynamic> _offerSdpConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

const Map<String, dynamic> _dataChannelConstraints = {
  'ordered': true,
};

// WebRTC Service Provider
final webRtcServiceProvider = Provider<WebRtcService>((ref) => WebRtcService());

// Connection States
enum WebRtcConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
}

// Peer Information
class WebRtcPeer {
  final String id;
  final String userId;
  final String userName;
  final RTCPeerConnection connection;
  final RTCDataChannel? dataChannel;
  final DateTime connectedAt;

  WebRtcPeer({
    required this.id,
    required this.userId,
    required this.userName,
    required this.connection,
    this.dataChannel,
    required this.connectedAt,
  });
}

class WebRtcService {
  // Private fields
  WebSocketChannel? _signalingChannel;
  final Map<String, WebRtcPeer> _peers = {};
  final StreamController<WebRtcConnectionState> _connectionStateController = 
      StreamController<WebRtcConnectionState>.broadcast();
  final StreamController<CollaborativeOperation> _operationsController = 
      StreamController<CollaborativeOperation>.broadcast();
  final StreamController<Map<String, dynamic>> _presenceController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  String? _currentDocumentId;
  String? _currentUserId;
  String? _currentUserName;
  WebRtcConnectionState _connectionState = WebRtcConnectionState.disconnected;

  // Public getters
  Stream<WebRtcConnectionState> get connectionState => _connectionStateController.stream;
  Stream<CollaborativeOperation> get operations => _operationsController.stream;
  Stream<Map<String, dynamic>> get presenceUpdates => _presenceController.stream;
  List<WebRtcPeer> get connectedPeers => _peers.values.toList();
  bool get isConnected => _connectionState == WebRtcConnectionState.connected;

  // Initialize WebRTC service
  Future<void> initialize() async {
    try {
      log('Initializing WebRTC service...');
      _updateConnectionState(WebRtcConnectionState.disconnected);
    } catch (e) {
      log('Failed to initialize WebRTC service: $e');
      _updateConnectionState(WebRtcConnectionState.failed);
    }
  }

  // Connect to document collaboration session
  Future<void> connectToDocument({
    required String documentId,
    required String userId,
    required String userName,
    String signalingServer = 'wss://your-signaling-server.com',
  }) async {
    try {
      _updateConnectionState(WebRtcConnectionState.connecting);
      
      _currentDocumentId = documentId;
      _currentUserId = userId;
      _currentUserName = userName;

      // Connect to signaling server
      await _connectToSignalingServer(signalingServer);
      
      // Join document room
      _sendSignalingMessage({
        'type': 'join',
        'documentId': documentId,
        'userId': userId,
        'userName': userName,
      });

      log('Connected to document: $documentId');
      _updateConnectionState(WebRtcConnectionState.connected);
      
    } catch (e) {
      log('Failed to connect to document: $e');
      _updateConnectionState(WebRtcConnectionState.failed);
      rethrow;
    }
  }

  // Disconnect from collaboration session
  Future<void> disconnect() async {
    try {
      log('Disconnecting from WebRTC session...');
      
      // Close all peer connections
      for (final peer in _peers.values) {
        await peer.connection.close();
        peer.dataChannel?.close();
      }
      _peers.clear();

      // Close signaling connection
      await _signalingChannel?.sink.close();
      _signalingChannel = null;

      _currentDocumentId = null;
      _currentUserId = null;
      _currentUserName = null;
      
      _updateConnectionState(WebRtcConnectionState.disconnected);
      log('Disconnected from WebRTC session');
      
    } catch (e) {
      log('Error during disconnect: $e');
    }
  }

  // Send collaborative operation to all peers
  Future<void> sendOperation(CollaborativeOperation operation) async {
    if (!isConnected || _currentDocumentId == null) return;

    final message = {
      'type': 'operation',
      'operation': operation.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonMessage = jsonEncode(message);
    
    // Send to all connected peers via data channels
    for (final peer in _peers.values) {
      try {
        if (peer.dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
          peer.dataChannel!.send(RTCDataChannelMessage(jsonMessage));
        }
      } catch (e) {
        log('Failed to send operation to peer ${peer.id}: $e');
      }
    }
  }

  // Send cursor/selection position
  Future<void> sendCursorPosition({
    required int position,
    required int selectionLength,
  }) async {
    if (!isConnected || _currentDocumentId == null) return;

    final message = {
      'type': 'cursor',
      'userId': _currentUserId,
      'userName': _currentUserName,
      'position': position,
      'selectionLength': selectionLength,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonMessage = jsonEncode(message);
    
    // Send cursor position to all peers
    for (final peer in _peers.values) {
      try {
        if (peer.dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
          peer.dataChannel!.send(RTCDataChannelMessage(jsonMessage));
        }
      } catch (e) {
        log('Failed to send cursor position to peer ${peer.id}: $e');
      }
    }
  }

  // Private methods

  Future<void> _connectToSignalingServer(String serverUrl) async {
    try {
      _signalingChannel = WebSocketChannel.connect(Uri.parse(serverUrl));
      
      _signalingChannel!.stream.listen(
        _handleSignalingMessage,
        onError: (error) {
          log('Signaling channel error: $error');
          _updateConnectionState(WebRtcConnectionState.failed);
        },
        onDone: () {
          log('Signaling channel closed');
          if (_connectionState == WebRtcConnectionState.connected) {
            _updateConnectionState(WebRtcConnectionState.disconnected);
          }
        },
      );
      
      log('Connected to signaling server: $serverUrl');
    } catch (e) {
      log('Failed to connect to signaling server: $e');
      throw Exception('Signaling server connection failed: $e');
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_signalingChannel != null) {
      final jsonMessage = jsonEncode(message);
      _signalingChannel!.sink.add(jsonMessage);
    }
  }

  void _handleSignalingMessage(dynamic data) async {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String;

      switch (type) {
        case 'peer-joined':
          await _handlePeerJoined(message);
          break;
        case 'offer':
          await _handleOffer(message);
          break;
        case 'answer':
          await _handleAnswer(message);
          break;
        case 'ice-candidate':
          await _handleIceCandidate(message);
          break;
        case 'peer-left':
          _handlePeerLeft(message);
          break;
        default:
          log('Unknown signaling message type: $type');
      }
    } catch (e) {
      log('Error handling signaling message: $e');
    }
  }

  Future<void> _handlePeerJoined(Map<String, dynamic> message) async {
    final peerId = message['peerId'] as String;
    final userId = message['userId'] as String;
    final userName = message['userName'] as String;

    log('Peer joined: $peerId ($userName)');
    
    // Create offer to new peer
    await _createPeerConnection(peerId, userId, userName, isOfferer: true);
  }

  Future<void> _handleOffer(Map<String, dynamic> message) async {
    final peerId = message['from'] as String;
    final userId = message['userId'] as String;
    final userName = message['userName'] as String;
    final offerSdp = message['sdp'] as String;
    final offerType = message['sdpType'] as String;

    log('Received offer from peer: $peerId');

    // Create peer connection and set remote description
    final peer = await _createPeerConnection(peerId, userId, userName, isOfferer: false);
    
    final offer = RTCSessionDescription(offerSdp, offerType);
    await peer.connection.setRemoteDescription(offer);

    // Create and send answer
    final answer = await peer.connection.createAnswer(_offerSdpConstraints);
    await peer.connection.setLocalDescription(answer);

    _sendSignalingMessage({
      'type': 'answer',
      'to': peerId,
      'sdp': answer.sdp,
      'sdpType': answer.type,
    });
  }

  Future<void> _handleAnswer(Map<String, dynamic> message) async {
    final peerId = message['from'] as String;
    final answerSdp = message['sdp'] as String;
    final answerType = message['sdpType'] as String;

    log('Received answer from peer: $peerId');

    final peer = _peers[peerId];
    if (peer != null) {
      final answer = RTCSessionDescription(answerSdp, answerType);
      await peer.connection.setRemoteDescription(answer);
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> message) async {
    final peerId = message['from'] as String;
    final candidateMap = message['candidate'] as Map<String, dynamic>;

    final peer = _peers[peerId];
    if (peer != null) {
      final candidate = RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      );
      await peer.connection.addCandidate(candidate);
    }
  }

  void _handlePeerLeft(Map<String, dynamic> message) async {
    final peerId = message['peerId'] as String;
    log('Peer left: $peerId');
    
    final peer = _peers.remove(peerId);
    if (peer != null) {
      await peer.connection.close();
      peer.dataChannel?.close();
    }
  }

  Future<WebRtcPeer> _createPeerConnection(
    String peerId,
    String userId,
    String userName, {
    required bool isOfferer,
  }) async {
    final peerConnection = await createPeerConnection(_configuration);
    
    // Set up ice candidate handling
    peerConnection.onIceCandidate = (candidate) {
      _sendSignalingMessage({
        'type': 'ice-candidate',
        'to': peerId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    RTCDataChannel? dataChannel;

    if (isOfferer) {
      // Create data channel
      dataChannel = await peerConnection.createDataChannel(
        'collaboration',
        RTCDataChannelInit()..ordered = _dataChannelConstraints['ordered'],
      );
      _setupDataChannel(dataChannel);

      // Create and send offer
      final offer = await peerConnection.createOffer(_offerSdpConstraints);
      await peerConnection.setLocalDescription(offer);

      _sendSignalingMessage({
        'type': 'offer',
        'to': peerId,
        'sdp': offer.sdp,
        'sdpType': offer.type,
        'userId': _currentUserId,
        'userName': _currentUserName,
      });
    } else {
      // Handle incoming data channel
      peerConnection.onDataChannel = (channel) {
        dataChannel = channel;
        _setupDataChannel(channel);
      };
    }

    // Handle connection state changes
    peerConnection.onConnectionState = (state) {
      log('Peer $peerId connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _peers.remove(peerId);
      }
    };

    final peer = WebRtcPeer(
      id: peerId,
      userId: userId,
      userName: userName,
      connection: peerConnection,
      dataChannel: dataChannel,
      connectedAt: DateTime.now(),
    );

    _peers[peerId] = peer;
    return peer;
  }

  void _setupDataChannel(RTCDataChannel dataChannel) {
    dataChannel.onMessage = (message) {
      try {
        final data = jsonDecode(message.text) as Map<String, dynamic>;
        final type = data['type'] as String;

        switch (type) {
          case 'operation':
            final operationData = data['operation'] as Map<String, dynamic>;
            final operation = CollaborativeOperation.fromJson(operationData);
            _operationsController.add(operation);
            break;
          case 'cursor':
            _presenceController.add(data);
            break;
        }
      } catch (e) {
        log('Error processing data channel message: $e');
      }
    };

    dataChannel.onDataChannelState = (state) {
      log('Data channel state changed: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        log('Data channel opened');
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        log('Data channel closed');
      }
    };
  }

  void _updateConnectionState(WebRtcConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
    }
  }

  // Cleanup
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _operationsController.close();
    _presenceController.close();
  }
}

// WebRTC Provider for Riverpod
final webRtcConnectionStateProvider = StreamProvider<WebRtcConnectionState>((ref) {
  final webRtcService = ref.watch(webRtcServiceProvider);
  return webRtcService.connectionState;
});

final webRtcOperationsProvider = StreamProvider<CollaborativeOperation>((ref) {
  final webRtcService = ref.watch(webRtcServiceProvider);
  return webRtcService.operations;
});

final webRtcPresenceProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final webRtcService = ref.watch(webRtcServiceProvider);
  return webRtcService.presenceUpdates;
});

final webRtcPeersProvider = Provider<List<WebRtcPeer>>((ref) {
  final webRtcService = ref.watch(webRtcServiceProvider);
  return webRtcService.connectedPeers;
});