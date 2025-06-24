import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'drawing_canvas.dart';

class GuesserPage extends StatefulWidget {
  final SocketService socketService;
  const GuesserPage({super.key, required this.socketService});

  @override
  State<GuesserPage> createState() => _GuesserPageState();
}

class _GuesserPageState extends State<GuesserPage> {
  String message = '';
  String input = '';

  @override
  void initState() {
    super.initState();
    widget.socketService.onGuessResult = (result) {
      setState(() {
        message = result == 'yes' ? '🎉 Correct Guess!' : '❌ Wrong guess!';
      });
    };
  }

  void submitGuess() {
    widget.socketService.sendGuess(input);
    setState(() => input = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guesser")),
      body: Column(
        children: [
          Text(message, style: const TextStyle(fontSize: 20)),
          Expanded(child: DrawingCanvas(socketService: widget.socketService)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) => input = val,
              onSubmitted: (_) => submitGuess(),
              decoration: const InputDecoration(hintText: 'Your guess...'),
            ),
          )
        ],
      ),
    );
  }
}
