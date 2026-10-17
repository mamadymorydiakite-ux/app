import 'dart:async';

import 'package:flutter/foundation.dart';

/// Connection state machine: disconnected → connecting → connected → error.
enum LinkStatus { disconnected, connecting, connected, error }

enum TransferDirection { upload, download }

enum TransferState { queued, active, done }

class TransferItem {
  TransferItem({
    required this.name,
    required this.size,
    required this.direction,
    this.progress = 0,
    this.state = TransferState.queued,
    this.speed = '2.4 MB/s',
    this.remaining = '3 seconds remaining',
  });

  final String name;
  final String size;
  final TransferDirection direction;
  double progress;
  TransferState state;
  String speed;
  String remaining;

  bool get isUpload => direction == TransferDirection.upload;
}

enum ClipboardSource { phone, pc }

class ClipboardEntry {
  ClipboardEntry({required this.text, required this.time, required this.source});

  final String text;
  final String time;
  final ClipboardSource source;
}

class DeviceInfo {
  DeviceInfo({
    required this.name,
    required this.ip,
    required this.session,
    required this.transferred,
    required this.speed,
    this.active = true,
  });

  final String name;
  final String ip;
  final String session;
  final String transferred;
  final String speed;
  final bool active;
}

/// Tiny immutable 2D point used by the trackpad.
class Offset2D {
  const Offset2D(this.x, this.y);

  final double x;
  final double y;
}

/// Single source of truth shared by the Android shell and the desktop shell.
/// Everything is simulated locally — no network, no cloud, fully offline.
class LinkController extends ChangeNotifier {
  LinkController({this.tickInterval = const Duration(milliseconds: 600)}) {
    _timer = Timer.periodic(tickInterval, (_) => tick());
  }

  final Duration tickInterval;
  Timer? _timer;

  // --- Connection -----------------------------------------------------------
  LinkStatus status = LinkStatus.disconnected;
  String localIp = '192.168.1.42';
  String pcName = 'Desktop-PC';
  String phoneName = 'Pixel 8 Pro';
  bool failNextAttempt = false;

  // --- Dashboard stats ------------------------------------------------------
  double localSpeedMbps = 340;
  String sessionTime = '01h 14m';
  String transferredTotal = '1.4 GB';

  // --- Files ---------------------------------------------------------------
  final List<TransferItem> transfers = [
    TransferItem(
      name: 'presentation.pdf',
      size: '24.5 MB',
      direction: TransferDirection.upload,
      progress: 0.45,
      state: TransferState.active,
      remaining: '12 seconds remaining',
    ),
    TransferItem(
      name: 'holiday-photo.jpg',
      size: '4.2 MB',
      direction: TransferDirection.upload,
      progress: 1,
      state: TransferState.done,
    ),
    TransferItem(
      name: 'budget-2026.xlsx',
      size: '820 KB',
      direction: TransferDirection.download,
      progress: 1,
      state: TransferState.done,
    ),
    TransferItem(
      name: 'notes.md',
      size: '12 KB',
      direction: TransferDirection.download,
      progress: 0,
      state: TransferState.queued,
    ),
  ];

  final List<String> phoneFiles = ['IMG_20260114.jpg', 'voice-note.m4a', 'tickets.pdf'];
  final List<String> computerFiles = ['report-final.docx', 'design-assets.zip', 'todo.txt'];

  // --- Clipboard ------------------------------------------------------------
  bool clipboardSync = true;
  final List<ClipboardEntry> clipboard = [
    ClipboardEntry(
      text: 'https://example.local/link-setup — works with no internet connection.',
      time: '14:32',
      source: ClipboardSource.pc,
    ),
    ClipboardEntry(
      text: 'Pairing PIN: 4821 (valid for this session only)',
      time: '14:20',
      source: ClipboardSource.phone,
    ),
    ClipboardEntry(
      text: 'Files stay on your two devices. Nothing is uploaded anywhere.',
      time: '13:58',
      source: ClipboardSource.pc,
    ),
  ];
  ClipboardSource clipboardTab = ClipboardSource.phone;

  // --- Keyboard -------------------------------------------------------------
  String keyboardText = '';
  bool keyboardActive = false;
  bool showOnScreenKeyboard = true;

  // --- Touchpad -------------------------------------------------------------
  Offset2D touchpadPosition = const Offset2D(0.5, 0.5);
  bool dragLock = false;
  int clickCount = 0;
  int scrollCount = 0;

