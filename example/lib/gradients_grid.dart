import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';

class GradientsGrid extends StatelessWidget {
  GradientsGrid({super.key});

  final gradients = [
    MeshGradient(
      colors: const [
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    ),
    MeshGradient(
      colors: const [
        Color(0xFF0000FF),
        Color(0xFF00FFFF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    ),
    MeshGradient(
      colors: const [
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    ),
    MeshGradient(
      colors: const [
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: gradients.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => AnimatedMeshGradientContainer(
        gradient: gradients[index],
      ),
    );
  }
}
