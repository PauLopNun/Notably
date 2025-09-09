import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollaborationService {
  final _client = Supabase.instance.client;

  Future<void> inviteCollaborator(String noteId, String email) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // First, check if the user exists
      final existingUser = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingUser == null) {
        // Send invitation email (placeholder for email service integration)
        await _sendInvitationEmail(email, noteId, user.email ?? 'Unknown');
        throw Exception('User not found. Invitation email sent to $email');
      }

      // Add collaborator to the note
      await _client.from('note_collaborators').insert({
        'note_id': noteId,
        'user_id': existingUser['id'],
        'invited_by': user.id,
        'permission': 'edit', // Default permission
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send notification to the collaborator
      await _sendCollaborationNotification(
        existingUser['id'],
        noteId,
        user.email ?? 'Unknown',
      );

      debugPrint('Collaboration invite sent successfully');
    } catch (e) {
      debugPrint('Error inviting collaborator: $e');
      rethrow;
    }
  }

  Future<void> acceptCollaborationInvite(String noteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('note_collaborators')
          .update({'status': 'accepted'})
          .eq('note_id', noteId)
          .eq('user_id', user.id);

      debugPrint('Collaboration invite accepted');
    } catch (e) {
      debugPrint('Error accepting collaboration invite: $e');
      rethrow;
    }
  }

  Future<void> removeCollaborator(String noteId, String userId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if the current user is the owner or has permission to remove collaborators
      final noteOwner = await _client
          .from('notes')
          .select('user_id')
          .eq('id', noteId)
          .single();

      if (noteOwner['user_id'] != user.id) {
        throw Exception('Only the note owner can remove collaborators');
      }

      await _client
          .from('note_collaborators')
          .delete()
          .eq('note_id', noteId)
          .eq('user_id', userId);

      debugPrint('Collaborator removed successfully');
    } catch (e) {
      debugPrint('Error removing collaborator: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCollaborators(String noteId) async {
    try {
      final collaborators = await _client
          .from('note_collaborators')
          .select('''
            *,
            profiles:user_id (
              id,
              email,
              full_name,
              avatar_url
            )
          ''')
          .eq('note_id', noteId)
          .eq('status', 'accepted');

      return collaborators;
    } catch (e) {
      debugPrint('Error fetching collaborators: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final invitations = await _client
          .from('note_collaborators')
          .select('''
            *,
            notes:note_id (
              id,
              title,
              created_at
            ),
            inviter:invited_by (
              email,
              full_name
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return invitations;
    } catch (e) {
      debugPrint('Error fetching pending invitations: $e');
      return [];
    }
  }

  Future<bool> canEditNote(String noteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Check if user is the owner
      final note = await _client
          .from('notes')
          .select('user_id')
          .eq('id', noteId)
          .maybeSingle();

      if (note != null && note['user_id'] == user.id) {
        return true;
      }

      // Check if user is a collaborator with edit permissions
      final collaboration = await _client
          .from('note_collaborators')
          .select('permission')
          .eq('note_id', noteId)
          .eq('user_id', user.id)
          .eq('status', 'accepted')
          .maybeSingle();

      return collaboration != null && 
             (collaboration['permission'] == 'edit' || 
              collaboration['permission'] == 'admin');
    } catch (e) {
      debugPrint('Error checking edit permissions: $e');
      return false;
    }
  }

  Future<void> updateCollaboratorPermission(
    String noteId,
    String userId,
    String permission,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate permission
      if (!['view', 'edit', 'admin'].contains(permission)) {
        throw Exception('Invalid permission level');
      }

      await _client
          .from('note_collaborators')
          .update({'permission': permission})
          .eq('note_id', noteId)
          .eq('user_id', userId);

      debugPrint('Collaborator permission updated successfully');
    } catch (e) {
      debugPrint('Error updating collaborator permission: $e');
      rethrow;
    }
  }

  // Real-time collaboration methods - simplified for now
  Stream<List<Map<String, dynamic>>> watchCollaborators(String noteId) {
    // This would need to be implemented with proper real-time subscriptions
    return Stream.empty();
  }

  Stream<Map<String, dynamic>> watchNoteChanges(String noteId) {
    // This would need to be implemented with proper real-time subscriptions
    return Stream.empty();
  }

  // Private helper methods
  Future<void> _sendInvitationEmail(
    String email,
    String noteId,
    String inviterEmail,
  ) async {
    // Placeholder for email service integration
    // In a real app, you'd integrate with a service like SendGrid, AWS SES, etc.
    debugPrint('Sending invitation email to $email from $inviterEmail for note $noteId');
  }

  Future<void> _sendCollaborationNotification(
    String userId,
    String noteId,
    String inviterEmail,
  ) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'collaboration_invite',
        'title': 'New Collaboration Invitation',
        'message': '$inviterEmail invited you to collaborate on a note',
        'data': {
          'note_id': noteId,
          'inviter_email': inviterEmail,
        },
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}