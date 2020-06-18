import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './add_place_screen.dart';
import '../providers/places_provider.dart';
import './place_details_screen.dart';

class PlaceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(AddPlaceScreen.routeName),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<PlacesProvider>(context, listen: false).getPlaces(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<PlacesProvider>(
                    builder: (ctx, places, _) {
                      return places.places.isEmpty
                          ? Center(
                              child: const Text('No places yet'),
                            )
                          : ListView.builder(
                              itemCount: places.places.length,
                              itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        FileImage(places.places[i].image),
                                  ),
                                  title: Text(places.places[i].title),
                                  subtitle: Text(
                                      '${places.places[i].location.latitude.toStringAsFixed(3)}, ${places.places[i].location.latitude.toStringAsFixed(3)}'),
                                  onTap: () => Navigator.of(context).pushNamed(
                                    PlaceDetailsScreen.routeName,
                                    arguments: places.places[i].id,
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
      ),
    );
  }
}
