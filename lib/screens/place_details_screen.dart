import 'package:flutter/material.dart';
import 'package:greatplacesapp/models/place.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../providers/places_provider.dart';
import './map_picker_screen.dart';

class PlaceDetailsScreen extends StatelessWidget {
  static const routeName = '/place details screem';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments as String;
    final _place =
        Provider.of<PlacesProvider>(context, listen: false).getPlaceById(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _place.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              width: double.infinity,
              child: Image.file(
                _place.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: _Map(place: _place),
            ),
            FlatButton.icon(
              label: Text('View Fullscreen Map'),
              icon: Icon(Icons.map),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => MapPickerScreen(
                    true,
                    LatLng(
                      _place.location.latitude,
                      _place.location.longitude,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Map extends StatefulWidget {
  const _Map({
    Key key,
    @required Place place,
  })  : _place = place,
        super(key: key);

  final Place _place;

  @override
  __MapState createState() => __MapState();
}

class __MapState extends State<_Map> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        zoom: 15,
        center: LatLng(
            widget._place.location.latitude, widget._place.location.longitude),
        interactive: false,
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
              point: LatLng(widget._place.location.latitude,
                  widget._place.location.longitude),
              anchorPos: AnchorPos.align(AnchorAlign.top),
              builder: (ctx) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