  // --- Ring -----------------------------------------------------------------
  bool ringing = false;
  double ringVolume = 0.8;

  // --- Screen share ---------------------------------------------------------
  bool screenSharing = false;
  bool captureDialogVisible = false;
  bool screenShareInterrupted = false;
  int screenShareSeconds = 0;
  String screenQuality = 'Balanced';
  int latencyMs = 24;
  int fps = 30;
  String resolution = '1080 × 2400';

  // --- Devices --------------------------------------------------------------
  final List<DeviceInfo> devices = [
    DeviceInfo(
      name: 'Pixel 8 Pro',
      ip: '192.168.1.42',
      session: '2h 34m',
      transferred: '156 MB',
      speed: '340 Mbps',
    ),
  ];
  final List<DeviceInfo> history = [
    DeviceInfo(
      name: 'Galaxy S24',
      ip: '192.168.1.87',
      session: '18m',
      transferred: '42 MB',
      speed: '210 Mbps',
      active: false,
    ),
    DeviceInfo(
      name: 'Pixel 6a',
      ip: '192.168.1.55',
      session: '6m',
      transferred: '8 MB',
      speed: '120 Mbps',
      active: false,
    ),
  ];

  // --- Settings -------------------------------------------------------------
  String language = 'English';
  bool startOnBoot = false;
  bool notifications = true;
  String preferredPort = '8080';
  String timeout = '30 seconds';
  bool autoConnect = true;
  bool requirePin = true;
  bool localTls = false;
  int allowedDevices = 3;
  String appVersion = '1.0.0 Stable';

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  /// Advances animated progress. Safe to call manually (used by tests).
  void tick() {
    var changed = false;
    for (final t in transfers) {
      if (t.state == TransferState.active && t.progress < 1) {
        t.progress = (t.progress + 0.04).clamp(0.0, 1.0);
        if (t.progress >= 1) t.state = TransferState.done;
        changed = true;
      }
    }
    if (screenSharing && !screenShareInterrupted) {
      screenShareSeconds += 1;
      latencyMs = 20 + (screenShareSeconds % 5) * 2;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  // --- Connection actions ---------------------------------------------------
  int _attempt = 0;

  void connect() {
    if (status == LinkStatus.connecting) return;
    status = LinkStatus.connecting;
    final attempt = ++_attempt;
    notifyListeners();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (attempt != _attempt) return;
      status = failNextAttempt ? LinkStatus.error : LinkStatus.connected;
      notifyListeners();
    });
  }

  void connectWithIp(String ip) {
    if (ip.trim().isNotEmpty) localIp = ip.trim();
    connect();
  }

  void scanQrCode() {
    localIp = '192.168.1.42';
    connect();
  }

  void cancel() {
    if (status == LinkStatus.connecting) {
      _attempt++; // invalidate the in-flight pairing attempt
      status = LinkStatus.disconnected;
      notifyListeners();
    }
  }

  void retry() {
    failNextAttempt = false;
    connect();
  }

  void disconnect() {
    status = LinkStatus.disconnected;
    ringing = false;
    screenSharing = false;
    captureDialogVisible = false;
    screenShareInterrupted = false;
    keyboardActive = false;
    notifyListeners();
  }

  /// Used by the prototype state switcher.
  void setStatus(LinkStatus value) {
    status = value;
    if (value != LinkStatus.connected) {
      ringing = false;
      screenSharing = false;
      captureDialogVisible = false;
    }
    notifyListeners();
  }

  // --- Files ---------------------------------------------------------------
  void toggleClipboardSync(bool value) {
    clipboardSync = value;
    notifyListeners();
  }

  void startTransfer() {
    final item = transfers.firstWhere(
      (t) => t.state == TransferState.queued,
      orElse: () => transfers.first,
    );
    item.state = TransferState.active;
    if (item.progress >= 1) item.progress = 0.1;
    notifyListeners();
  }

  void cancelTransfer() {
    for (final t in transfers) {
      if (t.state == TransferState.active) t.state = TransferState.queued;
    }
    notifyListeners();
  }

  void clearQueue() {
    transfers.removeWhere((t) => t.state == TransferState.queued);
    notifyListeners();
  }

  int get queuedCount => transfers.where((t) => t.state == TransferState.queued).length;

