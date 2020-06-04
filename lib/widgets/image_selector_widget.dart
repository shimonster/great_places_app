import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sysPaths;

class ImageSelectorWidget extends StatefulWidget {
  final Function saveImage;

  ImageSelectorWidget(this.saveImage);

  @override
  _ImageSelectorWidgetState createState() => _ImageSelectorWidgetState();
}

class _ImageSelectorWidgetState extends State<ImageSelectorWidget> {
  File _currentImage;

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _currentImage = File(imageFile.path);
    });
    final appDir = await sysPaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    File(imageFile.path).copy('${appDir.path}/$fileName');
    widget.saveImage(File(imageFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Theme.of(context).accentColor,
            ),
          ),
          alignment: Alignment.center,
          child: _currentImage == null
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Click The "Take Picture" button to take a picture',
                    textAlign: TextAlign.center,
                  ),
                )
              : Image.file(
                  _currentImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: FlatButton.icon(
            icon: Icon(Icons.camera),
            label: Text('Take Picture'),
            textColor: Theme.of(context).accentColor,
            onPressed: _takePicture,
          ),
        ),
      ],
    );
  }
}
