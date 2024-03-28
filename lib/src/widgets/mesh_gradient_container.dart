import 'package:color_mesh/color_mesh.dart';
import 'package:color_mesh/src/widgets/shader_loader.dart';
import 'package:flutter/material.dart';

/// A container that uses [gradient] as a decoration.
///
/// This widget calls [MeshGradient.precacheShader] if the shader is not
/// loaded.
class MeshGradientContainer extends StatelessWidget {
  final MeshGradient gradient;
  final Widget? child;

  const MeshGradientContainer({
    super.key,
    required this.gradient,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderLoader(
      builder: (context, init) => Container(
        decoration: BoxDecoration(
          gradient: init ? gradient : null,
        ),
        child: child,
      ),
    );
  }
}
