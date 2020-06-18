import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  static const routeName = '/map_picker';
  final LatLng oldLoc;
  final bool _spectateMode;

  MapPickerScreen(this._spectateMode, [this.oldLoc]);
  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
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
  bool _hadDisposed = false;

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
    _moveAnimationController.dispose();
    print('animation disposed');
    _hadDisposed = true;
    super.dispose();
  }

  Future<void> _selectLocation([LatLng location]) async {
    if (location == null) {
      setState(() {
        _isLoading = true;
      });
      final location = await Location().getLocation();
      if (!_hadDisposed) {
        final currentLocation = LatLng(location.latitude, location.longitude);
        setState(() {
          _currentLocation = currentLocation;
          if (widget.oldLoc != null &&
              (currentLocation != widget.oldLoc || widget._spectateMode)) {
            _selectedLocation = widget.oldLoc;
          }
          _isLoading = false;
        });
      }
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
          LatLng(_moveLatAnimation.value, _moveLngAnimation.value),
          widget._spectateMode ? 14 : 13);
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
                      widget._spectateMode,
                    ),
                  ),
                ),
          if (!widget._spectateMode)
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
                    : () => Navigator.of(context)
                        .pop(widget._spectateMode ? null : _selectedLocation),
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
            if (!widget._spectateMode)
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
  final bool _spectatorMode;

  const _Map(this.mapController, this.currentLocation, this.selectedLocation,
      this.selectLocation, this._spectatorMode);

  @override
  __MapState createState() => __MapState();
}

class __MapState extends State<_Map> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        zoom: widget._spectatorMode ? 14 : 13,
        center: widget.selectedLocation ?? widget.currentLocation,
        onTap: widget._spectatorMode ? null : widget.selectLocation,
      ),
      layers: [
        TileLayerOptions(
          errorImage: NetworkImage(
              'https://www.sciencenewsforstudents.org/wp-content/uploads/2020/02/021520_cats_feat_opt2-1028x579.jpg'),
          urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
              "{z}/{x}/{y}.png?key={apiKey}",
          additionalOptions: {
            'apiKey': 'kNNg2Al5OGZUWcCpC0MeaoCQeCCeNzrl',
          },
        ),
        MarkerLayerOptions(
          markers: [
            if (!widget._spectatorMode)
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
            if (widget.selectedLocation != null /* && widget._spectatorMode*/)
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
