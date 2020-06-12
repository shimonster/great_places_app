import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/places_provider.dart';
import './screens/place_list_screen.dart';
import './screens/add_place_screen.dart';
import './screens/map_picker_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PlacesProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.teal,
        ),
        home: PlaceListScreen(),
        routes: {
          AddPlaceScreen.routeName: (ctx) => AddPlaceScreen(),
          MapPickerScreen.routeName: (ctx) => MapPickerScreen(),
        },
      ),
    );
  }
}
