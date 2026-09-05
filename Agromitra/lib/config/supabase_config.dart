class SupabaseConfig {
  /// Supabase Project URL
  static const String supabaseUrl = "https://iquaslkxihnxdfzamtps.supabase.co";

  /// Supabase Anon / Publishable Key
  static const String supabaseAnonKey = "sb_publishable_9qqvfJuraQnSnqspglZ0CQ_uGmfNdBT";

  /// Indicates if Supabase has been configured with real credentials
  static bool get isConfigured =>
      supabaseUrl != "https://your-project.supabase.co" &&
      supabaseAnonKey != "your-anon-key-here" &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}
