import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workspace_member.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class Invitation {
  final String id;
  final String email;
  final String invitedByUserId;
  final String invitedByName;
  final String workspaceId;
  final String? noteId;
  final MemberRole role;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  const Invitation({
    required this.id,
    required this.email,
    required this.invitedByUserId,
    required this.invitedByName,
    required this.workspaceId,
    this.noteId,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'invited_by_user_id': invitedByUserId,
      'invited_by_name': invitedByName,
      'workspace_id': workspaceId,
      'note_id': noteId,
      'role': role.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      email: json['email'] as String,
      invitedByUserId: json['invited_by_user_id'] as String,
      invitedByName: json['invited_by_name'] as String,
      workspaceId: json['workspace_id'] as String,
      noteId: json['note_id'] as String?,
      role: MemberRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MemberRole.member,
      ),
      status: InvitationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }
}

class InvitationService {
  final SupabaseClient _client = Supabase.instance.client;

  // Send invitation to collaborate on a note or workspace
  Future<Invitation> sendInvitation({
    required String email,
    required String workspaceId,
    String? noteId,
    required MemberRole role,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Check if user is already a member
      final existingMember = await _client
          .from('workspace_members')
          .select()
          .eq('workspace_id', workspaceId)
          .eq('email', email)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('El usuario ya es miembro del workspace');
      }

      // Check if there's already a pending invitation
      final existingInvitation = await _client
          .from('invitations')
          .select()
          .eq('email', email)
          .eq('workspace_id', workspaceId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingInvitation != null) {
        throw Exception('Ya existe una invitación pendiente para este usuario');
      }

      // Get current user profile
      final profile = await _client
          .from('profiles')
          .select('name')
          .eq('id', currentUser.id)
          .single();

      final invitation = Invitation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        invitedByUserId: currentUser.id,
        invitedByName: profile['name'] ?? currentUser.email ?? 'Usuario',
        workspaceId: workspaceId,
        noteId: noteId,
        role: role,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      // Insert invitation into database
      await _client.from('invitations').insert(invitation.toJson());

      // Send email notification (if email service is configured)
      await _sendInvitationEmail(invitation);

      if (kDebugMode) {
        print('Invitation sent to $email for ${noteId != null ? 'note' : 'workspace'}');
      }

      return invitation;

    } catch (e) {
      if (kDebugMode) {
        print('Error sending invitation: $e');
      }
      rethrow;
    }
  }

  // Get pending invitations for current user
  Future<List<Invitation>> getPendingInvitations() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser?.email == null) {
        return [];
      }

      final response = await _client
          .from('invitations')
          .select()
          .eq('email', currentUser!.email!)
          .eq('status', 'pending')
          .gt('expires_at', DateTime.now().toIso8601String());

      return response.map<Invitation>((json) => Invitation.fromJson(json)).toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending invitations: $e');
      }
      return [];
    }
  }

  // Get invitations sent by current user
  Future<List<Invitation>> getSentInvitations(String workspaceId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final response = await _client
          .from('invitations')
          .select()
          .eq('invited_by_user_id', currentUser.id)
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);

      return response.map<Invitation>((json) => Invitation.fromJson(json)).toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error getting sent invitations: $e');
      }
      return [];
    }
  }

  // Accept invitation
  Future<WorkspaceMember> acceptInvitation(String invitationId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Get invitation
      final invitationData = await _client
          .from('invitations')
          .select()
          .eq('id', invitationId)
          .eq('email', currentUser.email!)
          .eq('status', 'pending')
          .single();

      final invitation = Invitation.fromJson(invitationData);

      // Check if not expired
      if (DateTime.now().isAfter(invitation.expiresAt)) {
        throw Exception('La invitación ha expirado');
      }

      // Get or create user profile
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      String userName = profileData?['name'] ??
                       currentUser.userMetadata?['name'] ??
                       currentUser.email?.split('@').first ??
                       'Usuario';

      // Create workspace member
      final member = WorkspaceMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.id,
        workspaceId: invitation.workspaceId,
        name: userName,
        email: currentUser.email!,
        role: invitation.role,
        joinedAt: DateTime.now(),
        isActive: true,
      );

      // Insert member and update invitation in transaction
      await _client.rpc('accept_invitation', params: {
        'invitation_id': invitationId,
        'member_data': member.toJson(),
      });

      if (kDebugMode) {
        print('Invitation accepted for workspace ${invitation.workspaceId}');
      }

      return member;

    } catch (e) {
      if (kDebugMode) {
        print('Error accepting invitation: $e');
      }
      rethrow;
    }
  }

  // Decline invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _client
          .from('invitations')
          .update({
            'status': 'declined',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId)
          .eq('email', currentUser.email!);

      if (kDebugMode) {
        print('Invitation declined: $invitationId');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error declining invitation: $e');
      }
      rethrow;
    }
  }

  // Cancel invitation (for invitation sender)
  Future<void> cancelInvitation(String invitationId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      await _client
          .from('invitations')
          .delete()
          .eq('id', invitationId)
          .eq('invited_by_user_id', currentUser.id);

      if (kDebugMode) {
        print('Invitation cancelled: $invitationId');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling invitation: $e');
      }
      rethrow;
    }
  }

  // Remove user from workspace
  Future<void> removeMember(String workspaceId, String userId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Check if current user has permission to remove members
      final currentMember = await _client
          .from('workspace_members')
          .select('role')
          .eq('workspace_id', workspaceId)
          .eq('user_id', currentUser.id)
          .single();

      final currentRole = MemberRole.values.firstWhere(
        (r) => r.name == currentMember['role'],
        orElse: () => MemberRole.member,
      );

      if (!currentRole.canDelete) {
        throw Exception('No tienes permisos para remover miembros');
      }

      // Remove member
      await _client
          .from('workspace_members')
          .delete()
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Member removed from workspace: $userId');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error removing member: $e');
      }
      rethrow;
    }
  }

  // Update member role
  Future<void> updateMemberRole(String workspaceId, String userId, MemberRole newRole) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Check if current user has permission to modify roles
      final currentMember = await _client
          .from('workspace_members')
          .select('role')
          .eq('workspace_id', workspaceId)
          .eq('user_id', currentUser.id)
          .single();

      final currentRole = MemberRole.values.firstWhere(
        (r) => r.name == currentMember['role'],
        orElse: () => MemberRole.member,
      );

      if (!currentRole.canInvite) {
        throw Exception('No tienes permisos para modificar roles');
      }

      // Update role
      await _client
          .from('workspace_members')
          .update({'role': newRole.name})
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Member role updated: $userId -> ${newRole.name}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error updating member role: $e');
      }
      rethrow;
    }
  }

  // Get workspace members
  Future<List<WorkspaceMember>> getWorkspaceMembers(String workspaceId) async {
    try {
      final response = await _client
          .from('workspace_members')
          .select()
          .eq('workspace_id', workspaceId)
          .eq('is_active', true)
          .order('joined_at', ascending: false);

      return response.map<WorkspaceMember>((json) => WorkspaceMember.fromJson(json)).toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error getting workspace members: $e');
      }
      return [];
    }
  }

  // Private method to send invitation email
  Future<void> _sendInvitationEmail(Invitation invitation) async {
    try {
      // This would integrate with your email service (SendGrid, etc.)
      // For now, we'll just simulate sending an email

      final emailContent = {
        'to': invitation.email,
        'subject': 'Invitación a colaborar en Notably',
        'body': '''
Hola,

${invitation.invitedByName} te ha invitado a colaborar en Notably.

${invitation.noteId != null ? 'Documento' : 'Workspace'}: ${invitation.workspaceId}
Rol: ${invitation.role.displayName}

Para aceptar la invitación, ingresa a la aplicación con este email.

La invitación expira el ${invitation.expiresAt.day}/${invitation.expiresAt.month}/${invitation.expiresAt.year}.

¡Gracias!
El equipo de Notably
        ''',
      };

      // TODO: Implement actual email sending
      if (kDebugMode) {
        print('Email would be sent: ${jsonEncode(emailContent)}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error sending invitation email: $e');
      }
      // Don't throw error for email sending failure
    }
  }
}