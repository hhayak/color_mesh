import 'package:color_mesh/color_mesh.dart';
import 'package:example/gradients_grid.dart';
import 'package:example/mesh_gradient_editor.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MeshGradient.precacheShader();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String _title = 'Color Mesh Demo';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appinio Mesh Gradient Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Editor',
              ),
              Tab(
                text: 'Examples',
              )
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const MeshGradientEditor(),
            GradientsGrid(),
          ],
        ),
      ),
    );
  }
}
