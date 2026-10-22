import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pixel-art UI kit in a medieval fantasy style (gold frames, ruby gems,
/// dark stone). Everything is painted on a coarse pixel grid so it stays
/// crisp at any size.

const String pixelFontFamily = 'PixelifySans';

class PixelPalette {
  static const Color outline = Color(0xFF1E0806);
  static const Color goldLight = Color(0xFFFFE38A);
  static const Color gold = Color(0xFFE2A82C);
  static const Color goldDark = Color(0xFF9C5C12);
  static const Color goldText = Color(0xFFFFE7A3);
  static const Color rubyLight = Color(0xFFF0414A);
  static const Color ruby = Color(0xFFC81E2B);
  static const Color rubyDark = Color(0xFF8C0F1D);
  static const Color stoneLight = Color(0xFF4A4038);
  static const Color stone = Color(0xFF332A24);
  static const Color stoneDark = Color(0xFF1F1916);
  static const Color greyLight = Color(0xFF8A8580);
  static const Color grey = Color(0xFF5E5954);
  static const Color greyDark = Color(0xFF3B3835);
  static const Color emeraldLight = Color(0xFF4FD07A);
  static const Color emerald = Color(0xFF1F8F48);
  static const Color emeraldDark = Color(0xFF0F5A2C);
}

/// Fill of a pixel frame: three stepped bands (light top, base, dark bottom).
class PixelFill {
  const PixelFill(this.light, this.base, this.dark);

  final Color light;
  final Color base;
  final Color dark;

  static const PixelFill ruby =
      PixelFill(PixelPalette.rubyLight, PixelPalette.ruby, PixelPalette.rubyDark);
  static const PixelFill stone =
      PixelFill(PixelPalette.stoneLight, PixelPalette.stone, PixelPalette.stoneDark);
  static const PixelFill grey =
      PixelFill(PixelPalette.greyLight, PixelPalette.grey, PixelPalette.greyDark);
  static const PixelFill emerald = PixelFill(
      PixelPalette.emeraldLight, PixelPalette.emerald, PixelPalette.emeraldDark);
}

/// Gold text with a dark pixel outline, using the pixel font.
TextStyle pixelTextStyle({
  double fontSize = 18,
  Color color = PixelPalette.goldText,
  FontWeight fontWeight = FontWeight.w700,
  Color outlineColor = PixelPalette.outline,
}) {
  final o = math.max(1.5, fontSize / 12);
  return TextStyle(
    fontFamily: pixelFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.1,
    shadows: [
      for (final offset in <Offset>[
        Offset(-o, 0), Offset(o, 0), Offset(0, -o), Offset(0, o),
        Offset(-o, -o), Offset(o, -o), Offset(-o, o), Offset(o, o),
      ])
        Shadow(color: outlineColor, offset: offset),
      Shadow(color: outlineColor.withOpacity(0.6), offset: Offset(0, o * 2)),
    ],
  );
}

Paint _solid(Color color) => Paint()
  ..color = color
  ..isAntiAlias = false;

/// Gold-rimmed pixel frame with notched corners and optional gem ornaments.
class PixelFramePainter extends CustomPainter {
  const PixelFramePainter({
    required this.fill,
    this.pixel = 3,
    this.gems = false,
    this.highlighted = false,
    this.rimLight = PixelPalette.goldLight,
    this.rim = PixelPalette.gold,
    this.rimDark = PixelPalette.goldDark,
  });

  final PixelFill fill;
  final double pixel;
  final bool gems;
  final bool highlighted;
  final Color rimLight;
  final Color rim;
  final Color rimDark;

  // Gems stick out on the left and right, so the frame body is inset.
  double get gemInset => gems ? pixel * 4 : 0;

  @override
  void paint(Canvas canvas, Size size) {
    final p = pixel;
    final left = gemInset;
    final right = size.width - gemInset;
    final body = Rect.fromLTRB(left, 0, right, size.height);
    if (body.width <= p * 8 || body.height <= p * 8) return;

    void notched(Rect r, double notch, Color color) {
      // Rectangle with stepped (pixel) corners.
      final paint = _solid(color);
      canvas.drawRect(Rect.fromLTRB(r.left + notch, r.top, r.right - notch, r.bottom), paint);
      canvas.drawRect(Rect.fromLTRB(r.left, r.top + notch, r.right, r.bottom - notch), paint);
      if (notch >= 2 * p) {
        canvas.drawRect(
            Rect.fromLTRB(r.left + p, r.top + p, r.right - p, r.bottom - p), paint);
      }
    }

    if (highlighted) {
      notched(body.inflate(p * 2), p * 3, PixelPalette.goldLight.withOpacity(0.35));
    }
    notched(body, p * 2, PixelPalette.outline);
    final rimRect = body.deflate(p);
    notched(rimRect, p * 2, rimDark);
    // light top/left edge, base gold, dark bottom/right edge
    notched(Rect.fromLTRB(rimRect.left, rimRect.top, rimRect.right - p, rimRect.bottom - p),
        p * 2, rimLight);
    notched(rimRect.deflate(p), p, rim);
    final inner = rimRect.deflate(p * 2);
    canvas.drawRect(inner, _solid(PixelPalette.outline));
    final fillRect = inner.deflate(p);
    final h = fillRect.height;
    // Shading bands are proportional on buttons but capped on big panels.
    final top = math.min((h * 0.22 / p).round(), 4) * p;
    final bottom = math.min((h * 0.28 / p).round(), 5) * p;
    canvas.drawRect(fillRect, _solid(fill.base));
    canvas.drawRect(
        Rect.fromLTRB(fillRect.left, fillRect.top, fillRect.right, fillRect.top + top),
        _solid(fill.light));
    canvas.drawRect(
        Rect.fromLTRB(fillRect.left, fillRect.bottom - bottom, fillRect.right, fillRect.bottom),
        _solid(fill.dark));
    // small glint in the top-left corner of the fill
    final glint = _solid(Colors.white.withOpacity(0.35));
    canvas.drawRect(
        Rect.fromLTWH(fillRect.left + p, fillRect.top + p, p * 3, p), glint);
    canvas.drawRect(Rect.fromLTWH(fillRect.left + p, fillRect.top + p * 2, p, p), glint);
    // gold studs along the top and bottom rim
    final studs = ((rimRect.width - p * 12) / (p * 22)).floor();
    for (var i = 1; i <= studs; i++) {
      final x = rimRect.left + p * 6 + (rimRect.width - p * 12) * i / (studs + 1);
      final sx = (x / p).floor() * p;
      canvas.drawRect(Rect.fromLTWH(sx, rimRect.top, p * 2, p), _solid(rimLight));
      canvas.drawRect(Rect.fromLTWH(sx, rimRect.bottom - p, p * 2, p), _solid(rimLight));
    }
    if (gems) {
      _paintGem(canvas, Offset(left, size.height / 2));
      _paintGem(canvas, Offset(right, size.height / 2));
    }
  }

  void _paintGem(Canvas canvas, Offset center) {
    final p = pixel;
    // Diamond: gold setting with a ruby core, drawn as stacked rows.
    const radius = 5;
    for (var row = -radius; row <= radius; row++) {
      final half = radius - row.abs();
      final y = center.dy - p / 2 + row * p;
      canvas.drawRect(
          Rect.fromLTWH(center.dx - (half + 1) * p, y, (half * 2 + 2) * p, p),
          _solid(PixelPalette.outline));
      if (half > 0) {
        canvas.drawRect(Rect.fromLTWH(center.dx - half * p, y, half * 2 * p, p),
            _solid(row < 0 ? rimLight : rim));
      }
      final coreHalf = half - 2;
      if (coreHalf > 0) {
        canvas.drawRect(
            Rect.fromLTWH(center.dx - coreHalf * p, y, coreHalf * 2 * p, p),
            _solid(row < 0 ? PixelPalette.rubyLight : PixelPalette.ruby));
      }
    }
    canvas.drawRect(Rect.fromLTWH(center.dx - p, center.dy - p * 2.5, p, p),
        _solid(Colors.white.withOpacity(0.8)));
  }

  @override
  bool shouldRepaint(covariant PixelFramePainter old) =>
      old.fill != fill ||
      old.pixel != pixel ||
      old.gems != gems ||
      old.highlighted != highlighted;
}

/// A framed panel; the child sits inside the gold rim.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.fill = PixelFill.stone,
    this.pixel = 3,
    this.padding = const EdgeInsets.all(14),
    this.highlighted = false,
  });

  final Widget child;
  final PixelFill fill;
  final double pixel;
  final EdgeInsets padding;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PixelFramePainter(fill: fill, pixel: pixel, highlighted: highlighted),
      child: Padding(
        padding: padding + EdgeInsets.all(pixel * 4),
        child: child,
      ),
    );
  }
}

