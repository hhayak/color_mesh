import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:color_mesh/color_mesh.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  final List<MeshColor> _meshColors = [
    const MeshColor(color: Colors.red, offset: Offset(0.2, 0)),
    const MeshColor(color: Colors.yellow, offset: Offset(0.8, 0)),
    const MeshColor(color: Colors.green, offset: Offset(0, 1)),
    const MeshColor(color: Colors.blue, offset: Offset(1, 1)),
    const MeshColor(color: Colors.deepPurple, offset: Offset(0.5, 0.5)),
    const MeshColor(color: Colors.orange, offset: Offset(0.8, 0.5)),
    const MeshColor(color: Colors.pink, offset: Offset(0.5, 0.4)),
    const MeshColor(color: Colors.teal, offset: Offset(0.22, 0.3)),
  ];

  int _selectedColorIndex = 0;

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _meshColors[_selectedColorIndex].color,
              onColorChanged: (color) {
                setState(() {
                  _meshColors[_selectedColorIndex] =
                      _meshColors[_selectedColorIndex].copyWith(color: color);
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  DragTarget<int>(
                    onMove: (details) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final Offset offset = Offset(
                        details.offset.dx / box.size.width,
                        details.offset.dy / box.size.height,
                      );

                      setState(() {
                        _meshColors[details.data] =
                            _meshColors[details.data].copyWith(
                          offset: offset,
                        );
                      });
                    },
                    builder: (context, candidateData, rejectedData) =>
                        RepaintBoundary(
                      child: AnimatedContainer(
                        alignment: Alignment.center,
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: MeshGradient(
                            colors: _meshColors.map((e) => e.color).toList(),
                            offsets: _meshColors.map((e) => e.offset).toList(),
                            strengths:
                                _meshColors.map((e) => e.strength).toList(),
                            sigmas: _meshColors.map((e) => e.sigma).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ..._meshColors.mapIndexed(
                    (i, e) => Align(
                      alignment: FractionalOffset(e.offset.dx, e.offset.dy),
                      child: Draggable<int>(
                        data: i,
                        childWhenDragging: const SizedBox.shrink(),
                        feedback: Handle(
                          color: _selectedColorIndex == i
                              ? Colors.white
                              : Colors.black,
                        ),
                        onDragStarted: () {
                          setState(() {
                            _selectedColorIndex = i;
                          });
                        },
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColorIndex = i;
                            });
                            _showColorPicker(context);
                          },
                          child: Handle(
                            color: _selectedColorIndex == i
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Weight'),
                      Expanded(
                        child: Slider(
                          value: _meshColors[_selectedColorIndex].strength,
                          min: 0,
                          max: 1,
                          onChanged: (value) {
                            setState(() {
                              _meshColors[_selectedColorIndex] =
                                  _meshColors[_selectedColorIndex]
                                      .copyWith(strength: value);
                            });
                          },
                          label: 'Strength',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Sigma'),
                      Expanded(
                        child: Slider(
                          value: _meshColors[_selectedColorIndex].sigma,
                          min: 0,
                          max: 1,
                          onChanged: (value) {
                            setState(() {
                              _meshColors[_selectedColorIndex] =
                                  _meshColors[_selectedColorIndex]
                                      .copyWith(sigma: value);
                            });
                          },
                          label: 'Sigma',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

class MeshColor {
  final Color color;
  final Offset offset;
  final double strength;
  final double sigma;

  const MeshColor({
    required this.color,
    required this.offset,
    this.strength = 1,
    this.sigma = 0.25,
  });

  MeshColor copyWith({
    Color? color,
    Offset? offset,
    double? strength,
    double? sigma,
  }) {
    return MeshColor(
      color: color ?? this.color,
      offset: offset ?? this.offset,
      strength: strength ?? this.strength,
      sigma: sigma ?? this.sigma,
    );
  }
}
