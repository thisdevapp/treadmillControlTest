                                                                                                           import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treadmill Control System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ControlDashboard(),
    );
  }
}

class ControlDashboard extends StatefulWidget {
  const ControlDashboard({super.key});

  @override
  State<ControlDashboard> createState() => _ControlDashboardState();
}

class _ControlDashboardState extends State<ControlDashboard> with SingleTickerProviderStateMixin {
  // USB Serial State
  UsbPort? _port;
  UsbDevice? _connectedDevice;
  Map<String, dynamic>? _lastDeviceIdentity;
  List<UsbDevice> _devices = [];
  StreamSubscription<Uint8List>? _subscription;
  String _inputBuffer = "";
  Timer? _connectionCheckTimer;
  Timer? _demoSimulationTimer;
  bool _isAlertShowing = false;
  bool _isDeviceSelectorShowing = false;

  // Animation for USB Icon
  late AnimationController _pulseController;

  // Treadmill State
  bool _isRunning = false;
  double _currentSpeed = 0.0;
  double _targetSpeed = 1.0;
  int _elapsedSeconds = 0;
  int _targetSeconds = 300;
  double _sessionDistance = 0.0;

  // Water Tank State
  double _currentTemp = 0.0;
  double _targetTemp = 39.0;
  double _waterLevel = 0.0;

  // System State
  String _faultMessage = "";

