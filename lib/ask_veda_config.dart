// =============================================================================
//  AskVedaConfig — where the app finds the AskVeda RAG backend.
// -----------------------------------------------------------------------------
//  Mirrors the SupabaseConfig style (a single static-const class). The AskVeda
//  service is a separate FastAPI backend (its own repo). During development it
//  runs on your machine; in production it becomes a deployed HTTPS URL.
// =============================================================================

class AskVedaConfig {
  AskVedaConfig._();

  /// Base URL of the AskVeda backend. Pick the value that matches HOW you run
  /// the app in dev (the server listens on your PC's port 8000):
  ///   • Android emulator            → http://10.0.2.2:8000   (10.0.2.2 = the host PC's localhost)
  ///   • iOS simulator / desktop     → http://127.0.0.1:8000
  ///   • Physical phone on same Wi-Fi → `http://YOUR-PC-LAN-IP:8000`  (e.g. http://192.168.1.5:8000)
  /// In production (Phase 9) this becomes the deployed https URL.
  /// CURRENT: localhost, used with a USB port-forward — the simplest dev setup.
  /// Run once per USB reconnect:  adb reverse tcp:8000 tcp:8000
  /// That tunnels the phone's localhost:8000 to this PC over the cable, so no
  /// Wi-Fi, no LAN IP and no firewall rules are involved.
  /// (Wi-Fi alternative, if you ever want it: this PC's IP, e.g. http://192.168.1.6:8000)
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Master switch. If false, the app never calls the backend and simply uses
  /// the offline Ask Veda engine (so nothing can break).
  static const bool enabled = true;
}
