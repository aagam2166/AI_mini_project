// lib/core/utils/time_utils.dart
String minToHHMM(int m) {
  final hh = (m ~/ 60).toString().padLeft(2, '0');
  final mm = (m % 60).toString().padLeft(2, '0');
  return "$hh:$mm";
}
