import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;

  Future<void> _getCurrentLocation() async {
    final location = await Location().getLocation();
    print('(${location.latitude}, ${location.longitude})');
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
          child: _previewImageUrl == null
              ? Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(_previewImageUrl,
                  fit: BoxFit.cover, width: double.infinity),
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
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
