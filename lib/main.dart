import 'package:flutter/material.dart';
import 'screens/broadcast_receiver_screen.dart';
import 'screens/image_scale_screen.dart';
import 'screens/video_screen.dart';
import 'screens/audio_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedDrawerIndex = 0;

  final List<String> _titles = [
    'App',
    'Image Scale',
    'Video',
    'Audio',
  ];

  final List<Widget> _screens = [
    const BroadcastReceiverScreen(),
    const ImageScaleScreen(),
    const VideoScreen(),
    const AudioScreen(),
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedDrawerIndex]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            _buildDrawerItem(
              title: 'Broadcast Receiver',
              isSelected: _selectedDrawerIndex == 0,
              onTap: () => _onSelectItem(0),
            ),
            _buildDrawerItem(
              title: 'Image Scale',
              isSelected: _selectedDrawerIndex == 1,
              onTap: () => _onSelectItem(1),
            ),
            _buildDrawerItem(
              title: 'Video',
              isSelected: _selectedDrawerIndex == 2,
              onTap: () => _onSelectItem(2),
            ),
            _buildDrawerItem(
              title: 'Audio',
              isSelected: _selectedDrawerIndex == 3,
              onTap: () => _onSelectItem(3),
            ),
          ],
        ),
      ),
      body: _screens[_selectedDrawerIndex],
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: isSelected ? Colors.deepPurple : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
