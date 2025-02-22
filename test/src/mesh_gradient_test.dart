import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$MeshGradient', () {
    const colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ];
    const offsets = [
      Offset(0, 0),
      Offset(1, 0),
      Offset(0, 1),
      Offset(1, 1),
    ];
    const strengths = [1.0, 1.0, 1.0, 1.0];
    const sigmas = [0.5, 0.5, 0.5, 0.5];

    test('should create MeshGradient', () {
      final gradient = MeshGradient(
        colors: colors,
        offsets: offsets,
        strengths: strengths,
        sigmas: sigmas,
      );
      expect(gradient, isNotNull);
    });

    test('should fail when colors and offsets length mismatch', () {
      expect(
          () => MeshGradient(
                colors: colors,
                offsets: offsets.sublist(0, 2),
                strengths: strengths,
                sigmas: sigmas,
              ),
          throwsAssertionError);
    });

    test('should fail when colors and strengths length mismatch', () {
      expect(
          () => MeshGradient(
                colors: colors,
                offsets: offsets,
                strengths: strengths.sublist(0, 2),
                sigmas: sigmas,
              ),
          throwsAssertionError);
    });

    test('should fail when colors and sigmas length mismatch', () {
      expect(
          () => MeshGradient(
                colors: colors,
                offsets: offsets,
                strengths: strengths,
                sigmas: sigmas.sublist(0, 2),
              ),
          throwsAssertionError);
    });

    test('should not create shader before fragment program precache', () {
      final gradient = MeshGradient(
        colors: colors,
        offsets: offsets,
        strengths: strengths,
        sigmas: sigmas,
      );
      expect(() {
        gradient.createShader(Rect.zero);
      }, throwsAssertionError);
    });

    test('should correctly lerp between two MeshGradients', () {
      final gradient = MeshGradient(
        colors: colors,
        offsets: offsets,
        strengths: strengths,
        sigmas: sigmas,
      );
      final target = MeshGradient(
        colors: colors.reversed.toList(),
        offsets: offsets.reversed.toList(),
        strengths: strengths.reversed.toList(),
        sigmas: sigmas.reversed.toList(),
      );
      const t = 0.7;

      final result = MeshGradient.lerp(gradient, target, t);

      expect(result, isNotNull);

      for (int i = 0; i < result!.colors.length; i++) {
        expect(
          result.colors[i],
          Color.lerp(gradient.colors[i], target.colors[i], t),
        );
        expect(
          result.offsets[i],
          Offset.lerp(gradient.offsets[i], target.offsets[i], t),
        );
      }
    });
  });

  testWidgets('mesh gradient ...', (tester) async {
    final MeshGradient gradient = MeshGradient(
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
      strengths: const [1.0, 1.0, 1.0, 1.0],
      sigmas: const [0.5, 0.5, 0.5, 0.5],
    );

    await tester.pumpWidget(Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
    ));
    await tester.pumpAndSettle();
    final excpetion = tester.binding.takeException();
    expect(excpetion, isAssertionError);
  });
}
