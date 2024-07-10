import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:color_mesh/color_mesh.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MeshGradient.precacheShader();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String _title = 'color_mesh Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MeshPlayground(),
    );
  }
}

class MeshPlayground extends StatefulWidget {
  const MeshPlayground({super.key});

  @override
  State<MeshPlayground> createState() => _MeshPlaygroundState();
}

class _MeshPlaygroundState extends State<MeshPlayground> {
  final List<Offset> _offsets = [
    const Offset(0.1, 0.3),
    const Offset(0.15, 0.6),
    const Offset(0.6, 0.1),
    const Offset(0.85, 0.8),
  ];

  late MeshGradient _gradient;

  @override
  void initState() {
    super.initState();
    _gradient = MeshGradient(
      colors: const [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.blue,
      ],
      offsets: _offsets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DragTarget<int>(
          onMove: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset offset = Offset(
              details.offset.dx / box.size.width,
              details.offset.dy / box.size.height,
            );
            setState(() {
              _offsets[details.data] = offset;
              _gradient = _gradient.copyWith(
                offsets: _offsets,
              );
            });
          },
          builder: (context, candidateData, rejectedData) => RepaintBoundary(
            child: AnimatedContainer(
              key: ValueKey(_gradient.hashCode),
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: _gradient,
              ),
            ),
          ),
        ),
        ..._offsets.mapIndexed(
          (i, e) => Align(
            alignment: FractionalOffset(e.dx, e.dy),
            child: Draggable<int>(
              data: i,
              childWhenDragging: const SizedBox.shrink(),
              feedback: const Handle(),
              child: const Handle(),
            ),
          ),
        ),
      ],
    );
  }
}

class Handle extends StatelessWidget {
  final Color color;
  const Handle({
    super.key,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
