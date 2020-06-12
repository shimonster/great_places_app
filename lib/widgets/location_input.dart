import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../screens/map_picker_screen.dart';

class LocationInput extends StatefulWidget {
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;
  LocationData location;

  Future<void> _getCurrentLocation() async {
    location = await Location().getLocation();
    setState(() {});
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
          child: location == null
              ? Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                )
              : FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                      location.latitude,
                      location.longitude,
                    ),
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
                          point: LatLng(location.latitude, location.longitude),
                          builder: (ctx) => new Container(
                            child: Icon(
                              Icons.my_location,
                              color: Colors.deepOrangeAccent,
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
                onPressed: () =>
                    Navigator.of(context).pushNamed(MapPickerScreen.routeName),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
