// ===== lib/drawing_canvas.dart =====
import 'package:flutter/material.dart';
import 'socket_service.dart';

offsetToRelative(Offset o, Size size) => Offset(o.dx / size.width, o.dy / size.height);
offsetFromRelative(Offset o, Size size) => Offset(o.dx * size.width, o.dy * size.height);

class DrawingCanvas extends StatefulWidget {
  final SocketService socketService;
  const DrawingCanvas({super.key, required this.socketService});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<Offset> points = [];

  @override
  void initState() {
    super.initState();
    widget.socketService.socket.on('draw', (data) {
      final size = context.size ?? const Size(1, 1);
      setState(() {
        points.add(offsetFromRelative(Offset(data['x1'], data['y1']), size));
      });
    });

    widget.socketService.socket.on('clear', (_) {
      setState(() => points.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        points.add(details.localPosition);
      },
      onPanUpdate: (details) {
        final size = context.size ?? const Size(1, 1);
        final local = details.localPosition;
        final last = points.isNotEmpty ? points.last : local;

        widget.socketService.sendDraw(
          offsetToRelative(last, size).dx,
          offsetToRelative(last, size).dy,
          offsetToRelative(local, size).dx,
          offsetToRelative(local, size).dy,
        );

        setState(() => points.add(local));
      },
      child: CustomPaint(
        painter: DrawingPainter(points),
        size: Size.infinite,
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
