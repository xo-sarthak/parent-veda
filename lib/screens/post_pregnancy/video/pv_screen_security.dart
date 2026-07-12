// =============================================================================
//  PvScreenSecurity - practical (not military-grade) capture protection
// -----------------------------------------------------------------------------
//  A clean abstraction the player can turn on while a lesson is on screen and
//  off when it leaves. It is OFF by default (kEnableScreenSecurity) because it
//  needs a native hook and is invisible in the prototype.
//
//  Android: FLAG_SECURE blocks screenshots and shows a black frame in most
//    screen recorders. Wire it once in MainActivity.kt:
//
//      class MainActivity : FlutterActivity() {
//        override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//          super.configureFlutterEngine(flutterEngine)
//          MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
//              "parentveda/screen_security").setMethodCallHandler { call, result ->
//            when (call.method) {
//              "enable"  -> { window.addFlags(WindowManager.LayoutParams.FLAG_SECURE); result.success(null) }
//              "disable" -> { window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE); result.success(null) }
//              else -> result.notImplemented()
//            }
//          }
//        }
//      }
//
//  iOS: screenshots cannot be prevented outright. What IS possible is detecting
//    UIScreen.capturedDidChangeNotification (screen recording / mirroring) and
//    responding - the player blurs/pauses. Expose that through the same channel
//    ("isCaptured" + an event stream) when we do the iOS pass.
//
//  Honest scope: this raises the bar against casual capture. A determined user
//  with a second camera or a rooted device can still record. That is acceptable -
//  this is UX-grade deterrence, not DRM.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pv_video_config.dart';

class PvScreenSecurity {
  PvScreenSecurity._();
  static final PvScreenSecurity instance = PvScreenSecurity._();

  static const MethodChannel _channel = MethodChannel('parentveda/screen_security');

  bool _secure = false;
  bool get isSecure => _secure;

  /// Turn on capture protection (no-op if disabled by flag or unwired natively).
  Future<void> enable() => _set(true);

  /// Turn it back off - call when the player is disposed so the rest of the app
  /// (screenshots of recipes, journal, etc.) is unaffected.
  Future<void> disable() => _set(false);

  Future<void> _set(bool on) async {
    if (!kEnableScreenSecurity) return;
    if (_secure == on) return;
    try {
      await _channel.invokeMethod(on ? 'enable' : 'disable');
      _secure = on;
    } on MissingPluginException {
      // Native side not wired yet - fail soft so the player still runs.
      if (kDebugMode) {
        debugPrint('PvScreenSecurity: native channel absent; ${on ? 'enable' : 'disable'} skipped');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('PvScreenSecurity error: $e');
    }
  }
}
