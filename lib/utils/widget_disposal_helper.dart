import 'dart:async';
import 'package:flutter/material.dart';

/// Helper class to manage safe disposal of widgets and their resources
class WidgetDisposalHelper {
  /// Safely dispose a list of controllers
  static void safeDisposeControllers<T>(List<T> controllers, {
    required void Function(T) disposeMethod,
  }) {
    try {
      final controllersToDispose = List<T>.from(controllers);
      controllers.clear();

      for (final controller in controllersToDispose) {
        try {
          disposeMethod(controller);
        } catch (e) {
          print('Error disposing controller: $e');
        }
      }
    } catch (e) {
      print('Error in batch controller disposal: $e');
    }
  }

  /// Safely dispose animation controllers
  static void safeDisposeAnimationControllers(List<AnimationController> controllers) {
    safeDisposeControllers<AnimationController>(
      controllers,
      disposeMethod: (controller) {
        if (!controller.isCompleted && !controller.isDismissed) {
          controller.stop();
        }
        controller.dispose();
      },
    );
  }

  /// Safely dispose text controllers
  static void safeDisposeTextControllers(List<TextEditingController> controllers) {
    safeDisposeControllers<TextEditingController>(
      controllers,
      disposeMethod: (controller) => controller.dispose(),
    );
  }

  /// Safely dispose focus nodes
  static void safeDisposeFocusNodes(List<FocusNode> nodes) {
    safeDisposeControllers<FocusNode>(
      nodes,
      disposeMethod: (node) => node.dispose(),
    );
  }

  /// Safely cancel a list of subscriptions
  static Future<void> safeCancelSubscriptions(List<StreamSubscription?> subscriptions) async {
    try {
      final subsToCancel = List<StreamSubscription?>.from(subscriptions);
      subscriptions.clear();

      for (final subscription in subsToCancel) {
        try {
          await subscription?.cancel();
        } catch (e) {
          print('Error cancelling subscription: $e');
        }
      }
    } catch (e) {
      print('Error in batch subscription cancellation: $e');
    }
  }

  /// Safely cancel timers
  static void safeCancelTimers(List<Timer?> timers) {
    try {
      final timersToCancel = List<Timer?>.from(timers);
      timers.clear();

      for (final timer in timersToCancel) {
        try {
          timer?.cancel();
        } catch (e) {
          print('Error cancelling timer: $e');
        }
      }
    } catch (e) {
      print('Error in batch timer cancellation: $e');
    }
  }

  /// Safely close stream controllers
  static Future<void> safeCloseStreamControllers<T>(List<StreamController<T>> controllers) async {
    try {
      final controllersToClose = List<StreamController<T>>.from(controllers);
      controllers.clear();

      for (final controller in controllersToClose) {
        try {
          if (!controller.isClosed) {
            await controller.close();
          }
        } catch (e) {
          print('Error closing stream controller: $e');
        }
      }
    } catch (e) {
      print('Error in batch stream controller closure: $e');
    }
  }

  /// Remove listeners safely before disposing
  static void safeRemoveListeners<T>({
    required List<T> controllers,
    required void Function(T) removeListener,
  }) {
    try {
      for (final controller in controllers) {
        try {
          removeListener(controller);
        } catch (e) {
          print('Error removing listener: $e');
        }
      }
    } catch (e) {
      print('Error in batch listener removal: $e');
    }
  }
}

/// Mixin to help with safe widget disposal
mixin SafeDisposalMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<AnimationController> _animationControllers = [];
  final List<TextEditingController> _textControllers = [];
  final List<FocusNode> _focusNodes = [];

  /// Register a subscription for automatic disposal
  void registerSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Register a timer for automatic disposal
  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Register an animation controller for automatic disposal
  void registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  /// Register a text controller for automatic disposal
  void registerTextController(TextEditingController controller) {
    _textControllers.add(controller);
  }

  /// Register a focus node for automatic disposal
  void registerFocusNode(FocusNode node) {
    _focusNodes.add(node);
  }

  /// Dispose all registered resources
  Future<void> disposeResources() async {
    await WidgetDisposalHelper.safeCancelSubscriptions(_subscriptions);
    WidgetDisposalHelper.safeCancelTimers(_timers);
    WidgetDisposalHelper.safeDisposeAnimationControllers(_animationControllers);
    WidgetDisposalHelper.safeDisposeTextControllers(_textControllers);
    WidgetDisposalHelper.safeDisposeFocusNodes(_focusNodes);
  }

  @override
  void dispose() {
    disposeResources();
    super.dispose();
  }
}