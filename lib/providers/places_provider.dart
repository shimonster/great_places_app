import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../helpers/db_helper.dart';

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
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path
    });
  }

  Future<void> getPlaces() async {
    final response = await DBHelper.getData('user_places');
    List<Place> retrievedPlaces = [];
    response.forEach(
      (element) {
        retrievedPlaces.add(
          Place(
            id: element['id'],
            title: element['title'],
            image: File(element['image']),
            location: null,
          ),
        );
      },
    );
    _places = retrievedPlaces;
    notifyListeners();
  }
}
