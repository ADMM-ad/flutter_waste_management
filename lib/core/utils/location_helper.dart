import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationHelper {
  /// Request GPS location and perform reverse geocoding to retrieve readable address string.
  static Future<LocationResult> getCurrentLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) pada perangkat belum aktif. Silakan aktifkan GPS.');
    }

    // 2. Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, open app settings
      await openAppSettings();
      throw Exception('Izin akses lokasi ditolak permanen. Silakan izinkan melalui Pengaturan Perangkat.');
    }

    // 3. Obtain current coordinates
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    // 4. Reverse Geocoding
    String resolvedAddress = 'Koordinat: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode
        ].where((e) => e != null && e.isNotEmpty).toList();

        if (parts.isNotEmpty) {
          resolvedAddress = parts.join(', ');
        }
      }
    } catch (_) {
      // Fallback to coordinates string if reverse geocoding fails offline
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: resolvedAddress,
    );
  }
}
