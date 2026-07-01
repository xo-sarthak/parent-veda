/// Supabase connection settings for ParentVeda.
///
/// WHERE THESE COME FROM:
///   In your Supabase dashboard go to  Settings -> API  and copy:
///     * "Project URL"        -> paste into [url] below
///     * "anon" / "public" key -> paste into [anonKey] below
///
/// IS IT SAFE TO COMMIT THIS FILE?  Yes. The anon key is *designed* to be
/// public and shipped inside the app; it is protected by Row-Level Security
/// rules we add in the database. NEVER put the database password or the
/// `service_role` key in here -- those are real secrets and must never ship
/// inside the app.
class SupabaseConfig {
  // Private constructor: this class only holds constants, it is never created.
  SupabaseConfig._();

  /// Your project's URL, e.g. https://abcdefgh.supabase.co
  static const String url = 'https://csrabzuhxbschkeyohha.supabase.co';

  /// Your project's anon / public key (a long string that starts with "eyJ...").
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzcmFienVoeGJzY2hrZXlvaGhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI2NTU3MjQsImV4cCI6MjA5ODIzMTcyNH0.MErbbPMfVrXl8G8mdyjiSKnQS_n0JMfQXb3sN895VK0';
}