/// Ruby-and-gold button like the "Play!" banner; grey when disabled.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fill = PixelFill.ruby,
    this.fontSize = 22,
    this.height = 56,
    this.pixel = 3,
    this.gems = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final PixelFill fill;
  final double fontSize;
  final double height;
  final double pixel;
  final bool gems;
  final IconData? icon;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final fill = enabled
        ? (_pressed
            ? PixelFill(widget.fill.base, widget.fill.dark, widget.fill.dark)
            : widget.fill)
        : PixelFill.grey;
    final textColor = enabled ? PixelPalette.goldText : const Color(0xFFCFC9C2);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: SizedBox(
          height: widget.height,
          child: CustomPaint(
            painter: PixelFramePainter(
              fill: fill,
              pixel: widget.pixel,
              gems: widget.gems,
              rimLight: enabled ? PixelPalette.goldLight : PixelPalette.greyLight,
              rim: enabled ? PixelPalette.gold : PixelPalette.grey,
              rimDark: enabled ? PixelPalette.goldDark : PixelPalette.greyDark,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                widget.pixel * (widget.gems ? 12 : 6),
                _pressed ? widget.pixel : 0,
                widget.pixel * (widget.gems ? 12 : 6),
                _pressed ? 0 : widget.pixel,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor, size: widget.fontSize),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.label,
                        style: pixelTextStyle(fontSize: widget.fontSize, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Heraldic pixel shield used as a level badge.
class PixelShieldPainter extends CustomPainter {
  const PixelShieldPainter({
    required this.fill,
    this.selected = false,
    this.dimmed = false,
  });

  final PixelFill fill;
  final bool selected;
  final bool dimmed;

  static const int columns = 16;
  static const int rows = 19;

  // Half width (in pixels) of each shield row: straight sides, pointed bottom.
  static double _halfWidth(int row) {
    if (row < 1) return 6;
    if (row < 10) return 8;
    final t = (row - 9) / (rows - 9);
    return math.max(0.0, 8 * (1 - math.pow(t, 1.25).toDouble()));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = math.min(size.width / (columns + 4), size.height / (rows + 4));
    final cx = size.width / 2;
    final top = (size.height - rows * p) / 2;

    void layer(int inset, Color Function(int row, double half) color) {
      for (var row = inset; row < rows - inset; row++) {
        final half = (_halfWidth(row) - inset).floorToDouble();
        if (half <= 0) continue;
        canvas.drawRect(
            Rect.fromLTWH(cx - half * p, top + row * p, half * 2 * p, p + 0.5),
            _solid(color(row, half)));
      }
    }

    if (selected) {
      // pulsing-free glow ring around the selected shield
      for (var row = -2; row < rows + 1; row++) {
        final half = _halfWidth(row.clamp(0, rows - 1).toInt()) + 2;
        canvas.drawRect(
            Rect.fromLTWH(cx - half * p, top + row * p, half * 2 * p, p + 0.5),
            _solid(PixelPalette.goldLight.withOpacity(0.35)));
      }
    }
    // outline grows the shape by one pixel around
    for (var row = -1; row <= rows; row++) {
      final half = _halfWidth(row.clamp(0, rows - 1).toInt()) + 1;
      canvas.drawRect(
          Rect.fromLTWH(cx - half * p, top + row * p, half * 2 * p, p + 0.5),
          _solid(PixelPalette.outline));
    }
    final rimLight = dimmed ? PixelPalette.greyLight : PixelPalette.goldLight;
    final rim = dimmed ? PixelPalette.grey : PixelPalette.gold;
    final rimDark = dimmed ? PixelPalette.greyDark : PixelPalette.goldDark;
    layer(0, (row, _) => row < rows / 2 ? rimLight : rimDark);
    layer(1, (_, __) => rim);
    layer(2, (_, __) => PixelPalette.outline);
    layer(3, (row, _) {
      if (row < 6) return fill.light;
      if (row < 12) return fill.base;
      return fill.dark;
    });
    // heraldic cross line and a glint
    canvas.drawRect(Rect.fromLTWH(cx - p * 5, top + p * 4, p * 2, p),
        _solid(Colors.white.withOpacity(0.35)));
    canvas.drawRect(Rect.fromLTWH(cx - p * 5, top + p * 5, p, p),
        _solid(Colors.white.withOpacity(0.35)));
  }

  @override
  bool shouldRepaint(covariant PixelShieldPainter old) =>
      old.fill != fill || old.selected != selected || old.dimmed != dimmed;
}

/// Dark castle-wall background with pixel bricks and a warm vignette.
class PixelStoneBackgroundPainter extends CustomPainter {
  const PixelStoneBackgroundPainter({this.pixel = 4});

  final double pixel;

  @override
  void paint(Canvas canvas, Size size) {
    final p = pixel;
    canvas.drawRect(Offset.zero & size, _solid(const Color(0xFF15100E)));
    final brickW = p * 16;
    final brickH = p * 7;
    final random = math.Random(7);
    final shades = <Color>[
      const Color(0xFF231B17),
      const Color(0xFF281F1A),
      const Color(0xFF2D231D),
      const Color(0xFF211915),
    ];
    for (var y = 0.0, row = 0; y < size.height; y += brickH, row++) {
      final offset = row.isOdd ? -brickW / 2 : 0.0;
      for (var x = offset; x < size.width; x += brickW) {
        final brick = Rect.fromLTWH(x + p, y + p, brickW - p, brickH - p);
        canvas.drawRect(brick, _solid(shades[random.nextInt(shades.length)]));
        // top highlight and a few chipped pixels
        canvas.drawRect(Rect.fromLTWH(brick.left, brick.top, brick.width, p),
            _solid(const Color(0xFF3A2E26)));
        if (random.nextDouble() < 0.4) {
          canvas.drawRect(
              Rect.fromLTWH(brick.left + p * (2 + random.nextInt(10)),
                  brick.top + p * (2 + random.nextInt(3)), p, p),
              _solid(const Color(0xFF1A1310)));
        }
      }
    }
    // warm torch light from the top and dark edges
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.1,
          colors: [
            const Color(0xFFFFA040).withOpacity(0.10),
            Colors.transparent,
            Colors.black.withOpacity(0.65),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant PixelStoneBackgroundPainter old) => old.pixel != pixel;
}

/// Full-screen stone wall behind a menu.
class PixelMenuBackground extends StatelessWidget {
  const PixelMenuBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const PixelStoneBackgroundPainter(),
      child: child,
    );
  }
}

/// Ruby banner with a gold title, used as a screen heading.
class PixelTitleBanner extends StatelessWidget {
  const PixelTitleBanner({super.key, required this.title, this.subtitle, this.fontSize = 26});

  final String title;
  final String? subtitle;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const PixelFramePainter(fill: PixelFill.ruby, pixel: 3, gems: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 12, 48, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center, style: pixelTextStyle(fontSize: fontSize)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: pixelTextStyle(
                  fontSize: fontSize * 0.55,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF6D9C0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Cluster of glowing pixel crystals (three shards) for menu decoration.
class PixelCrystalPainter extends CustomPainter {
  const PixelCrystalPainter({this.mirrored = false});

  final bool mirrored;

  static const Color _light = Color(0xFFE6C4FF);
  static const Color _mid = Color(0xFFA35BFF);
  static const Color _dark = Color(0xFF5B2A9E);

  @override
  void paint(Canvas canvas, Size size) {
    final p = (size.height / 40).floorToDouble().clamp(2.0, 8.0).toDouble();
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    // soft magic glow behind the cluster
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.62),
      size.height * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          _mid.withOpacity(0.35),
          _mid.withOpacity(0.0),
        ]).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.62),
            radius: size.height * 0.5)),
    );
    final ground = (size.height / p).floor() - 1;
    final centerColumn = (size.width / p / 2).floor();
    // (column offset from centre, height in pixels, half width)
    _shard(canvas, p, centerColumn - 7, ground, 20, 3);
    _shard(canvas, p, centerColumn + 7, ground, 24, 3);
    _shard(canvas, p, centerColumn, ground, 34, 4);
  }

  void _shard(Canvas canvas, double p, int column, int ground, int height, int half) {
    final topRow = ground - height;
    for (var row = 0; row < height; row++) {
      // pointed tip, straight body
      final w = math.min(half, row ~/ 2 + 1);
      final y = (topRow + row) * p;
      canvas.drawRect(
          Rect.fromLTWH((column - w - 1) * p, y, (w * 2 + 2) * p, p), _solid(PixelPalette.outline));
      // left facet light, right facet dark, centre ridge mid
      canvas.drawRect(Rect.fromLTWH((column - w) * p, y, w * p, p), _solid(_light));
      canvas.drawRect(Rect.fromLTWH(column * p, y, w * p, p), _solid(_dark));
      canvas.drawRect(Rect.fromLTWH((column - 1) * p, y, p, p), _solid(_mid));
    }
    canvas.drawRect(Rect.fromLTWH((column - half - 1) * p, (ground) * p, (half * 2 + 2) * p, p),
        _solid(PixelPalette.outline));
    // sparkle near the tip
    canvas.drawRect(Rect.fromLTWH((column - 2) * p, (topRow + 4) * p, p, p),
        _solid(Colors.white.withOpacity(0.9)));
  }

  @override
  bool shouldRepaint(covariant PixelCrystalPainter old) => old.mirrored != mirrored;
}

