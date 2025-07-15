import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> signUp(String email, String password, String role, String displayName) async {
    final response = await supabase.auth.signUp(email: email, password: password);
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'role': role,
        'display_name': displayName,
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final data = await supabase.from('users').select().eq('id', user.id).single();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }

  Future<List<Map<String, dynamic>>> getVisitors() async {
    final data = await supabase.from('visitors').select().order('timestamp', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addVisitor({required String name, required String reason, required DateTime timestamp, required String photoUrl}) async {
    await supabase.from('visitors').insert({
      'name': name,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'photo_url': photoUrl,
    });
  }

  // Optionally, add update/delete methods for visitors if needed
}
