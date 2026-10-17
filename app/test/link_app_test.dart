import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/desktop/desktop_shell.dart';
import 'package:link/main.dart';
import 'package:link/mobile/mobile_shell.dart';
import 'package:link/state/link_controller.dart';
import 'package:link/theme.dart';

/// Pumps the mobile hub at a phone-sized surface.
Future<void> pumpHub(WidgetTester tester, {Size size = const Size(900, 1700)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const LinkMockupApp());
  await tester.pump(const Duration(milliseconds: 60));
}

/// Pumps the Windows shell on its own (1100 × 700 window surface).
Future<void> pumpDesktop(WidgetTester tester, LinkController controller,
    {Size size = const Size(1400, 950)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: buildLinkTheme(),
    home: Scaffold(
      backgroundColor: LinkColors.background,
      body: Center(child: DesktopApp(controller: controller)),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 60));
}

/// Tears the widget tree down so the mockup's periodic ticker is cancelled.
Future<void> disposeUi(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  // Register the bundled Outfit font so text metrics match the real app.
  setUpAll(() async {
    final loader = FontLoader('Outfit');
    final bytes = await rootBundle.load('assets/fonts/Outfit.ttf');
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  });

  group('connection state machine', () {
    test('starts disconnected and pairs locally', () async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      addTearDown(c.dispose);

      expect(c.status, LinkStatus.disconnected);
      expect(c.localIp, '192.168.1.42');

      c.connect();
      expect(c.status, LinkStatus.connecting);

      await Future<void>.delayed(const Duration(milliseconds: 1700));
      expect(c.status, LinkStatus.connected);
      expect(c.devices.single.name, 'Pixel 8 Pro');
    });

    test('cancelling returns to the pairing screen', () async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      addTearDown(c.dispose);

      c.connect();
      c.cancel();
      expect(c.status, LinkStatus.disconnected);
      await Future<void>.delayed(const Duration(milliseconds: 1700));
      expect(c.status, LinkStatus.disconnected);
    });

    test('failure is reported then a retry succeeds', () async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      addTearDown(c.dispose);

      c.failNextAttempt = true;
      c.connect();
      await Future<void>.delayed(const Duration(milliseconds: 1700));
      expect(c.status, LinkStatus.error);

      c.retry();
      expect(c.status, LinkStatus.connecting);
      await Future<void>.delayed(const Duration(milliseconds: 1700));
      expect(c.status, LinkStatus.connected);
    });

    test('disconnecting stops ringing and screen sharing', () {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      addTearDown(c.dispose);

      c.setStatus(LinkStatus.connected);
      c.startRinging();
      c.confirmScreenShare();
      c.disconnect();

      expect(c.status, LinkStatus.disconnected);
      expect(c.ringing, isFalse);
      expect(c.screenSharing, isFalse);
    });
  });

  group('mobile app', () {
    testWidgets('pairs over the QR code and reaches the dashboard', (tester) async {
      await pumpHub(tester);

      expect(find.text('Connect to your PC'), findsOneWidget);
      expect(find.text('No internet required. Paired locally.'), findsOneWidget);

      await tester.tap(find.text('Scan QR Code'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Scan Desktop QR'), findsOneWidget);
      expect(find.text('PAIRING VIA WI-FI DIRECT'), findsOneWidget);

      await tester.tap(find.text('Use IP Address'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.textContaining('Connecting to'), findsOneWidget);
      expect(find.text('IP Address: 192.168.1.42'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('CONNECTED SEAMLESSLY'), findsOneWidget);
      expect(find.text('LOCAL'), findsWidgets);
      expect(find.text('Send Files'), findsOneWidget);
      expect(find.text('Screen Share'), findsOneWidget);
      expect(find.text('340 Mbps • 01h 14m session'), findsOneWidget);

      await disposeUi(tester);
    });

    testWidgets('manual IP entry uses the typed address', (tester) async {
      await pumpHub(tester);

      await tester.enterText(find.byType(TextField).first, '192.168.1.99');
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('Connect'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('IP Address: 192.168.1.99'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('CONNECTED SEAMLESSLY'), findsOneWidget);

      await disposeUi(tester);
    });

    testWidgets('bottom navigation reaches every tab', (tester) async {
      await pumpHub(tester);

      await tester.tap(find.text('Files'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Select files to send'), findsOneWidget);

      await tester.tap(find.text('Clipboard'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Clipboard Sync'), findsWidgets);
      expect(find.text('Phone Clipboard'), findsOneWidget);

      await tester.tap(find.text('Tools'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Remote Keyboard'), findsOneWidget);
      expect(find.text('Mouse & Trackpad'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Start on boot'), findsOneWidget);
      expect(find.text('PROTOTYPE'), findsOneWidget);

      await disposeUi(tester);
    });
  });

  group('desktop app', () {
    testWidgets('ready → connecting → connected overview', (tester) async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      await pumpDesktop(tester, c);

      expect(find.text('Connect your phone'), findsOneWidget);
      expect(find.text('LOCAL IP: 192.168.1.42'), findsOneWidget);
      expect(find.text('Waiting for device…'), findsOneWidget);
      expect(find.text('Local Connection Only'), findsOneWidget);

      c.connect();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.textContaining('Connecting to'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.textContaining('Welcome back to'), findsOneWidget);
      expect(find.text('WI-FI DIRECT'), findsOneWidget);
      expect(find.text('340 Mbps'), findsOneWidget);
      expect(find.text('PIXEL 8 PRO'), findsOneWidget);

      await disposeUi(tester);
      c.dispose();
    });

    testWidgets('files tab shows the three columns and the transfer queue', (tester) async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      c.setStatus(LinkStatus.connected);
      await pumpDesktop(tester, c);

      await tester.tap(find.text('Files'));
      await tester.pump(const Duration(milliseconds: 60));

      expect(find.text('Phone (Pixel 8 Pro)'), findsOneWidget);
      expect(find.text('Computer (Local)'), findsOneWidget);
      expect(find.text('Drag files here to send instantly'), findsOneWidget);
      expect(find.text('RECENT TRANSFERS'), findsOneWidget);
      expect(find.text('presentation.pdf'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);

      // Progress advances with every tick of the local transfer loop.
      for (var i = 0; i < 7; i++) {
        c.tick();
      }
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('73%'), findsOneWidget);

      // Finish the batch to reach the "Transfer Complete" screen.
      c.clearQueue();
      c.cancelTransfer();
      for (final t in c.transfers) {
        t.state = TransferState.done;
        t.progress = 1;
      }
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('Transfer Complete'), findsOneWidget);
      expect(find.text('Send More Files'), findsOneWidget);

      await tester.tap(find.text('Send More Files'));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('RECENT TRANSFERS'), findsOneWidget);
      expect(find.text('screenshots.zip'), findsOneWidget);

      await disposeUi(tester);
      c.dispose();
    });

    testWidgets('screen share goes live then reconnects', (tester) async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      c.setStatus(LinkStatus.connected);
      await pumpDesktop(tester, c);

      await tester.tap(find.text('Screen'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('View your Android screen on this computer'), findsOneWidget);
      expect(find.text('Simulate incoming screen share'), findsOneWidget);

      c.confirmScreenShare();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('LIVE'), findsWidgets);
      expect(find.text('Fullscreen'), findsOneWidget);
      expect(find.text('Screenshot'), findsOneWidget);

      c.interruptScreenShare();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Screen share interrupted — Reconnecting…'), findsOneWidget);
      expect(find.text('Reconnect now'), findsOneWidget);

      c.confirmScreenShare();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('LIVE'), findsWidgets);

      await disposeUi(tester);
      c.dispose();
    });
  });

  group('desktop tools', () {
    testWidgets('clipboard, mouse and ring sections work', (tester) async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      c.setStatus(LinkStatus.connected);
      await pumpDesktop(tester, c);

      final before = c.clipboard.length;

      await tester.tap(find.text('Clipboard'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('SYNCED LOCALLY'), findsOneWidget);
      expect(find.text('Phone Clipboard'), findsOneWidget);

      await tester.tap(find.text('Copy to PC').first);
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.clipboard.length, before + 1);

      await tester.tap(find.text('Mouse'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Virtual Trackpad Active'), findsOneWidget);
      expect(find.text('SUPPORTED GESTURES'), findsOneWidget);

      await tester.tap(find.text('Ring Phone'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Ring Your Phone'), findsOneWidget);

      await tester.tap(find.text('Ring Phone').last);
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.ringing, isTrue);
      expect(find.text('RINGING PIXEL 8 PRO NOW'), findsOneWidget);

      await tester.tap(find.text('Stop Ringing'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.ringing, isFalse);

      await disposeUi(tester);
      c.dispose();
    });

    testWidgets('prototype switcher jumps between states', (tester) async {
      final c = LinkController(tickInterval: const Duration(hours: 1));
      await pumpDesktop(tester, c);

      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Start on Boot'), findsOneWidget);
      expect(find.text('Require PIN for pairing'), findsOneWidget);

      await tester.tap(find.text('Connected'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.status, LinkStatus.connected);

      await tester.tap(find.text('Error'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(c.status, LinkStatus.error);

      await tester.tap(find.text('Overview'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Connection Failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await disposeUi(tester);
      c.dispose();
    });
  });

  group('design system', () {
    testWidgets('mobile shell keeps the 390 × 844 Android surface', (tester) async {
      await pumpHub(tester);
      expect(tester.getSize(find.byType(MobileApp)), const Size(390, 844));

      await disposeUi(tester);
    });

    testWidgets('bundled Outfit font is available offline and keeps real weights', (tester) async {
      final bytes = await rootBundle.load('assets/fonts/Outfit.ttf');
      expect(bytes.lengthInBytes, greaterThan(50000));

      double widthOf(FontWeight weight) {
        final painter = TextPainter(
          text: TextSpan(
            text: 'Link local mockup',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: weight, fontSize: 32),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        return painter.width;
      }

      final regular = widthOf(FontWeight.w400);
      final heavy = widthOf(FontWeight.w800);
      expect(regular, greaterThan(0));
      // The variable font exposes the wght axis, so heavy text is really heavier.
      expect(heavy, greaterThan(regular));
    });
  });

}
