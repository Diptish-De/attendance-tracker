import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://wlghkbdqhiiayxlqsief.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZ2hrYmRxaGlpYXl4bHFzaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5OTUyNjMsImV4cCI6MjEwMjU3MTI2M30.zHzHdwmxrvuGu4jUtbBdIyX7PlsiKaHwpO2u91oJQCM';

  static SupabaseClient get client => Supabase.instance.client;
}
