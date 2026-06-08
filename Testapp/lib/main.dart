                                                                                                           import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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

class _ControlDashboardState extends State<ControlDashboard> {
  // USB Serial State
  UsbPort? _port;
  List<UsbDevice> _devices = [];
  StreamSubscription<Uint8List>? _subscription;
  String _inputBuffer = "";

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
    UsbSerial.usbEventStream?.listen((event) => _refreshDevices());
    _refreshDevices();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  // --- Logging Logic ---

  Future<void> _initLogging() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/app_debug_log.txt";
    _logFile = File(path);
    _log("LOGGING INITIALIZED. File at: $path");
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
    await _disconnect();
    _log("Connecting to ${device.productName}...");

    _port = await device.create();
    if (!await _port!.open()) {
      _log("ERROR: Failed to open port");
      return;
    }

    await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _subscription = _port!.inputStream!.listen((data) {
      final raw = String.fromCharCodes(data);
      _processIncomingData(raw);
    });

    _log("Connected successfully to ${device.productName}");
    if (mounted) setState(() {});
  }

  Future<void> _disconnect() async {
    if (_port != null) {
      _log("Disconnecting...");
      await _subscription?.cancel();
      _subscription = null;
      _port?.close();
      _port = null;
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
        title: const Text("S&D MediCare Control System"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => _showLogTerminal(context),
            tooltip: "View Logs",
          ),
          IconButton(
            icon: const Icon(Icons.usb),
            onPressed: () => _showDeviceSelector(context),
            color: _port != null ? Colors.greenAccent : Colors.redAccent,
          ),
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
    return _buildMetricCard(
      title: "TREADMILL CONTROL",
      icon: Icons.directions_run,
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
                label: "TARGET SPEED: ${_targetSpeed.toStringAsFixed(1)} M/h",
                value: _targetSpeed,
                min: 0.5,
                max: 20.0,
                divisions: 195,
                onChanged: (v) => setState(() => _targetSpeed = v),
                onChangeEnd: (v) => _sendCommand("setSpeed:${(v * 100).toInt()}"),
                isTablet: isTablet,
              ),
              _buildControlSlider(
                label: "TARGET TIMER: ${_targetSeconds ~/ 60}m",
                value: _targetSeconds.toDouble(),
                min: 60,
                max: 3600,
                divisions: 59,
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
                          setState(() => _isRunning = true);
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
                          setState(() => _isRunning = false);
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
    );
  }

  Widget _buildWaterTankPanel(bool isTablet) {
    double metricFontSize = isTablet ? 32 : 24;
    return _buildMetricCard(
      title: "WATER TANK",
      icon: Icons.water_drop,
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
              _faultMessage = "MANUAL EMERGENCY STOP";
            });
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }
}
