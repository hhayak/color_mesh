import 'dart:async';

import 'package:flutter/material.dart';

import 'package:color_mesh/color_mesh.dart';
import 'package:color_mesh/src/utils/utils.dart';
import 'package:color_mesh/src/widgets/shader_loader.dart';

/// A container that randomly shuffles the colors of the [gradient],
/// with a period of [duration].
///
/// This widget calls [MeshGradient.precacheShader] if the shader is not
/// loaded.
class AnimatedMeshGradientContainer extends StatefulWidget {
  final MeshGradient? gradient;
  final Duration duration;
  final Widget? child;

  const AnimatedMeshGradientContainer({
    super.key,
    this.gradient,
    this.duration = const Duration(seconds: 3),
    this.child,
  });

  @override
  State<AnimatedMeshGradientContainer> createState() =>
      _AnimatedMeshGradientContainerState();
}

class _AnimatedMeshGradientContainerState
    extends State<AnimatedMeshGradientContainer> {
  MeshGradient? _gradient;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _gradient = widget.gradient;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _shuffleGradient();
      _timer = Timer.periodic(widget.duration, (timer) {
        _shuffleGradient();
      });
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedMeshGradientContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gradient != widget.gradient) {
      _gradient = widget.gradient;
      _shuffleGradient();
    }
  }

  void _shuffleGradient() {
    setState(() {
      _gradient = _gradient?.shuffle();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderLoader(
      builder: (context, init) => AnimatedContainer(
        duration: widget.duration,
        decoration: init ? BoxDecoration(gradient: _gradient) : null,
        child: widget.child,
      ),
    );
  }
}
