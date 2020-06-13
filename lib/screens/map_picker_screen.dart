import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  static const routeName = '/map_picker';
  final LatLng oldLoc;

  MapPickerScreen({this.oldLoc});
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation;
  LatLng _currentLocation;
  Function saveLocation;
  bool _isLoading = false;
  final _mapController = MapController();

  Future<void> _selectLocation([LatLng location]) async {
    if (location == null) {
      setState(() {
        _isLoading = true;
      });
      final location = await Location().getLocation();
      final currentLocation = LatLng(location.latitude, location.longitude);
      setState(() {
        _currentLocation = currentLocation;
        if (widget.oldLoc != null) {
          _selectedLocation = widget.oldLoc;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _selectedLocation = location;
      });
    }
    print(['selected location', _selectedLocation]);
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
      body: Column(
        children: <Widget>[
          _isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  child: Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
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
                          },
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.center),
                              point: _currentLocation,
                              builder: (ctx) => Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.red, width: 3),
                                    borderRadius: BorderRadius.circular(100)),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                              ),
                            ),
                            if (_selectedLocation != null &&
                                _currentLocation != _selectedLocation)
                              Marker(
                                anchorPos: AnchorPos.align(AnchorAlign.top),
                                point: _selectedLocation,
                                builder: (ctx) => Icon(
                                  Icons.place,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          Container(
            width: double.infinity,
            height: 60,
            child: FlatButton.icon(
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              icon: Icon(Icons.check),
              label: Text('Choose'),
              onPressed: _selectedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_selectedLocation);
                    },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70, right: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(7)),
        width: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () => _mapController.move(_currentLocation, 15),
              child: Container(
                height: 35,
                width: 25,
                alignment: Alignment.center,
                child: Icon(Icons.person_pin,
                    color: Theme.of(context).accentColor),
              ),
            ),
            Divider(
              height: 5,
            ),
            InkWell(
              onTap: _selectedLocation == null
                  ? null
                  : () => _mapController.move(_selectedLocation, 15),
              child: Container(
                height: 35,
                width: 25,
                alignment: Alignment.center,
                child: Icon(Icons.location_on,
                    color: Theme.of(context).accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
