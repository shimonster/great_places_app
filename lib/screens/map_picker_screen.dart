import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  static const routeName = '/map_picker';
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation;
  LatLng _currentLocation;
  bool _isLoading = false;

  Future<void> _selectLocation([LatLng location]) async {
    print('alsdfhllash ');
    if (location == null) {
      setState(() {
        _isLoading = true;
      });
      final location = await Location().getLocation();
      final currentLocation = LatLng(location.latitude, location.longitude);
      setState(() {
        _selectedLocation = currentLocation;
        _currentLocation = currentLocation;
        _isLoading = false;
        print(['current location', currentLocation]);
      });
    } else {
      setState(() {
        _selectedLocation = location;
      });
      print(['selected location', _selectedLocation]);
    }
  }

  @override
  void initState() {
    _selectLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : Container(
              child: FlutterMap(
                options: MapOptions(
                  zoom: 15,
                  center: _selectedLocation ?? _currentLocation,
                  onTap: _selectLocation,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://api.tomtom.com/map/1/tile/basic/main/"
                          "{z}/{x}/{y}.png?key={apiKey}",
                      additionalOptions: {
                        'apiKey': 'kNNg2Al5OGZUWcCpC0MeaoCQeCCeNzrl',
                      }),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 40,
                        point: _currentLocation,
                        builder: (ctx) => Icon(
                          Icons.my_location,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      Marker(
                        width: 40,
                        point: _selectedLocation,
                        builder: (ctx) => Icon(
                          Icons.place,
                          color: Colors.red,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