  /// "Send More Files" — completes the current batch and queues a new file.
  void resetTransfers() {
    for (final t in transfers) {
      t.state = TransferState.done;
      t.progress = 1;
    }
    transfers.add(TransferItem(
      name: 'screenshots.zip',
      size: '6.8 MB',
      direction: TransferDirection.upload,
      progress: 0.05,
      state: TransferState.active,
      remaining: '8 seconds remaining',
    ));
    notifyListeners();
  }

  int get completedCount => transfers.where((t) => t.state == TransferState.done).length;

  // --- Clipboard ------------------------------------------------------------
  void setClipboardTab(ClipboardSource source) {
    clipboardTab = source;
    notifyListeners();
  }

  void addClipboardEntry(String text, ClipboardSource source) {
    if (text.trim().isEmpty) return;
    clipboard.insert(0, ClipboardEntry(text: text.trim(), time: 'now', source: source));
    notifyListeners();
  }

  void pasteOnPhone(ClipboardEntry entry) => addClipboardEntry(entry.text, ClipboardSource.phone);

  void sendToPc(ClipboardEntry entry) => addClipboardEntry(entry.text, ClipboardSource.pc);

  // --- Keyboard -------------------------------------------------------------
  void setKeyboardText(String value) {
    keyboardText = value;
    if (!keyboardActive && value.isNotEmpty) keyboardActive = true;
    notifyListeners();
  }

  void activateTyping() {
    keyboardActive = true;
    notifyListeners();
  }

  void clearText() {
    keyboardText = '';
    keyboardActive = false;
    notifyListeners();
  }

  void setShowOnScreenKeyboard(bool value) {
    showOnScreenKeyboard = value;
    notifyListeners();
  }

  // --- Touchpad -------------------------------------------------------------
  void moveTouchpad(double dx, double dy) {
    touchpadPosition = Offset2D(
      (touchpadPosition.x + dx).clamp(0.02, 0.98),
      (touchpadPosition.y + dy).clamp(0.02, 0.98),
    );
    notifyListeners();
  }

  void setDragLock(bool value) {
    dragLock = value;
    notifyListeners();
  }

  void click({required bool right}) {
    clickCount += 1;
    notifyListeners();
  }

  void scroll(double delta) {
    scrollCount += 1;
    notifyListeners();
  }

  // --- Ring -----------------------------------------------------------------
  void startRinging() {
    ringing = true;
    notifyListeners();
  }

  void stopRinging() {
    ringing = false;
    notifyListeners();
  }

  void setRingVolume(double value) {
    ringVolume = value;
    notifyListeners();
  }

  // --- Screen share ---------------------------------------------------------
  void requestScreenShare() {
    captureDialogVisible = true;
    notifyListeners();
  }

  void cancelScreenShare() {
    captureDialogVisible = false;
    notifyListeners();
  }

  void confirmScreenShare() {
    captureDialogVisible = false;
    screenSharing = true;
    screenShareInterrupted = false;
    screenShareSeconds = 0;
    notifyListeners();
  }

  void stopScreenShare() {
    screenSharing = false;
    captureDialogVisible = false;
    screenShareInterrupted = false;
    notifyListeners();
  }

  void interruptScreenShare() {
    screenShareInterrupted = true;
    notifyListeners();
  }

  void setScreenQuality(String value) {
    screenQuality = value;
    notifyListeners();
  }

  String get screenShareElapsed {
    final m = (screenShareSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (screenShareSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // --- Settings -------------------------------------------------------------
  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void setStartOnBoot(bool value) {
    startOnBoot = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notifications = value;
    notifyListeners();
  }

  void setPort(String value) {
    preferredPort = value;
    notifyListeners();
  }

  void setTimeout(String value) {
    timeout = value;
    notifyListeners();
  }

  void setAutoConnect(bool value) {
    autoConnect = value;
    notifyListeners();
  }

  void setRequirePin(bool value) {
    requirePin = value;
    notifyListeners();
  }

  void setLocalTls(bool value) {
    localTls = value;
    notifyListeners();
  }

  void addAllowedDevice() {
    allowedDevices += 1;
    notifyListeners();
  }

  // --- Devices --------------------------------------------------------------
  void disconnectDevice(String name) {
    devices.removeWhere((d) => d.name == name);
    notifyListeners();
  }

  void connectHistoryDevice(DeviceInfo device) {
    if (!devices.any((d) => d.ip == device.ip)) {
      devices.add(DeviceInfo(
        name: device.name,
        ip: device.ip,
        session: '0m',
        transferred: '0 MB',
        speed: '340 Mbps',
      ));
    }
    notifyListeners();
  }
}
