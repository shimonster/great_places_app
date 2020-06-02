import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/place.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];

  List<Place> get places {
    return [..._places];
  }

  void addPlace(String title, File image) {
    final newPlace = Place(
      id: DateTime.now().toString(),
      title: title,
      image: image,
    );
    _places.add(newPlace);
    notifyListeners();
    print(_places);
  }
}
