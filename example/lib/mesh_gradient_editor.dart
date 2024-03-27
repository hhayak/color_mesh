import 'dart:typed_data';

import 'package:color_mesh/color_mesh.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class MeshGradientEditor extends StatefulWidget {
  const MeshGradientEditor({super.key});

  @override
  State<MeshGradientEditor> createState() => _MeshGradientEditorState();
}

class _MeshGradientEditorState extends State<MeshGradientEditor> {
  final GlobalKey _meshKey = GlobalKey();
  List<MeshColor> colors = [
    MeshColor(
      color: Colors.red,
      offset: const Offset(0.1, 0.2),
    ),
    MeshColor(
      color: Colors.yellow,
      offset: const Offset(0.9, 0.1),
    ),
    MeshColor(
      color: Colors.blue,
      offset: const Offset(0.2, 0.8),
    ),
    MeshColor(
      color: Colors.green,
      offset: const Offset(0.9, 0.9),
    ),
  ];

  MeshColor? selected;

  void _updateOffset(DragUpdateDetails details, MeshColor color) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final Offset offset = Offset(
      localOffset.dx / box.size.width,
      localOffset.dy / box.size.height,
    );
    setState(() {
      color.offset = offset;
    });
  }

  void _onSelect(MeshColor currentColor) async {
    final Color newColor = await showColorPickerDialog(
      context,
      currentColor.color,
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 0,
      wheelDiameter: 165,
      enableOpacity: true,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
      },
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        copyButton: false,
        pasteButton: false,
        longPressMenu: false,
      ),
      actionButtons: const ColorPickerActionButtons(
        dialogActionIcons: false,
        dialogActionButtons: true,
      ),
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
    );

    setState(() {
      currentColor.color = newColor;
    });
  }

  Future<void> _capturePng() async {
    final RenderRepaintBoundary boundary =
        _meshKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    FileSaver.instance.saveFile(
      bytes: pngBytes,
      name: 'mesh_gradient_${DateTime.now().millisecondsSinceEpoch}',
      ext: 'png',
      mimeType: MimeType.png,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ColorsOffsetsRow(
          colors: colors,
          onSelect: _onSelect,
        ),
        FilledButton.icon(
          onPressed: _capturePng,
          icon: const Icon(Icons.download),
          label: const Text('Save'),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              RepaintBoundary(
                key: _meshKey,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: MeshGradient(
                      colors: colors.map((e) => e.color).toList(),
                      offsets: colors.map((e) => e.offset).toList(),
                    ),
                  ),
                ),
              ),
              ...colors.map(
                (e) => GestureDetector(
                  onPanUpdate: (details) => _updateOffset(details, e),
                  child: Align(
                    alignment: FractionalOffset(
                      e.offset.dx,
                      e.offset.dy,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: e == selected
                            ? Border.all(
                                color: Colors.black,
                              )
                            : null,
                      ),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorsOffsetsRow extends StatelessWidget {
  final List<MeshColor> colors;
  final void Function(MeshColor)? onSelect;
  const _ColorsOffsetsRow({
    required this.colors,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < colors.length; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: onSelect == null
                    ? null
                    : () {
                        onSelect!(colors[i]);
                      },
                child: _ColorOffsetBox(
                  color: colors[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorOffsetBox extends StatelessWidget {
  final MeshColor color;
  const _ColorOffsetBox({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ColorIndicator(
            height: 20,
            width: 40,
            color: color.color,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
              '${color.offset.dx.toStringAsPrecision(2)}, ${color.offset.dy.toStringAsPrecision(2)}'),
        ),
      ],
    );
  }
}

class MeshColor {
  Color color;
  Offset offset;

  MeshColor({
    required this.color,
    required this.offset,
  });
}
