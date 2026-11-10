import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/movie.dart';

// Generated movie poster: gradient + a drawn picture that matches the genre,
// plus the title and year. If the movie has a posterUrl, that image is shown
// on top (the art stays underneath if the image cannot load).
// compact = just the first letter (for tiny thumbnails).
// showTitle = false -> picture only (used behind the Home banner text).
// heroTag = poster flies between screens (Hero animation).
class PosterBox extends StatelessWidget {
  final Movie movie;
  final String? heroTag;
  final bool compact;
  final bool showTitle;

  const PosterBox({
    super.key,
    required this.movie,
    this.heroTag,
    this.compact = false,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final art = _PosterArt(movie: movie, compact: compact, showTitle: showTitle);
    final url = movie.posterUrl.trim();

    final Widget content = (url.isEmpty || compact)
        ? art
        : Stack(
            fit: StackFit.expand,
            children: [
              art,
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                ),
              ),
            ],
          );

    final poster = Material(type: MaterialType.transparency, child: content);
    return heroTag == null ? poster : Hero(tag: heroTag!, child: poster);
  }
}

LinearGradient _posterGradient(Color base) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(base, Colors.white, 0.25)!,
        base,
        Color.lerp(base, Colors.black, 0.8)!,
      ],
      stops: const [0, 0.5, 1],
    );

