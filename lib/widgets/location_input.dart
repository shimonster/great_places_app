import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../screens/map_picker_screen.dart';

class LocationInput extends StatefulWidget {
  final Function saveLocation;
  final LatLng selectedLocation;

  LocationInput({this.saveLocation, this.selectedLocation});
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LatLng _location;
  final _mapController = MapController();
  LatLng _selectedLocation;
  LocationData _currentLocation;

  @override
  void initState() {
    _selectedLocation = widget.selectedLocation;
    if (_selectedLocation != null) {
      widget.saveLocation(
          _selectedLocation.latitude, _selectedLocation.longitude);
      _setLocation(_selectedLocation);
    }
    super.initState();
  }

  void _setLocation(LatLng loc) {
    if (_location != null) {
      _mapController.move(loc, 14);
    }
    setState(() {
      _location = loc;
      widget.saveLocation(loc.latitude, loc.longitude);
    });
  }

  Future<void> _getCurrentLocation() async {
    final loc = await Location().getLocation();
    _setLocation(LatLng(loc.latitude, loc.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).accentColor,
              width: 2,
            ),
          ),
          child: _location == null
              ? Center(
                  child: Text('No location selected.'),
                )
              : _Map(_mapController, _location, _currentLocation),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton.icon(
                label: Text('Current Location'),
                icon: Icon(Icons.person_pin_circle),
                textColor: Theme.of(context).accentColor,
                onPressed: _getCurrentLocation,
              ),
            ),
            Expanded(
              child: FlatButton.icon(
                label: Text('Select Location'),
                icon: Icon(Icons.place),
                textColor: Theme.of(context).accentColor,
                onPressed: () => Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (ctx) => MapPickerScreen(false, _location),
                  ),
                )
                    .then((loc) {
                  final LatLng location = loc;
                  if (location != null) {
                    _setLocation(location);
                  }
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Map extends StatelessWidget {
  _Map(this._mapController, this._location, this._currentLocation);

  final MapController _mapController;
  final LatLng _location;
  final _currentLocation;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        zoom: 14,
        center: _location ?? _currentLocation,
        interactive: true,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
              "{z}/{x}/{y}.png?key={apiKey}",
          additionalOptions: {
            'apiKey': 'kNNg2Al5OGZUWcCpC0MeaoCQeCCeNzrl',
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 40,
              point: _location,
              builder: (ctx) => Container(
                child: Icon(
                  Icons.my_location,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
