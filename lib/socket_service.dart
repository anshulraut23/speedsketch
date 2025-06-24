import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  Function(String role)? onRoleConfirmed;
  Function(String from, String guess)? onReceiveGuess;
  Function(String result)? onGuessResult;

  void connect() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    socket.onConnect((_) => print('✅ Connected'));

    socket.on('role_confirmed', (role) {
      if (onRoleConfirmed != null) onRoleConfirmed!(role);
    });

    socket.on('receive_guess', (data) {
      if (onReceiveGuess != null) {
        onReceiveGuess!(data['from'], data['guess']);
      }
    });

    socket.on('guess_result', (result) {
      if (onGuessResult != null) onGuessResult!(result);
    });
  }

  void registerAsDrawer() => socket.emit('register_drawer');
  void registerAsGuesser() => socket.emit('register_guesser');

  void sendDraw(double x0, double y0, double x1, double y1) {
    socket.emit('draw', {'x0': x0, 'y0': y0, 'x1': x1, 'y1': y1});
  }

  void sendGuess(String word) {
    socket.emit('guess', word);
  }

  void respondToGuess(String to, String result) {
    socket.emit('guess_response', {'to': to, 'result': result});
  }

  void disconnect() => socket.disconnect();
}
