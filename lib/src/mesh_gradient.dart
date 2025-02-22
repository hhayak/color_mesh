// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:color_mesh/src/utils/shader_controller.dart';

/// [colors] are the [Color]s that will be used to create the gradient.
///
/// [offsets] are the [Offset]s where each color is placed. Offset(0, 0)
/// corresponds to the top left.
/// 
/// [strengths] are the weight of each color. Controls the prominence or 
/// intensity of each color in the gradient
/// 
/// [sigmas] are the spread of each color. Controls the spread range of each color.
/// 
/// [MeshGradient.precacheShader] must be called before using this gradient.
/// If not, the gradient will be transparent.
class MeshGradient extends Gradient {
  final List<Offset> offsets;
  final List<double> strengths;
  final List<double> sigmas;

  static ui.FragmentProgram? _cachedFragmentProgram;

  static const _assetKey = 'packages/color_mesh/shaders/mesh_gradient.frag';

  static const _shaderMaxPoints = 8;

  const MeshGradient({
    required super.colors,
    required this.offsets,
    required this.strengths,
    required this.sigmas,
  })  : assert(colors.length <= _shaderMaxPoints),
        assert(offsets.length == colors.length),
        assert(strengths.length == colors.length),
        assert(sigmas.length == colors.length);

  static bool get initialised => _cachedFragmentProgram != null;

  static Future<ui.FragmentProgram?> precacheShader() async {
    if (_cachedFragmentProgram != null) {
      return _cachedFragmentProgram;
    }

    try {
      _cachedFragmentProgram = await ui.FragmentProgram.fromAsset(_assetKey);
      return _cachedFragmentProgram;
    } on Exception catch (e) {
      dev.log(
        'Error while loading fragment program $_assetKey',
        error: e,
        stackTrace: StackTrace.current,
        name: (MeshGradient).toString(),
      );
      return null;
    }
  }

  @override
  Shader createShader(
    Rect rect, {
    TextDirection? textDirection,
    ui.FragmentProgram? fragmentOverride,
  }) {
    final fragmentProgram = fragmentOverride ?? _cachedFragmentProgram;

    assert(fragmentProgram != null);

    if (fragmentProgram == null) {
      const transparentGradient = LinearGradient(
        colors: [Colors.transparent, Colors.transparent],
      );
      return transparentGradient.createShader(rect);
    }

    final controller = ShaderController(fragmentProgram);

    final size = rect.size;

    // Set iResolution
    controller.setVec2(size.width, size.height);

    // Set numPoints
    final int numPoints = colors.length;
    controller.setFloat(numPoints.toDouble());

    // Pre-pad lists to _shaderMaxPoints with default values
    final paddedOffsets = [
      ...offsets,
      ...List.filled(_shaderMaxPoints - offsets.length, Offset.zero)
    ];

    final paddedColors = [
      ...colors,
      ...List.filled(_shaderMaxPoints - colors.length, Colors.transparent)
    ];

    final paddedStrengths = [
      ...strengths,
      ...List.filled(_shaderMaxPoints - strengths.length, 1.0)
    ];

    final paddedSigmas = [
      ...sigmas,
      ...List.filled(_shaderMaxPoints - sigmas.length, 0.1)
    ];

    for (int i = 0; i < _shaderMaxPoints; i++) {
      controller.setVec2(paddedOffsets[i].dx, paddedOffsets[i].dy);
    }

    for (int i = 0; i < _shaderMaxPoints; i++) {
      controller.setVec4(
        paddedColors[i].r,
        paddedColors[i].g,
        paddedColors[i].b,
        paddedColors[i].a,
      );
    }

    for (int i = 0; i < _shaderMaxPoints; i++) {
      controller.setFloat(paddedStrengths[i]);
    }

    for (int i = 0; i < _shaderMaxPoints; i++) {
      controller.setFloat(paddedSigmas[i]);
    }

    return controller.shader;
  }

  @override
  MeshGradient scale(double factor) {
    return copyWith(
      colors: colors.map((color) => Color.lerp(null, color, factor)!).toList(),
    );
  }

  @override
  Gradient? lerpFrom(Gradient? a, double t) {
    if (a == null || (a is MeshGradient)) {
      return MeshGradient.lerp(a as MeshGradient?, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  Gradient? lerpTo(Gradient? b, double t) {
    if (b == null || (b is MeshGradient)) {
      return MeshGradient.lerp(this, b as MeshGradient?, t);
    }
    return super.lerpTo(b, t);
  }

  static MeshGradient? lerp(MeshGradient? a, MeshGradient? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }

    final colors = <Color>[];
    final offsets = <Offset>[];
    final strengths = <double>[];
    final sigmas = <double>[];

    for (int i = 0; i < a.colors.length; i++) {
      colors.add(Color.lerp(
          a.colors.elementAtOrNull(i), b.colors.elementAtOrNull(i), t)!);
      offsets.add(Offset.lerp(
          a.offsets.elementAtOrNull(i), b.offsets.elementAtOrNull(i), t)!);
      strengths.add(ui.lerpDouble(
          a.strengths.elementAtOrNull(i), b.strengths.elementAtOrNull(i), t)!);
      sigmas.add(ui.lerpDouble(
          a.sigmas.elementAtOrNull(i), b.sigmas.elementAtOrNull(i), t)!);
    }

    return MeshGradient(
      colors: colors,
      offsets: offsets,
      strengths: strengths,
      sigmas: sigmas,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MeshGradient &&
        other.transform == transform &&
        listEquals<Color>(other.colors, colors) &&
        listEquals<Offset>(other.offsets, offsets) &&
        listEquals<double>(other.strengths, strengths) &&
        listEquals<double>(other.sigmas, sigmas);
  }

  @override
  int get hashCode => Object.hash(
        transform,
        Object.hashAll(colors),
        Object.hashAll(offsets),
        Object.hashAll(strengths),
        Object.hashAll(sigmas),
      );

  @override
  String toString() {
    final List<String> description = <String>[
      'colors: $colors',
      'offset: $offsets',
      'strengths: $strengths',
      'sigmas: $sigmas',
      if (transform != null) 'transform: $transform',
    ];

    return '${objectRuntimeType(this, 'MeshGradient')}(${description.join(', ')})';
  }

  MeshGradient copyWith({
    List<Color>? colors,
    List<Offset>? offsets,
    List<double>? strengths,
    List<double>? sigmas,
  }) {
    return MeshGradient(
      colors: colors ?? this.colors,
      offsets: offsets ?? this.offsets,
      strengths: strengths ?? this.strengths,
      sigmas: sigmas ?? this.sigmas,
    );
  }

  @override
  Gradient withOpacity(double opacity) {
    return copyWith(
      colors: <Color>[
        for (final Color color in colors) color.withValues(alpha: opacity)
      ],
    );
  }
}
