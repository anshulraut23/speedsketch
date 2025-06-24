import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'drawing_canvas.dart';

class DrawerPage extends StatefulWidget {
  final SocketService socketService;
  const DrawerPage({super.key, required this.socketService});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  List<Map<String, String>> guesses = [];

  @override
  void initState() {
    super.initState();
    widget.socketService.onReceiveGuess = (from, guess) {
      setState(() => guesses.add({'from': from, 'guess': guess}));
    };
  }

  void respond(String to, String result) {
    widget.socketService.respondToGuess(to, result);
    setState(() => guesses.removeWhere((g) => g['from'] == to));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drawer")),
      body: Column(
        children: [
          const Text('Draw here!'),
          Expanded(child: DrawingCanvas(socketService: widget.socketService)),
          const Divider(),
          const Text("Incoming Guesses:"),
          ...guesses.map((g) => ListTile(
            title: Text('${g['from']}: ${g['guess']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () => respond(g['from']!, 'yes'), child: const Text("Yes")),
                TextButton(onPressed: () => respond(g['from']!, 'no'), child: const Text("No")),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
