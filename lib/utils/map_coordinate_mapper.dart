import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Utility responsible for translating geographic coordinates to pixel
/// positions on the static India map graphic used across the app.
class IndiaMapCoordinateMapper {
  IndiaMapCoordinateMapper._();

  /// Approximate geographic bounds that cover mainland India.
  static const double minLatitude = 6.0;
  static const double maxLatitude = 37.5;
  static const double minLongitude = 68.0;
  static const double maxLongitude = 97.5;

  /// Default padding applied to the map image so markers avoid clipping at the edges.
  static const EdgeInsets defaultPadding = EdgeInsets.fromLTRB(24, 24, 24, 36);

  /// Converts a given latitude and longitude into an [Offset] within the
  /// rendered map based on the provided [mapSize]. The optional [mapPadding]
  /// can be used to fine-tune marker placement against the visual image
  /// borders.
  static Offset latLngToOffset({
    required double latitude,
    required double longitude,
    required Size mapSize,
    EdgeInsets mapPadding = defaultPadding,
  }) {
    if (mapSize.width <= 0 || mapSize.height <= 0) {
      return Offset.zero;
    }

    final double effectiveWidth = mapSize.width - mapPadding.horizontal;
    final double effectiveHeight = mapSize.height - mapPadding.vertical;

    if (effectiveWidth <= 0 || effectiveHeight <= 0) {
      return Offset(mapPadding.left, mapPadding.top);
    }

    final double clampedLatitude = latitude.clamp(minLatitude, maxLatitude).toDouble();
    final double clampedLongitude = longitude.clamp(minLongitude, maxLongitude).toDouble();

    final double longitudeRatio =
        (clampedLongitude - minLongitude) / (maxLongitude - minLongitude);
    final double latitudeRatio =
        (clampedLatitude - minLatitude) / (maxLatitude - minLatitude);

    final double dx = mapPadding.left + (longitudeRatio * effectiveWidth);
    // Latitude increases as we move north, but the vertical axis grows downwards,
    // so we invert the Y ratio.
    final double dy = mapPadding.top + ((1 - latitudeRatio) * effectiveHeight);

    return Offset(dx, dy);
  }
}