import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../screens/map_picker_screen.dart';

class LocationInput extends StatefulWidget {
  final Function saveLocation;

  LocationInput(this.saveLocation);
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LatLng _location;
  final _mapController = MapController();

  Future<void> _getCurrentLocation() async {
    final loc = await Location().getLocation();
    setState(() {
      if (_location != null) {
        _mapController.move(LatLng(loc.latitude, loc.longitude), 13);
      }
      _location = LatLng(loc.latitude, loc.longitude);
    });
    widget.saveLocation(loc.latitude, loc.longitude);
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
              ? Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    zoom: 13,
                    center: _location,
                    interactive: true,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                          "https://api.tomtom.com/map/1/tile/basic/main/"
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
                ),
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
                    builder: (ctx) => MapPickerScreen(oldLoc: _location),
                  ),
                )
                    .then((loc) {
                  if (loc != null) {
                    final LatLng location = loc;
                    widget.saveLocation(location.latitude, location.longitude);
                    setState(() {
                      if (_location != null) {
                        _mapController.move(
                            LatLng(location.latitude, location.longitude), 13);
                      }
                      _location = LatLng(location.latitude, location.longitude);
                    });
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
