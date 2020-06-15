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
  final _moveAnimationController = AnimationController(
    duration: Duration(seconds: 2),
    vsync: __MapState(),
  );
  Animation<double> _moveLatAnimation;
  Animation<double> _moveLngAnimation;
  bool _isMoving = false;

  Widget _map() {
    return _Map(
      _mapController,
      _currentLocation,
      _selectedLocation,
      _selectLocation,
      !_mapController.ready ? _currentLocation : _mapController.center,
      'expanded',
    );
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
    _moveAnimationController.reset();
    print('_animateMove was run');
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
    _isMoving = true;
    setState(() {
      _moveAnimationController.forward().then((value) {
        setState(() {
          _isMoving = false;
        });
      });
    });
  }

  @override
  void initState() {
    print('initState');
    _selectLocation();
    _moveLatAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _moveAnimationController,
        curve: Curves.ease,
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
                    child: _moveLngAnimation == null || !_isMoving
                        ? _map()
                        : AnimatedBuilder(
                            animation: _moveLngAnimation,
                            builder: (ctx, ch) {
                              _mapController.move(
                                  LatLng(_moveLatAnimation.value,
                                      _moveLngAnimation.value),
                                  15);
                              print(['animation', _moveLngAnimation.value]);
                              return _map();
                            },
                            child: _Map(
                              _mapController,
                              _currentLocation,
                              _selectedLocation,
                              _selectLocation,
                              !_mapController.ready
                                  ? _currentLocation
                                  : _mapController.center,
                              'animation builder',
                            ),
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
                print('go to person on tap');
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
                    color: Theme.of(context).accentColor),
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
  final LatLng mapPos;
  final String printString;

  const _Map(this.mapController, this.currentLocation, this.selectedLocation,
      this.selectLocation, this.mapPos, this.printString);

  @override
  __MapState createState() => __MapState();
}

class __MapState extends State<_Map> with TickerProviderStateMixin {
  @override
  void dispose() {
    print('map dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.printString);
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        zoom: 15,
        center: widget.mapPos,
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