  // Logging State
  List<String> _liveLogs = [];
  File? _logFile;
  final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  @override
  void initState() {
    super.initState();
    _initLogging();
    _loadSavedDevice();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    UsbSerial.usbEventStream?.listen((event) {
      _refreshDevices();
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        _handleUsbAttached();
      }
    });
    _refreshDevices();
    _startConnectionTimer();
  }

  Future<void> _handleUsbAttached() async {
    // Wait a bit for devices to be fully recognized by the system
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final currentDevices = await UsbSerial.listDevices();
    bool knownDevicePresent = false;

    if (_lastDeviceIdentity != null) {
      for (var device in currentDevices) {
        if (device.vid == _lastDeviceIdentity!['vid'] &&
            device.pid == _lastDeviceIdentity!['pid'] &&
            device.deviceName == _lastDeviceIdentity!['deviceName']) {
          knownDevicePresent = true;
          break;
        }
      }
    }

    if (knownDevicePresent) {
      _log("Known device detected upon attachment. Skipping popup.");
      // The periodic connection timer or a manual check will handle the actual connection
      await _checkConnectionStatus();
    } else {
      // Only show selector if no known device is present and we're not connected
      if (_port == null && !_isDeviceSelectorShowing && !_isAlertShowing) {
        _log("Unknown device detected. Showing device selector.");
        _showDeviceSelector(context);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectionCheckTimer?.cancel();
    _demoSimulationTimer?.cancel();
    _disconnect();
    super.dispose();
  }

  void _startDemoSimulation() {
    _demoSimulationTimer?.cancel();
    _demoSimulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_isRunning) {
          // Ramping up to target
          double targetKmH = _targetSpeed / 1000.0;
          if (_currentSpeed < targetKmH) {
            _currentSpeed += (targetKmH / 10); // Ramp up in 10 seconds
            if (_currentSpeed > targetKmH) _currentSpeed = targetKmH;
          } else if (_currentSpeed > targetKmH) {
            _currentSpeed -= (targetKmH / 10);
            if (_currentSpeed < targetKmH) _currentSpeed = targetKmH;
          }

          // Counting down
          if (_elapsedSeconds > 0) {
            _elapsedSeconds--;
          } else {
            _isRunning = false; // Auto stop when timer hits zero
          }
        } else {
          // Ramping down to zero
          if (_currentSpeed > 0) {
            _currentSpeed -= 0.5; // Fixed decrease for stopping feel
            if (_currentSpeed < 0) _currentSpeed = 0;
          } else {
            _currentSpeed = 0;
            _demoSimulationTimer?.cancel();
          }
          _elapsedSeconds = 0;
        }
      });
    });
  }

  void _startConnectionTimer() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    final currentDevices = await UsbSerial.listDevices();

    if (_port != null) {
      // Current Connection Check
      bool deviceStillPresent = false;
      for (var device in currentDevices) {
        if (_connectedDevice != null &&
            device.vid == _connectedDevice!.vid &&
            device.pid == _connectedDevice!.pid &&
            device.deviceName == _connectedDevice!.deviceName) {
          deviceStillPresent = true;
          break;
        }
      }

      if (!deviceStillPresent) {
        _log("CRITICAL: Connected device lost from USB list.");
        _handleUnexpectedDisconnection();
      }
    } else {
      // Auto-Reconnection Check
      if (_lastDeviceIdentity != null) {
        for (var device in currentDevices) {
          if (device.vid == _lastDeviceIdentity!['vid'] &&
              device.pid == _lastDeviceIdentity!['pid'] &&
              device.deviceName == _lastDeviceIdentity!['deviceName']) {
            _log("Auto-reconnection: Found last known device. Attempting connect...");
            _connect(device);
            break;
          }
        }
      }
    }
  }

  void _handleUnexpectedDisconnection() {
    _disconnect(isManual: false);
    if (!_isAlertShowing) {
      _showDisconnectionAlert();
    }
  }

  void _showDisconnectionAlert() {
    _isAlertShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text("Connection Lost"),
          ],
        ),
        content: const Text("USB connection to the device has been lost. Please check the cable and try reconnecting."),
        actions: [
          FilledButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              _isAlertShowing = false;
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    ).then((_) {
      _isAlertShowing = false;
    });
  }

  // --- Logging Logic ---

  Future<void> _initLogging() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/app_debug_log.txt";
    _logFile = File(path);
    _log("LOGGING INITIALIZED. File at: $path");
  }

  Future<void> _loadSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final vid = prefs.getInt('last_vid');
    final pid = prefs.getInt('last_pid');
    final name = prefs.getString('last_name');

    if (vid != null && pid != null && name != null) {
      setState(() {
        _lastDeviceIdentity = {
          'vid': vid,
          'pid': pid,
          'deviceName': name,
        };
      });
      _log("Loaded saved device: $name (VID: $vid, PID: $pid)");
      // Check immediately if it's already plugged in
      _checkConnectionStatus();
    }
  }

  Future<void> _saveDevice(UsbDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_vid', device.vid ?? 0);
    await prefs.setInt('last_pid', device.pid ?? 0);
    await prefs.setString('last_name', device.deviceName ?? "");
    _log("Saved device to storage: ${device.deviceName}");
  }

  Future<void> _clearSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_vid');
    await prefs.remove('last_pid');
    await prefs.remove('last_name');
    _log("Cleared saved device from storage.");
  }

  void _log(String message) {
    final timestamp = _timeFormat.format(DateTime.now());
    final entry = "[$timestamp] $message";

    setState(() {
      _liveLogs.add(entry);
      if (_liveLogs.length > 100) _liveLogs.removeAt(0);
    });

    _logFile?.writeAsStringSync("$entry\n", mode: FileMode.append);
    debugPrint(entry);
  }

  // --- USB Serial Logic ---

  Future<void> _refreshDevices() async {
    _devices = await UsbSerial.listDevices();
    _log("USB devices refreshed. Found: ${_devices.length}");
    if (mounted) setState(() {});
  }

  Future<void> _connect(UsbDevice device) async {
    await _disconnect(isManual: false);
    _log("Connecting to ${device.productName}...");

    _port = await device.create();
    if (!await _port!.open()) {
      _log("ERROR: Failed to open port");
      return;
    }

    _connectedDevice = device;
    _lastDeviceIdentity = {
      'vid': device.vid,
      'pid': device.pid,
      'deviceName': device.deviceName,
    };
    _saveDevice(device);

    // Auto-dismiss alert if it's showing
    if (_isAlertShowing) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _subscription = _port!.inputStream!.listen((data) {
      final raw = String.fromCharCodes(data);
      _processIncomingData(raw);
    }, onError: (error) {
      _log("Stream Error: $error");
      _handleUnexpectedDisconnection();
    }, onDone: () {
      _log("Stream Closed");
      _handleUnexpectedDisconnection();
    });

    _log("Connected successfully to ${device.productName}");
    if (mounted) setState(() {});
  }

  Future<void> _disconnect({bool isManual = true}) async {
    if (_port != null) {
      _log("Disconnecting...");
      await _subscription?.cancel();
      _subscription = null;
      _port?.close();
      _port = null;
      _connectedDevice = null;
      if (isManual) {
        _lastDeviceIdentity = null;
        _clearSavedDevice();
      }
      _log("Disconnected.");
    }
    if (mounted) setState(() {});
  }

  void _sendCommand(String cmd) async {
    if (_port != null) {
      final fullCmd = "$cmd*";
      _log("TX >> $fullCmd");
      await _port!.write(Uint8List.fromList(fullCmd.codeUnits));
    } else {
      _log("WARN: Attempted to send command without connection: $cmd");
    }
  }

  void _processIncomingData(String data) {
    _inputBuffer += data;
    if (_inputBuffer.contains('*')) {
      List<String> commands = _inputBuffer.split('*');
      _inputBuffer = commands.last;
      for (int i = 0; i < commands.length - 1; i++) {
        final singleCmd = commands[i].trim();
        _log("RX << $singleCmd");
        _handleSingleCommand(singleCmd);
      }
    }
  }

  void _handleSingleCommand(String cmd) {
    if (!mounted) return;
    setState(() {
      if (cmd.startsWith("distance:")) {
        _sessionDistance = double.tryParse(cmd.split(":")[1]) ?? 0.0;
      } else if (cmd.startsWith("currentTemp:")) {
        _currentTemp = double.tryParse(cmd.split(":")[1]) ?? 0.0;
      } else if (cmd.startsWith("waterLevel:")) {
        _waterLevel = double.tryParse(cmd.split(":")[1]) ?? 0.0;
      } else if (cmd.startsWith("faultAlarm:")) {
        _faultMessage = cmd.split(":")[1];
        _log("FAULT DETECTED: $_faultMessage");
      } else if (cmd == "Emergency") {
        _isRunning = false;
        _faultMessage = "EMERGENCY STOP PRESSED";
        _log("EMERGENCY SIGNAL RECEIVED");
      }
    });
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Treadmill Controller"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => _showLogTerminal(context),
            tooltip: "View Logs",
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                bool isConnected = _port != null;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isConnected)
                      Container(
                        width: 32 + (20 * _pulseController.value),
                        height: 32 + (20 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(1 - _pulseController.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.usb),
                      onPressed: () => _showDeviceSelector(context),
                      color: isConnected ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Tablet layout (side-by-side) only if width is large AND it's landscape
          bool isLandscapeTablet = constraints.maxWidth > 700 && constraints.maxWidth > constraints.maxHeight;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_faultMessage.isNotEmpty) _buildFaultBanner(),
                const SizedBox(height: 16),
                if (isLandscapeTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildTreadmillPanel(isLandscapeTablet)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildWaterTankPanel(isLandscapeTablet)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildTreadmillPanel(isLandscapeTablet),
                      const SizedBox(height: 16),
                      _buildWaterTankPanel(isLandscapeTablet),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildEmergencyBar(),
    );
  }

  void _showLogTerminal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("LIVE SYSTEM LOGS",
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Clear"),
                      onPressed: () {
                        setState(() => _liveLogs.clear());
                        _logFile?.writeAsStringSync("");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.greenAccent),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _liveLogs.length,
                itemBuilder: (context, i) {
                  final log = _liveLogs[_liveLogs.length - 1 - i];
                  return Text(
                    log,
                    style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaultBanner() {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text("SYSTEM FAULT: $_faultMessage", style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _faultMessage = ""),
        ),
      ),
    );
  }

  Widget _buildTreadmillPanel(bool isTablet) {
    bool isConnected = _port != null;
    return _buildMetricCard(
      title: "TREADMILL CONTROL",
      icon: Icons.directions_run,
      child: IgnorePointer(
        ignoring: !isConnected,
        child: Opacity(
          opacity: isConnected ? 1.0 : 0.4,
          child: Column(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                double metricFontSize = isTablet ? 32 : 24;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBigMetric("SPEED", _currentSpeed.toStringAsFixed(2), "km/h", Colors.orange, metricFontSize),
                    _buildBigMetric("TIME", _formatTime(_elapsedSeconds), "MM:SS", Colors.blue, metricFontSize),
                    _buildBigMetric("DISTANCE", _sessionDistance.toStringAsFixed(3), "km", Colors.green, metricFontSize),
                  ],
                );
              }),
              const Divider(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildControlSlider(
                    label: "TARGET SPEED: ${_targetSpeed.toInt()} M/h",
                    value: _targetSpeed,
                    min: 1,
                    max: 5000,
                    divisions: 4999,
                    onChanged: (v) => setState(() => _targetSpeed = v),
                    onChangeEnd: (v) => _sendCommand("setSpeed:${v.toInt()}"),
                    isTablet: isTablet,
                  ),
                  _buildControlSlider(
                    label: "TARGET TIMER: ${_formatTime(_targetSeconds)}",
                    value: _targetSeconds.toDouble(),
                    min: 1,
                    max: 1200,
                    divisions: 1199,
                    onChanged: (v) => setState(() => _targetSeconds = v.toInt()),
                    onChangeEnd: (v) => _sendCommand("setTimer:${v.toInt()}"),
                    isTablet: isTablet,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isRunning
                          ? null
                          : () {
                              setState(() {
                                _isRunning = true;
                                _elapsedSeconds = _targetSeconds;
                              });
                              _startDemoSimulation();
                              _sendCommand("start");
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("START"),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: !_isRunning
                          ? null
                          : () {
                              setState(() {
                                _isRunning = false;
                                _elapsedSeconds = 0;
                              });
                              _sendCommand("stop");
                            },
                      icon: const Icon(Icons.stop),
                      label: const Text("STOP"),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterTankPanel(bool isTablet) {
    bool isConnected = _port != null;
    double metricFontSize = isTablet ? 32 : 24;
    return _buildMetricCard(
      title: "WATER TANK",
      icon: Icons.water_drop,
      child: IgnorePointer(
        ignoring: !isConnected,
        child: Opacity(
          opacity: isConnected ? 1.0 : 0.4,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBigMetric("TEMP", _currentTemp.toStringAsFixed(1), "°C", Colors.redAccent, metricFontSize),
                  _buildBigMetric("LEVEL", _waterLevel.toStringAsFixed(1), "cm", Colors.blueAccent, metricFontSize),
                ],
              ),
              const Divider(height: 32),
              _buildControlSlider(
                label: "TARGET TEMP: ${_targetTemp.toInt()}°C",
                value: _targetTemp,
                min: 20,
                max: 45,
                divisions: 25,
                onChanged: (v) => setState(() => _targetTemp = v),
                onChangeEnd: (v) => _sendCommand("targetTemp:${v.toInt()}"),
                isTablet: isTablet,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendCommand("setWaterTank"),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text("FILL TANK"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendCommand("drain"),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text("DRAIN"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
    required bool isTablet,
  }) {
    return Container(
      width: isTablet ? 300 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBigMetric(String label, String value, String unit, Color color, double fontSize) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color, fontFamily: 'Courier')),
        Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmergencyBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.red.withAlpha(25),
        child: FilledButton(
          onPressed: () {
            setState(() {
              _isRunning = false;
              _currentSpeed = 0;
              _elapsedSeconds = 0;
              _faultMessage = "MANUAL EMERGENCY STOP";
            });
            _demoSimulationTimer?.cancel();
            _sendCommand("Emergency");
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("EMERGENCY STOP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _showDeviceSelector(BuildContext context) async {
    await _refreshDevices();
    if (!context.mounted) return;
    if (_isDeviceSelectorShowing) return;

    setState(() => _isDeviceSelectorShowing = true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select USB Device"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _devices.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(_devices[i].productName ?? "Unknown"),
              subtitle: Text("VID: ${_devices[i].vid} PID: ${_devices[i].pid}"),
              onTap: () {
                _connect(_devices[i]);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE"),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _isDeviceSelectorShowing = false);
    });
  }
}
