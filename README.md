<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Provides a mesh gradient that works similarly to `LinearGradient` and `RadialGradient`. You can use `MeshGradient` in decorations and animations.

> You can check a live preview in this blog [post](https://www.hamzahayak.dev/blog/color-mesh)!

* The color mesh is defined with 4 colors and 4 offsets.
* `Web` is supported in Flutter versions `< 3.19` - watching how this [issue](https://github.com/flutter/flutter/issues/144503) develops

## Features

* `MeshGradient` - a class that extends `Gradient` and aims to be used similarly to `RadialGradient` and `LinearGradient`.
    * You can choose 4 colors.
    * You can choose 4 offsets - where the colors are positioned.
    * It supports lerping, so you can animate it with `BoxDecoration` + `AnimatedContainer` for example.
* `MeshGradientContainer` - a simple Container with a MeshGradient decoration.
* `AnimatedMeshGradientContainer` - an animated container that shuffles the gradient colors periodically.

<figure>
    <img src="https://raw.githubusercontent.com/hhayak/color_mesh/main/screenshots/mesh.png" alt="MeshGradientContainer" width="200" height="200"/>
    <figcaption>MeshGradientContainer</figcaption>
</figure>

<figure>
    <img src="https://raw.githubusercontent.com/hhayak/color_mesh/main/screenshots/shuffle.gif" alt="AnimatedMeshGradientContainer" width="200" height="200"/>
    <figcaption>AnimatedMeshGradientContainer</figcaption>
</figure>

## Getting started

To use `MeshGradient`, you have to initialize the shader that powers it. Simply `await` for `MeshGradient.precacheShader()`
in your app startup, or through a `FutureBuilder` for example.

```dart
Future<void> main() async {
  await MeshGradient.precacheShader();
  runApp(const MyApp());
}
```

**Note:** `MeshGradientContainer` will load the shader on your behalf, if it wasn't done previously.

## Usage

> The 'Example' tab shows how to implement an animated mesh gradient.

An example using `MeshGradient` as part of the decoration for a `Container`.

```dart
Future<void> main() async {
  await MeshGradient.precacheShader();
  runApp(const MyApp());
}

// ... MyApp() ...

class MyMeshContainer extends StatelessWidget {
  const MyMeshContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: MeshGradient(
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
        ),
      ),
    );
  }
}
```

## Additional information

Any contribution is welcome! 

You can use the Github repository to report bugs by opening issues, or help implement new features by opening new pull requests. 

Thank you!
