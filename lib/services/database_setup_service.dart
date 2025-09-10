import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DatabaseSetupService {
  static final _client = Supabase.instance.client;

  /// Auto-setup database schema on app startup
  static Future<void> ensureDatabaseSchema() async {
    try {
      debugPrint('🔍 Checking database schema...');
      
      // Check if notes table exists by trying to query it
      final notesTableExists = await _checkTableExists('notes');
      
      if (!notesTableExists) {
        debugPrint('❌ Notes table not found!');
        debugPrint('📋 Please run the SQL setup manually in Supabase:');
        debugPrint('   1. Open: https://nxqlxybhwqocfcubngwa.supabase.co');
        debugPrint('   2. Go to SQL Editor');
        debugPrint('   3. Copy and run the SQL from SETUP.md file');
        debugPrint('   4. Restart the app');
        
        // Show user-friendly message but don't block app startup
        return;
      } else {
        debugPrint('✅ Notes table exists - database ready!');
      }
      
      debugPrint('🚀 Database setup completed!');
    } catch (e) {
      debugPrint('❌ Database setup error: $e');
      debugPrint('💡 If this is first run, please set up database manually (see SETUP.md)');
    }
  }

  /// Check if a table exists in the database
  static Future<bool> _checkTableExists(String tableName) async {
    try {
      await _client
          .from(tableName)
          .select('id')
          .limit(1);
      
      return true; // If no exception, table exists
    } catch (e) {
      // If exception mentions table/relation doesn't exist, return false
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('relation') && errorStr.contains('does not exist')) {
        return false;
      }
      if (errorStr.contains('table') && errorStr.contains('does not exist')) {
        return false;
      }
      
      // For other errors, assume table exists but there's another issue
      debugPrint('Table check error (assuming exists): $e');
      return true;
    }
  }
}