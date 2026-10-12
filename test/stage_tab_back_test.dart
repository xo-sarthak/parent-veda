// Back on a bottom tab goes Home first; back on Home is the only way out.
//
// The pregnancy shell keeps its five tabs in one IndexedStack inside one
// route, and that route is the first on the stack — so without a PopScope,
// Android back on Tools had nothing to pop but the app. TTC's tab host already
// had the rule; this pins both, by source, so neither shell can lose it.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pregnancy shell: back on a non-Home tab returns to Today', () {
    final src = File('lib/screens/main_scaffold.dart').readAsStringSync();
    expect(src, contains('PopScope('));
    expect(src, contains('canPop: AppNav.instance.index == 0'));
    expect(src, contains('AppNav.instance.go(0)'));
  });

  test('trying-to-conceive host: back on a non-Today tab returns to Today', () {
    final src = File('lib/screens/ttc/ttc_tab_host.dart').readAsStringSync();
    expect(src, contains('canPop: _to == 0'));
    expect(src, contains('TtcTabs.instance.select(0)'));
  });
}