class _PosterArt extends StatelessWidget {
  final Movie movie;
  final bool compact;
  final bool showTitle;
  const _PosterArt({
    required this.movie,
    required this.compact,
    required this.showTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: _posterGradient(movie.poster)),
        child: Center(
          child: Text(
            movie.title.isEmpty ? '?' : movie.title[0],
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : 200.0;
        final titleSize = (w * 0.105).clamp(10.0, 30.0).toDouble();
        final smallSize = (w * 0.05).clamp(8.0, 12.0).toDouble();

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                  painter: _PosterPainter(movie, fullArt: !showTitle)),
              if (showTitle)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(w * 0.07, w * 0.06, w * 0.07, w * 0.07),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xCC000000)],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: titleSize,
                            letterSpacing: 0.8,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: w * 0.02),
                        Text(
                          '${movie.year}  •  ${movie.genre}'.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: smallSize,
                              letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _Motif { space, action, thriller, animation, comedy, drama }

_Motif _motifFor(String genre) {
  switch (genre) {
    case 'Sci-Fi':
    case 'Fantasy':
      return _Motif.space;
    case 'Action':
      return _Motif.action;
    case 'Thriller':
    case 'Horror':
      return _Motif.thriller;
    case 'Animation':
      return _Motif.animation;
    case 'Comedy':
      return _Motif.comedy;
    default:
      return _Motif.drama;
  }
}

// Draws the poster picture. Same movie = same picture (random numbers are seeded).
class _PosterPainter extends CustomPainter {
  final Movie movie;
  final bool fullArt;
  _PosterPainter(this.movie, {required this.fullArt});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
        rect, Paint()..shader = _posterGradient(movie.poster).createShader(rect));

    final artH = fullArt ? h : h * 0.66; // top part that holds the picture
    final u = math.min(w, artH); // size unit so it works for posters and banners
    final rnd = math.Random(movie.id * 7919 + movie.title.length * 31 + movie.genre.length);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, artH));
    switch (_motifFor(movie.genre)) {
      case _Motif.space:
        _space(canvas, w, artH, u, rnd);
        break;
      case _Motif.action:
        _action(canvas, w, artH, u);
        break;
      case _Motif.thriller:
        _thriller(canvas, w, artH, u);
        break;
      case _Motif.animation:
        _animation(canvas, w, artH, u, rnd);
        break;
      case _Motif.comedy:
        _comedy(canvas, w, artH, u, rnd);
        break;
      case _Motif.drama:
        _drama(canvas, w, artH, u);
        break;
    }
    canvas.restore();
  }

  // Stars, a planet and a ring.
  void _space(Canvas c, double w, double h, double u, math.Random r) {
    final star = Paint();
    for (var i = 0; i < 45; i++) {
      star.color = Colors.white.withAlpha(70 + r.nextInt(180));
      c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h),
          u * 0.004 + r.nextDouble() * u * 0.01, star);
    }
    final center = Offset(w * 0.5, h * 0.5);
    final radius = u * 0.26;
    c.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [Colors.white.withAlpha(235), Colors.white.withAlpha(40)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(-0.4);
    c.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: radius * 3.2, height: radius * 0.8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = u * 0.014
        ..color = Colors.white.withAlpha(190),
    );
    c.restore();
  }

  // Explosion with rays and a slash.
  void _action(Canvas c, double w, double h, double u) {
    final center = Offset(w * 0.5, h * 0.5);
    final ray = Paint()..color = Colors.white.withAlpha(45);
    final len = math.max(w, h) * 1.5;
    for (var i = 0; i < 14; i++) {
      final a = i * (2 * math.pi / 14);
      final a2 = a + math.pi / 28;
      c.drawPath(
        Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx + math.cos(a) * len, center.dy + math.sin(a) * len)
          ..lineTo(center.dx + math.cos(a2) * len, center.dy + math.sin(a2) * len)
          ..close(),
        ray,
      );
    }
    c.drawCircle(
        center,
        u * 0.24,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * 0.03
          ..color = Colors.white.withAlpha(220));
    c.drawCircle(center, u * 0.16, Paint()..color = Colors.orangeAccent.withAlpha(230));
    c.drawCircle(center, u * 0.08, Paint()..color = Colors.yellowAccent.withAlpha(240));
    c.drawLine(
        Offset(0, h),
        Offset(w, 0),
        Paint()
          ..strokeWidth = u * 0.03
          ..color = Colors.white.withAlpha(120));
  }

  // Moon behind window blinds.
  void _thriller(Canvas c, double w, double h, double u) {
    c.drawCircle(Offset(w * 0.62, h * 0.4), u * 0.18,
        Paint()..color = Colors.white.withAlpha(225));
    final bar = Paint()..color = Colors.black.withAlpha(110);
    final step = h / 10;
    for (var y = 0.0; y < h; y += step) {
      c.drawRect(Rect.fromLTWH(0, y, w, step * 0.45), bar);
    }
  }

  // Sun and floating bubbles.
  void _animation(Canvas c, double w, double h, double u, math.Random r) {
    c.drawCircle(Offset(w * 0.72, h * 0.3), u * 0.16,
        Paint()..color = const Color(0xFFFFE082).withAlpha(230));
    final b = Paint();
    for (var i = 0; i < 16; i++) {
      b.color = Colors.white.withAlpha(35 + r.nextInt(80));
      c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h),
          u * (0.03 + r.nextDouble() * 0.1), b);
    }
  }

  // Confetti and a smiley face.
  void _comedy(Canvas c, double w, double h, double u, math.Random r) {
    final colors = [
      Colors.yellowAccent,
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.white,
      Colors.orangeAccent,
    ];
    final p = Paint();
    for (var i = 0; i < 45; i++) {
      p.color = colors[r.nextInt(colors.length)].withAlpha(210);
      c.save();
      c.translate(r.nextDouble() * w, r.nextDouble() * h);
      c.rotate(r.nextDouble() * math.pi);
      c.drawRect(
          Rect.fromCenter(center: Offset.zero, width: u * 0.05, height: u * 0.025),
          p);
      c.restore();
    }
    final center = Offset(w * 0.5, h * 0.52);
    final rad = u * 0.24;
    c.drawCircle(center, rad, Paint()..color = const Color(0xFFFFEB3B));
    final dark = Paint()..color = Colors.black87;
    c.drawCircle(center.translate(-rad * 0.35, -rad * 0.25), rad * 0.1, dark);
    c.drawCircle(center.translate(rad * 0.35, -rad * 0.25), rad * 0.1, dark);
    c.drawArc(
      Rect.fromCircle(center: center.translate(0, rad * 0.05), radius: rad * 0.55),
      0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rad * 0.1
        ..strokeCap = StrokeCap.round
        ..color = Colors.black87,
    );
  }

  // Spotlight with a lone figure.
  void _drama(Canvas c, double w, double h, double u) {
    final cone = Path()
      ..moveTo(w * 0.46, 0)
      ..lineTo(w * 0.54, 0)
      ..lineTo(w * 0.9, h)
      ..lineTo(w * 0.1, h)
      ..close();
    c.drawPath(
      cone,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(150), Colors.white.withAlpha(10)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    final fig = Paint()..color = Colors.black.withAlpha(190);
    c.drawCircle(Offset(w * 0.5, h * 0.6), u * 0.06, fig);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.5 - u * 0.08, h * 0.6 + u * 0.08, u * 0.16, h),
        Radius.circular(u * 0.06),
      ),
      fig,
    );
  }

  @override
  bool shouldRepaint(covariant _PosterPainter old) =>
      old.movie != movie || old.fullArt != fullArt;
}
