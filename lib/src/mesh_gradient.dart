// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer' as dev;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:color_mesh/src/utils/shader_controller.dart';
import 'package:color_mesh/src/utils/utils.dart';

/// [colors] are the 4 [Color]s that will be used to create the gradient.
///
/// [offsets] are the 4 [Offset]s where each color is placed. Offset(0, 0)
/// corresponds to the top left.
///
/// [MeshGradient.precacheShader] must be called before using this gradient.
/// If not, the gradient will be transparent.
class MeshGradient extends Gradient {
  final List<Offset> offsets;

  static ui.FragmentProgram? _cachedFragmentProgram;

  static const _assetKey = 'packages/color_mesh/shaders/mesh_gradient.frag';

  const MeshGradient({
    required super.colors,
    this.offsets = const [
      Offset(0, 0),
      Offset(0, 1),
      Offset(1, 0),
      Offset(1, 1),
    ],
  }) : assert(colors.length == 4 && offsets.length == colors.length);

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

    final shaderController = ShaderController(fragmentProgram);
    final size = rect.size;
    final centeredOffsets = _centerOffsets(offsets);
    final colorSrc = [
      [-0.85, -0.9],
      [-0.95, 0.9],
      [0.85, -0.9],
      [0.95, 0.9],
    ];

    final (H, s2) = MathUtils.rbf(centeredOffsets, centeredOffsets, true);
    final w = MathUtils.linsolve(H, colorSrc);

    //uSize
    shaderController.setFloat(size.width);
    shaderController.setFloat(size.height);
    //colors
    for (Color color in colors) {
      shaderController.setVec3(
        color.r,
        color.g,
        color.b,
      );
    }
    //offsets
    for (Offset offset in centeredOffsets) {
      shaderController.setVec2(offset.dx, offset.dy);
    }
    // s2
    for (var s in s2) {
      shaderController.setFloat(s);
    }
    // w
    for (var weight in w) {
      shaderController.setVec2(weight[0], weight[1]);
    }

    return shaderController.shader;
  }

  List<Offset> _centerOffsets(List<Offset> offset) {
    return offsets.map((e) => Offset(e.dx * 2 - 1, e.dy * 2 - 1)).toList();
  }

  @override
  MeshGradient scale(double factor) {
    return MeshGradient(
      colors: colors.map((color) => Color.lerp(null, color, factor)!).toList(),
      offsets: offsets,
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
    final interpolated = _interpolateColorsAndOffsets(
      a.colors,
      a.offsets,
      b.colors,
      b.offsets,
      t,
    );
    return MeshGradient(
      colors: interpolated.$1,
      offsets: interpolated.$2,
    );
  }

  static (List<Color>, List<Offset>) _interpolateColorsAndOffsets(
    List<Color> aColors,
    List<Offset> aOffsets,
    List<Color> bColors,
    List<Offset> bOffsets,
    double t,
  ) {
    assert(aColors.length == 4);
    assert(bColors.length == aColors.length);
    assert(aOffsets.length == aColors.length);
    assert(bOffsets.length == aColors.length);
    final List<Color> interpolatedColors = <Color>[];
    final List<Offset> interpolatedOffsets = <Offset>[];
    for (int i = 0; i < aColors.length; i++) {
      interpolatedColors.add(Color.lerp(aColors[i], bColors[i], t)!);
      interpolatedOffsets.add(Offset.lerp(aOffsets[i], bOffsets[i], t)!);
    }
    return (interpolatedColors, interpolatedOffsets);
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
        listEquals<Offset>(other.offsets, offsets);
  }

  @override
  int get hashCode => Object.hash(
        transform,
        Object.hashAll(colors),
        Object.hashAll(offsets),
      );

  @override
  String toString() {
    final List<String> description = <String>[
      'colors: $colors',
      'offset: $offsets',
      if (transform != null) 'transform: $transform',
    ];

    return '${objectRuntimeType(this, 'MeshGradient')}(${description.join(', ')})';
  }

  MeshGradient copyWith({
    List<Color>? colors,
    List<Offset>? offsets,
  }) {
    return MeshGradient(
      colors: colors ?? this.colors,
      offsets: offsets ?? this.offsets,
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
