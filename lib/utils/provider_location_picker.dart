import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProviderLocationPicker extends StatefulWidget {
  const ProviderLocationPicker({super.key});

  @override
  State<ProviderLocationPicker> createState() => _ProviderLocationPickerState();
}

class _ProviderLocationPickerState extends State<ProviderLocationPicker> {
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position pos = await _determinePosition();
      setState(() {
        _currentPosition = pos;
      });

      // Convert lat/lng to address
      List<Placemark> placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);

      Placemark place = placemarks.first;
      setState(() {
        _currentAddress =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Center(
        child: _currentPosition == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Lat: ${_currentPosition!.latitude}, "
                "Lng: ${_currentPosition!.longitude}"),
            const SizedBox(height: 10),
            Text(
              _currentAddress ?? "Fetching address...",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
