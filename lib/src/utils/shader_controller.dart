import 'dart:ui';

class ShaderController {
  final FragmentProgram program;
  final FragmentShader shader;

  int _i = 0;

  ShaderController(this.program) : shader = program.fragmentShader();

  void setFloat(double value) {
    shader.setFloat(_i, value);
    _i++;
  }

  void setVec2(double x, double y) {
    setFloat(x);
    setFloat(y);
  }

  void setVec3(double x, double y, double z) {
    setFloat(x);
    setFloat(y);
    setFloat(z);
  }

  void setVec4(double x, double y, double z, double w) {
    setFloat(x);
    setFloat(y);
    setFloat(z);
    setFloat(w);
  }
}