/// Gold ornament line with a ruby diamond in the middle.
class PixelOrnamentPainter extends CustomPainter {
  const PixelOrnamentPainter({this.pixel = 3});

  final double pixel;

  @override
  void paint(Canvas canvas, Size size) {
    final p = pixel;
    final cy = (size.height / 2 / p).floor() * p;
    final cx = (size.width / 2 / p).floor() * p;
    canvas.drawRect(Rect.fromLTWH(0, cy - p, size.width, p * 3), _solid(PixelPalette.outline));
    canvas.drawRect(Rect.fromLTWH(p, cy, size.width - p * 2, p), _solid(PixelPalette.gold));
    for (var row = -4; row <= 4; row++) {
      final half = 4 - row.abs();
      final y = cy + row * p;
      canvas.drawRect(Rect.fromLTWH(cx - (half + 1) * p, y, (half * 2 + 3) * p, p),
          _solid(PixelPalette.outline));
      if (half > 0) {
        canvas.drawRect(Rect.fromLTWH(cx - half * p, y, (half * 2 + 1) * p, p),
            _solid(row < 0 ? PixelPalette.goldLight : PixelPalette.gold));
      }
      if (half > 2) {
        canvas.drawRect(Rect.fromLTWH(cx - (half - 2) * p, y, ((half - 2) * 2 + 1) * p, p),
            _solid(row < 0 ? PixelPalette.rubyLight : PixelPalette.ruby));
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelOrnamentPainter old) => old.pixel != pixel;
}
