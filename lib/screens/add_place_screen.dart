import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong/latlong.dart';

import '../widgets/image_selector_widget.dart';
import '../widgets/location_input.dart';
import '../models/place.dart' as plc;
import '../providers/places_provider.dart';

class AddPlaceScreen extends StatefulWidget {
  static const routeName = '/addPlaceScreen';
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  var _titleController = TextEditingController();
  var _titleFocusNode = FocusNode();
  File _imageFile;
  plc.Location _selectedLocation;

  void _saveImage(File image) {
    _imageFile = image;
  }

  void _saveLocation(double lat, double lng, [String address]) {
    _selectedLocation = address != null
        ? plc.Location(latitude: lat, longitude: lng, address: address)
        : plc.Location(latitude: lat, longitude: lng, address: address);
  }

  void _submitData() {
    if (_titleController == null || _imageFile == null) {
      return;
    }
    Provider.of<PlacesProvider>(context, listen: false)
        .addPlace(_titleController.text, _imageFile);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _titleFocusNode.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Place'),
      ),
      body: Column(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  TextField(
                    focusNode: _titleFocusNode,
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: _titleFocusNode.hasFocus
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ImageSelectorWidget(_saveImage),
                  SizedBox(
                    height: 20,
                  ),
                  LocationInput(_saveLocation),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: RaisedButton(
              child: Text('Create'),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Theme.of(context).primaryColor,
              onPressed: _submitData,
            ),
          ),
        ],
      ),
    );
  }
}
