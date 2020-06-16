import 'dart:math';

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

class _MapPickerScreenState extends State<MapPickerScreen>
    with TickerProviderStateMixin {
  LatLng _selectedLocation;
  LatLng _currentLocation;
  Function saveLocation;
  bool _isLoading = false;
  final _mapController = MapController();
  var _moveAnimationController = AnimationController(
    vsync: __MapState(),
  );
  Animation<double> _moveLatAnimation;
  Animation<double> _moveLngAnimation;
  double _distance;
  Duration _duration;

  @override
  void initState() {
    _selectLocation();
    _moveLatAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.linear,
      ),
    );
    _moveLatAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.linear,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    if (_moveLngAnimation != null) {
      _moveLngAnimation.removeListener(() {});
    }
    super.dispose();
  }

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
  }

  void _animateMove(LatLng end) {
    _moveAnimationController = AnimationController(
      vsync: __MapState(),
    );
    _distance = sqrt(pow(_mapController.center.longitude - end.longitude, 2) +
        pow(_mapController.center.latitude - end.latitude, 2));
    _duration = Duration(
      milliseconds: min(
          int.parse(
            (_distance * 10000).toStringAsFixed(0),
          ),
          1200),
    );
    _moveAnimationController.duration = _duration;
    _moveLatAnimation = Tween<double>(
      begin: _mapController.center.latitude,
      end: end.latitude,
    ).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.ease,
      ),
    );
    _moveLngAnimation = Tween<double>(
      begin: _mapController.center.longitude,
      end: end.longitude,
    ).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.linear,
      ),
    );
    _moveAnimationController.forward().then((value) {
      _moveLngAnimation.removeListener(() {});
    });
    _moveLngAnimation.addListener(() {
      _mapController.move(
          LatLng(_moveLatAnimation.value, _moveLngAnimation.value), 15);
    });
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
                    child: _Map(
                      _mapController,
                      _currentLocation,
                      _selectedLocation,
                      _selectLocation,
//                      !_mapController.ready
//                          ? _currentLocation
//                          : _mapController.center,
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
              onTap: () {
                _animateMove(_currentLocation);
              },
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
                  : () {
                      _animateMove(_selectedLocation);
                    },
              child: Container(
                height: 35,
                width: 25,
                alignment: Alignment.center,
                child: Icon(Icons.location_on,
                    color: _selectedLocation == null
                        ? Colors.grey
                        : Theme.of(context).accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Map extends StatefulWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final LatLng selectedLocation;
  final Function selectLocation;
//  final LatLng mapPos;

  const _Map(this.mapController, this.currentLocation, this.selectedLocation,
      this.selectLocation /*, this.mapPos*/);

  @override
  __MapState createState() => __MapState();
}

class __MapState extends State<_Map> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        zoom: 15,
        center: widget.currentLocation,
        onTap: widget.selectLocation,
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
              anchorPos: AnchorPos.align(AnchorAlign.center),
              point: widget.currentLocation,
              builder: (ctx) => Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  Icons.person,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
            ),
            if (widget.selectedLocation != null &&
                widget.currentLocation != widget.selectedLocation)
              Marker(
                anchorPos: AnchorPos.align(AnchorAlign.top),
                point: widget.selectedLocation,
                builder: (ctx) => Icon(
                  Icons.place,
                  size: 30,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
