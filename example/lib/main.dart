import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';

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
      home: const MeshGradientDemo(),
    );
  }
}

class MeshGradientDemo extends StatelessWidget {
  const MeshGradientDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshGradient Demo'),
      ),
      body: const MyAnimatedMeshGradient(),
    );
  }
}

class MyAnimatedMeshGradient extends StatefulWidget {
  const MyAnimatedMeshGradient({super.key});

  @override
  State<MyAnimatedMeshGradient> createState() => _MyAnimatedMeshGradientState();
}

class _MyAnimatedMeshGradientState extends State<MyAnimatedMeshGradient> {
  bool _changeGradient = false;

  final MeshGradient _firstGradient = MeshGradient(
    colors: const [
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.blue,
    ],
    offsets: const [
      Offset(0, 0), // topLeft
      Offset(0, 1), // topRight
      Offset(1, 0), // bottomLeft
      Offset(1, 1), // bottomRight
    ],
  );

  final MeshGradient _secondGradient = MeshGradient(
    colors: const [
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.blue,
    ],
    offsets: const [
      Offset(0.3, 0.1), // topLeft
      Offset(0, 0.8), // topRight
      Offset(0.8, 0.3), // bottomLeft
      Offset(1, 1), // bottomRight
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _changeGradient = !_changeGradient;
        });
      },
      child: AnimatedMeshGradientContainer(
        duration: const Duration(seconds: 3),
        gradient: _changeGradient ? _firstGradient : _secondGradient,
        child: const Center(
          child: Text('Tap to change gradients'),
        ),
      ),
    );
  }
}
