import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:color_mesh/color_mesh.dart';

class ShaderLoader extends StatefulWidget {
  final Widget Function(BuildContext, bool) builder;

  const ShaderLoader({
    super.key,
    required this.builder,
  });

  @override
  State<ShaderLoader> createState() => _ShaderLoaderState();
}

class _ShaderLoaderState extends State<ShaderLoader> {
  Future<FragmentProgram?>? _future;

  @override
  void initState() {
    super.initState();
    if (!MeshGradient.initialised) {
      _future = MeshGradient.precacheShader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return widget.builder(context, MeshGradient.initialised);
      },
    );
  }
}
