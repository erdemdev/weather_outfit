// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

/// Basit PNG encoder — 1024x1024 uygulama ikonu oluşturur
void main() {
  const size = 1024;
  final pixels = Uint8List(size * size * 4);

  // Gradient arka plan: #1A3A4A -> #2C6E8A -> #3A8FA8
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final i = (y * size + x) * 4;
      final t = y / size;
      final tx = x / size;
      // Köşegen gradient
      final d = (t * 0.7 + tx * 0.3);
      
      int r, g, b;
      if (d < 0.5) {
        final f = d / 0.5;
        r = _lerp(0x1A, 0x2C, f);
        g = _lerp(0x3A, 0x6E, f);
        b = _lerp(0x4A, 0x8A, f);
      } else {
        final f = (d - 0.5) / 0.5;
        r = _lerp(0x2C, 0x3A, f);
        g = _lerp(0x6E, 0x8F, f);
        b = _lerp(0x8A, 0xA8, f);
      }

      pixels[i] = r;
      pixels[i + 1] = g;
      pixels[i + 2] = b;
      pixels[i + 3] = 255;
    }
  }

  // Yuvarlatılmış beyaz iç çerçeve (subtle glow)
  _drawCircleFilled(pixels, size, size ~/ 2, size ~/ 2, (size * 0.38).round(), 255, 255, 255, 18);

  // Güneş - sağ üst
  final sunX = (size * 0.65).round();
  final sunY = (size * 0.28).round();
  final sunR = (size * 0.1).round();
  _drawCircleFilled(pixels, size, sunX, sunY, sunR + 15, 255, 220, 100, 40);
  _drawCircleFilled(pixels, size, sunX, sunY, sunR, 255, 210, 70, 220);
  
  // Güneş ışınları
  for (int angle = 0; angle < 360; angle += 45) {
    final rad = angle * pi / 180;
    final x1 = sunX + (sunR * 1.3 * cos(rad)).round();
    final y1 = sunY + (sunR * 1.3 * sin(rad)).round();
    final x2 = sunX + (sunR * 1.7 * cos(rad)).round();
    final y2 = sunY + (sunR * 1.7 * sin(rad)).round();
    _drawLine(pixels, size, x1, y1, x2, y2, 255, 210, 70, 160, 4);
  }

  // Bulut - sol üst
  final cloudX = (size * 0.35).round();
  final cloudY = (size * 0.32).round();
  _drawCloud(pixels, size, cloudX, cloudY, (size * 0.12).round());

  // Askı (hanger) - alt kısım, kıyafet sembolü
  final hangerCX = (size * 0.5).round();
  final hangerCY = (size * 0.6).round();
  final hangerSize = (size * 0.18).round();
  
  // Askı üçgeni
  _drawLine(pixels, size, hangerCX, hangerCY - hangerSize, hangerCX - hangerSize, hangerCY + (hangerSize * 0.5).round(), 255, 255, 255, 220, 7);
  _drawLine(pixels, size, hangerCX, hangerCY - hangerSize, hangerCX + hangerSize, hangerCY + (hangerSize * 0.5).round(), 255, 255, 255, 220, 7);
  _drawLine(pixels, size, hangerCX - hangerSize, hangerCY + (hangerSize * 0.5).round(), hangerCX + hangerSize, hangerCY + (hangerSize * 0.5).round(), 255, 255, 255, 220, 7);

  // Askı kancası (üstteki çengel)
  _drawCircleOutline(pixels, size, hangerCX, hangerCY - hangerSize - (size * 0.03).round(), (size * 0.035).round(), 255, 255, 255, 210, 5);

  // T-shirt şekli (basit) - askının altında
  final shirtY = hangerCY + (hangerSize * 0.5).round();
  final shirtW = (hangerSize * 1.2).round();
  final shirtH = (hangerSize * 1.0).round();
  // Gövde
  _drawRectFilled(pixels, size, hangerCX - shirtW ~/ 2, shirtY, shirtW, shirtH, 255, 255, 255, 50);
  // Gövde kenar çizgisi
  _drawLine(pixels, size, hangerCX - shirtW ~/ 2, shirtY, hangerCX - shirtW ~/ 2, shirtY + shirtH, 255, 255, 255, 180, 5);
  _drawLine(pixels, size, hangerCX + shirtW ~/ 2, shirtY, hangerCX + shirtW ~/ 2, shirtY + shirtH, 255, 255, 255, 180, 5);
  _drawLine(pixels, size, hangerCX - shirtW ~/ 2, shirtY + shirtH, hangerCX + shirtW ~/ 2, shirtY + shirtH, 255, 255, 255, 180, 5);

  // Yağmur damlası - sağ alt (küçük)
  final dropX = (size * 0.72).round();
  final dropY = (size * 0.68).round();
  final dropSize = (size * 0.03).round();
  _drawCircleFilled(pixels, size, dropX, dropY, dropSize, 150, 210, 255, 180);
  _drawCircleFilled(pixels, size, dropX, dropY - dropSize, (dropSize * 0.6).round(), 150, 210, 255, 180);

  // PNG kaydet
  final png = _encodePNG(pixels, size, size);
  final file = File('assets/app_icon.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(png);
  print('✅ İkon oluşturuldu: assets/app_icon.png ($size x $size)');
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

void _drawCircleFilled(Uint8List px, int w, int cx, int cy, int r, int red, int green, int blue, int alpha) {
  for (int dy = -r; dy <= r; dy++) {
    for (int dx = -r; dx <= r; dx++) {
      if (dx * dx + dy * dy <= r * r) {
        final x = cx + dx;
        final y = cy + dy;
        if (x >= 0 && x < w && y >= 0 && y < w) {
          final i = (y * w + x) * 4;
          _blend(px, i, red, green, blue, alpha);
        }
      }
    }
  }
}

void _drawCircleOutline(Uint8List px, int w, int cx, int cy, int r, int red, int green, int blue, int alpha, int thick) {
  for (int dy = -r - thick; dy <= r + thick; dy++) {
    for (int dx = -r - thick; dx <= r + thick; dx++) {
      final dist = sqrt(dx * dx + dy * dy);
      if (dist >= r - thick / 2 && dist <= r + thick / 2) {
        final x = cx + dx;
        final y = cy + dy;
        if (x >= 0 && x < w && y >= 0 && y < w) {
          final i = (y * w + x) * 4;
          _blend(px, i, red, green, blue, alpha);
        }
      }
    }
  }
}

void _drawLine(Uint8List px, int w, int x0, int y0, int x1, int y1, int r, int g, int b, int a, int thick) {
  final dx = (x1 - x0).abs();
  final dy = (y1 - y0).abs();
  final steps = dx > dy ? dx : dy;
  if (steps == 0) return;
  final xi = (x1 - x0) / steps;
  final yi = (y1 - y0) / steps;
  double px2 = x0.toDouble(), py = y0.toDouble();
  for (int s = 0; s <= steps; s++) {
    for (int t = -thick ~/ 2; t <= thick ~/ 2; t++) {
      for (int t2 = -thick ~/ 2; t2 <= thick ~/ 2; t2++) {
        final fx = px2.round() + t;
        final fy = py.round() + t2;
        if (fx >= 0 && fx < w && fy >= 0 && fy < w) {
          final i = (fy * w + fx) * 4;
          _blend(px, i, r, g, b, a);
        }
      }
    }
    px2 += xi;
    py += yi;
  }
}

void _drawRectFilled(Uint8List px, int w, int rx, int ry, int rw, int rh, int r, int g, int b, int a) {
  for (int dy = 0; dy < rh; dy++) {
    for (int dx = 0; dx < rw; dx++) {
      final x = rx + dx;
      final y = ry + dy;
      if (x >= 0 && x < w && y >= 0 && y < w) {
        final i = (y * w + x) * 4;
        _blend(px, i, r, g, b, a);
      }
    }
  }
}

void _drawCloud(Uint8List px, int w, int cx, int cy, int r) {
  _drawCircleFilled(px, w, cx - (r * 0.6).round(), cy, (r * 0.7).round(), 255, 255, 255, 200);
  _drawCircleFilled(px, w, cx, cy - (r * 0.3).round(), (r * 0.85).round(), 255, 255, 255, 210);
  _drawCircleFilled(px, w, cx + (r * 0.6).round(), cy, (r * 0.65).round(), 255, 255, 255, 190);
  _drawCircleFilled(px, w, cx, cy + (r * 0.15).round(), (r * 0.9).round(), 255, 255, 255, 180);
}

void _blend(Uint8List px, int i, int r, int g, int b, int a) {
  final sa = a / 255.0;
  final da = 1.0 - sa;
  px[i] = (px[i] * da + r * sa).round().clamp(0, 255);
  px[i + 1] = (px[i + 1] * da + g * sa).round().clamp(0, 255);
  px[i + 2] = (px[i + 2] * da + b * sa).round().clamp(0, 255);
  px[i + 3] = 255;
}

// Minimal PNG encoder
Uint8List _encodePNG(Uint8List rgba, int w, int h) {
  final raw = BytesBuilder();
  for (int y = 0; y < h; y++) {
    raw.addByte(0); // filter none
    raw.add(rgba.sublist(y * w * 4, (y + 1) * w * 4));
  }
  final rawBytes = raw.toBytes();
  final compressed = zlib.encode(rawBytes);

  final out = BytesBuilder();
  // PNG signature
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);
  // IHDR
  _writeChunk(out, 'IHDR', _ihdr(w, h));
  // IDAT
  _writeChunk(out, 'IDAT', compressed);
  // IEND
  _writeChunk(out, 'IEND', []);
  return out.toBytes();
}

Uint8List _ihdr(int w, int h) {
  final d = ByteData(13);
  d.setUint32(0, w);
  d.setUint32(4, h);
  d.setUint8(8, 8); // bit depth
  d.setUint8(9, 6); // RGBA
  d.setUint8(10, 0);
  d.setUint8(11, 0);
  d.setUint8(12, 0);
  return d.buffer.asUint8List();
}

void _writeChunk(BytesBuilder out, String type, List<int> data) {
  final len = ByteData(4)..setUint32(0, data.length);
  out.add(len.buffer.asUint8List());
  final typeBytes = type.codeUnits;
  out.add(typeBytes);
  out.add(data);
  final crc = _crc32([...typeBytes, ...data]);
  final crcBytes = ByteData(4)..setUint32(0, crc);
  out.add(crcBytes.buffer.asUint8List());
}

int _crc32(List<int> data) {
  int crc = 0xFFFFFFFF;
  for (final b in data) {
    crc ^= b;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) == 1) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}

final zlib = ZLibCodec();
