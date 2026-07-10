import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BroadcastChannel {
  static const MethodChannel _channel = MethodChannel('com.example.mobileappassn2/broadcast');

  static Future<void> sendCustomBroadcast(String message) async {
    await _channel.invokeMethod('sendCustomBroadcast', {'message': message});
  }

  static Future<void> registerBatteryReceiver() async {
    await _channel.invokeMethod('registerBatteryReceiver');
  }

  static Future<void> unregisterBatteryReceiver() async {
    await _channel.invokeMethod('unregisterBatteryReceiver');
  }

  static Future<void> registerCustomReceiver() async {
    await _channel.invokeMethod('registerCustomReceiver');
  }

  static Future<void> unregisterCustomReceiver() async {
    await _channel.invokeMethod('unregisterCustomReceiver');
  }

  static void setMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) {
    _channel.setMethodCallHandler(handler);
  }
}

enum BroadcastStep {
  selection,
  customInput,
  customReceiver,
  batteryReceiver,
}

class BroadcastReceiverScreen extends StatefulWidget {
  const BroadcastReceiverScreen({super.key});

  @override
  State<BroadcastReceiverScreen> createState() => _BroadcastReceiverScreenState();
}

class _BroadcastReceiverScreenState extends State<BroadcastReceiverScreen> {
  BroadcastStep _currentStep = BroadcastStep.selection;
  String _selectedType = 'Custom';
  final TextEditingController _textController = TextEditingController();
  
  String _customInputText = '';
  String _receivedCustomMessage = 'Waiting for broadcast...';
  int? _batteryPercentage;

  @override
  void initState() {
    super.initState();
    BroadcastChannel.setMethodCallHandler(_handleNativeMethodCalls);
  }

  Future<dynamic> _handleNativeMethodCalls(MethodCall call) async {
    switch (call.method) {
      case 'onCustomBroadcastReceived':
        final String message = call.arguments as String;
        setState(() {
          _receivedCustomMessage = "Received: $message";
        });
        break;
      case 'onBatteryPercentageReceived':
        final int percentage = call.arguments as int;
        setState(() {
          _batteryPercentage = percentage;
        });
        break;
    }
  }

  @override
  void dispose() {
    _cleanupReceivers();
    _textController.dispose();
    super.dispose();
  }

  void _cleanupReceivers() {
    BroadcastChannel.unregisterBatteryReceiver();
    BroadcastChannel.unregisterCustomReceiver();
  }

  void _onProceed() {
    if (_selectedType == 'Custom') {
      setState(() {
        _currentStep = BroadcastStep.customInput;
      });
    } else {
      BroadcastChannel.registerBatteryReceiver();
      setState(() {
        _currentStep = BroadcastStep.batteryReceiver;
      });
    }
  }

  void _onCustomInputNext() {
    _customInputText = _textController.text;
    BroadcastChannel.registerCustomReceiver();
    setState(() {
      _currentStep = BroadcastStep.customReceiver;
    });
  }

  void _triggerCustomBroadcast() {
    BroadcastChannel.sendCustomBroadcast(_customInputText);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom broadcast sent!')),
    );
  }

  void _goBackToSelection() {
    _cleanupReceivers();
    setState(() {
      _currentStep = BroadcastStep.selection;
      _textController.clear();
      _receivedCustomMessage = 'Waiting for broadcast...';
      _batteryPercentage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_currentStep != BroadcastStep.selection)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: TextButton.icon(
                onPressed: _goBackToSelection,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Select'),
              ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildCurrentView(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_currentStep) {
      case BroadcastStep.selection:
        return _buildSelectionView();
      case BroadcastStep.customInput:
        return _buildCustomInputView();
      case BroadcastStep.customReceiver:
        return _buildCustomReceiverView();
      case BroadcastStep.batteryReceiver:
        return _buildBatteryReceiverView();
    }
  }

  Widget _buildSelectionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Select a broadcast type',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedType,
          items: const [
            DropdownMenuItem(
              value: 'Custom',
              child: Text('Custom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            DropdownMenuItem(
              value: 'Battery',
              child: Text('Battery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onProceed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Proceed'),
        ),
      ],
    );
  }

  Widget _buildCustomInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter message for broadcast:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type something...',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _onCustomInputNext,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomReceiverView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Custom Broadcast Receiver',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Text(
          _receivedCustomMessage,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _triggerCustomBroadcast,
            child: const Text('Send Custom Broadcast'),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryReceiverView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Listening for Battery Broadcasts...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          _batteryPercentage != null
              ? 'Battery level: $_batteryPercentage%'
              : 'Battery level: Fetching...',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
