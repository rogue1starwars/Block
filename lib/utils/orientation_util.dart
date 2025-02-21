/// Normalizes a bearing angle to be within -180 to 180 degrees
///
/// [bearing] The input bearing angle in degrees (-360 to 360)
/// Returns normalized bearing in degrees (-180 to 180)
///
/// Throws [ArgumentError] if bearing is outside valid range
double formatBearing(double bearing) {
  // Validate input range
  if (bearing < -360 || bearing > 360) {
    return bearing;
  }

  // Return original value if already in range
  if (bearing.abs() <= 180) {
    return bearing;
  }

  // Normalize bearing to -180 to 180 range
  return bearing > 0 ? bearing - 360 : bearing + 360;
}
