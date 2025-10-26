import 'package:flutter/material.dart';

import '../utils/map_coordinate_mapper.dart';

/// Paints a simplified silhouette of India that aligns with the coordinate
/// system used for positioning destination markers.
class IndiaMapPainter extends CustomPainter {
  IndiaMapPainter({
    this.mapPadding = IndiaMapCoordinateMapper.defaultPadding,
    this.fillColor = const Color(0xFFB2DFDB),
    this.strokeColor = const Color(0xFF00796B),
    this.waterColor = const Color(0xFFE0F7FA),
  });

  final EdgeInsets mapPadding;
  final Color fillColor;
  final Color strokeColor;
  final Color waterColor;

  static const List<Map<String, double>> _mainlandBoundary = [
    {'lat': 35.5, 'lng': 74.0},
    {'lat': 35.0, 'lng': 77.8},
    {'lat': 34.0, 'lng': 80.8},
    {'lat': 32.0, 'lng': 83.0},
    {'lat': 30.0, 'lng': 86.0},
    {'lat': 28.5, 'lng': 88.5},
    {'lat': 27.5, 'lng': 91.0},
    {'lat': 26.0, 'lng': 94.0},
    {'lat': 25.5, 'lng': 95.5},
    {'lat': 23.5, 'lng': 94.2},
    {'lat': 22.0, 'lng': 92.5},
    {'lat': 20.5, 'lng': 89.5},
    {'lat': 19.0, 'lng': 88.0},
    {'lat': 17.0, 'lng': 86.8},
    {'lat': 15.0, 'lng': 85.5},
    {'lat': 13.0, 'lng': 81.5},
    {'lat': 11.0, 'lng': 80.0},
    {'lat': 8.5, 'lng': 77.5},
    {'lat': 10.5, 'lng': 75.5},
    {'lat': 12.5, 'lng': 74.5},
    {'lat': 15.5, 'lng': 73.5},
    {'lat': 17.5, 'lng': 72.5},
    {'lat': 19.5, 'lng': 72.8},
    {'lat': 21.5, 'lng': 72.5},
    {'lat': 23.5, 'lng': 70.5},
    {'lat': 24.5, 'lng': 69.5},
    {'lat': 26.0, 'lng': 70.0},
    {'lat': 28.0, 'lng': 70.5},
    {'lat': 30.0, 'lng': 71.0},
    {'lat': 32.0, 'lng': 72.5},
    {'lat': 33.5, 'lng': 74.0},
  ];

  static const List<Map<String, double>> _andamanIslands = [
    {'lat': 12.5, 'lng': 92.7},
    {'lat': 11.5, 'lng': 92.8},
    {'lat': 10.5, 'lng': 92.6},
  ];

  static const List<Map<String, double>> _lakshadweepIslands = [
    {'lat': 11.0, 'lng': 72.7},
    {'lat': 10.2, 'lng': 72.4},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Water background
    final Rect mapRect = Offset.zero & size;
    final Paint waterPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [waterColor, waterColor.withOpacity(0.65)],
      ).createShader(mapRect);
    canvas.drawRect(mapRect, waterPaint);

    final Path mainlandPath = _buildPath(size, _mainlandBoundary);
    final Paint landPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainlandPath, landPaint);

    final Paint borderPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(mainlandPath, borderPaint);

    final Paint islandPaint = Paint()
      ..color = fillColor.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    for (final island in _andamanIslands) {
      final Offset center = _latLngToOffset(size, island['lat']!, island['lng']!);
      canvas.drawCircle(center, 6, islandPaint);
      canvas.drawCircle(center, borderPaint.strokeWidth / 2, borderPaint);
    }

    for (final island in _lakshadweepIslands) {
      final Offset center = _latLngToOffset(size, island['lat']!, island['lng']!);
      canvas.drawCircle(center, 4, islandPaint);
      canvas.drawCircle(center, borderPaint.strokeWidth / 2, borderPaint);
    }
  }

  Path _buildPath(Size size, List<Map<String, double>> coordinates) {
    final Path path = Path();
    if (coordinates.isEmpty) {
      return path;
    }

    final Offset firstPoint =
        _latLngToOffset(size, coordinates.first['lat']!, coordinates.first['lng']!);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < coordinates.length; i++) {
      final Offset offset =
          _latLngToOffset(size, coordinates[i]['lat']!, coordinates[i]['lng']!);
      path.lineTo(offset.dx, offset.dy);
    }

    path.close();
    return path;
  }

  Offset _latLngToOffset(Size mapSize, double latitude, double longitude) {
    return IndiaMapCoordinateMapper.latLngToOffset(
      latitude: latitude,
      longitude: longitude,
      mapSize: mapSize,
      mapPadding: mapPadding,
    );
  }

  @override
  bool shouldRepaint(covariant IndiaMapPainter oldDelegate) {
    return oldDelegate.mapPadding != mapPadding ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.waterColor != waterColor;
  }
}
