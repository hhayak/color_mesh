import 'package:color_mesh/color_mesh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
