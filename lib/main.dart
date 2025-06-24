import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'drawer_page.dart';
import 'guesser_page.dart';

void main() => runApp(const SpeedSketchApp());

class SpeedSketchApp extends StatelessWidget {
  const SpeedSketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeedSketch',
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final socketService = SocketService();

  @override
  void initState() {
    super.initState();
    socketService.connect();
    socketService.onRoleConfirmed = (role) {
      if (role == 'drawer') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DrawerPage(socketService: socketService)));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => GuesserPage(socketService: socketService)));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => socketService.registerAsDrawer(), child: const Text("I want to DRAW")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => socketService.registerAsGuesser(), child: const Text("I want to GUESS")),
          ],
        ),
      ),
    );
  }
}
