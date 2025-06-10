import 'dart:typed_data';
import 'dart:ui';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Crop Your Image Demo'),
        ),
        body: CropSample(),
      ),
    );
  }
}

class CropSample extends StatefulWidget {
  @override
  _CropSampleState createState() => _CropSampleState();
}

class _CropSampleState extends State<CropSample> {
  static const _images = const [
    'assets/images/city.png',
    'assets/images/lake.png',
    'assets/images/train.png',
    'assets/images/turtois.png',
  ];

  final _cropController = CropController();
  final _imageDataList = <Uint8List>[];

  var _loadingImage = false;
  var _currentImage = 3;
  set currentImage(int value) {
    setState(() {
      _currentImage = value;
    });
    _cropController.image = _imageDataList[_currentImage];
  }

  var _isThumbnail = false;
  var _isCropping = false;
  var _isCircleUi = false;
  Uint8List? _croppedData;
  var _statusText = '';
  var _isOverlayActive = true;
  var _undoEnabled = false;
  var _redoEnabled = false;

  @override
  void initState() {
    _loadAllImages();
    super.initState();
  }

  Future<void> _loadAllImages() async {
    setState(() {
      _loadingImage = true;
    });
    for (final assetName in _images) {
      _imageDataList.add(await _load(assetName));
    }
    setState(() {
      _loadingImage = false;
    });
  }

  Future<Uint8List> _load(String assetName) async {
    final assetData = await rootBundle.load(assetName);
    return assetData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Visibility(
          visible: !_loadingImage && !_isCropping,
          child: Column(
            children: [
              // if (_imageDataList.length >= 4)
              //   Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Row(
              //       children: [
              //         _buildThumbnail(_imageDataList[0]),
              //         const SizedBox(width: 16),
              //         _buildThumbnail(_imageDataList[1]),
              //         const SizedBox(width: 16),
              //         _buildThumbnail(_imageDataList[2]),
              //         const SizedBox(width: 16),
              //         _buildThumbnail(_imageDataList[3]),
              //       ],
              //     ),
              //   ),
              Expanded(
                child: Visibility(
                  visible: _croppedData == null,
                  child: Stack(
                    children: [
                      if (_imageDataList.isNotEmpty) ...[
                        Crop(
                          showManualZoom: true,
                          willUpdateScale: (newScale) => newScale < 5,
                          controller: _cropController,
                          image: _imageDataList[_currentImage],
                          onCropped: (result) {
                            switch (result) {
                              case CropSuccess(:final croppedImage):
                                _croppedData = croppedImage;
                              case CropFailure(:final cause):
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text('Failed to crop image: ${cause}'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('OK')),
                                    ],
                                  ),
                                );
                            }
                            setState(() => _isCropping = false);
                          },
                          withCircleUi: _isCircleUi,
                          onStatusChanged: (status) => setState(() {
                            _statusText = <CropStatus, String>{
                                  CropStatus.nothing: 'Crop has no image data',
                                  CropStatus.loading: 'Crop is now loading given image',
                                  CropStatus.ready: 'Crop is now ready!',
                                  CropStatus.cropping: 'Crop is now cropping image',
                                }[status] ??
                                '';
                          }),
                          maskColor: _isThumbnail ? Colors.white : null,
                          cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
                          interactive: true,
                          fixCropRect: true,
                          radius: 20,
                          initialRectBuilder: InitialRectBuilder.withBuilder(
                            (viewportRect, imageRect) {
                              return Rect.fromLTRB(
                                viewportRect.left + 24,
                                viewportRect.top + 24,
                                viewportRect.right - 24,
                                viewportRect.bottom - 24,
                              );
                            },
                          ),
                          onHistoryChanged: (history) => setState(() {
                            _undoEnabled = history.undoCount > 0;
                            _redoEnabled = history.redoCount > 0;
                          }),
                          overlayBuilder: _isOverlayActive
                              ? (context, rect) {
                                  final overlay = CustomPaint(
                                    // painter: GridPainter(),
                                    painter: CameraIconPainter(),
                                  );
                                  return _isCircleUi
                                      ? ClipOval(
                                          child: overlay,
                                        )
                                      : overlay;
                                }
                              : null,
                        ),
                        // IgnorePointer(
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(24),
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //         border: Border.all(width: 4, color: Colors.white),
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isThumbnail = true),
                          onTapUp: (_) => setState(() => _isThumbnail = false),
                          child: CircleAvatar(
                            backgroundColor: _isThumbnail ? Colors.blue.shade50 : Colors.blue,
                            child: Center(
                              child: Icon(Icons.crop_free_rounded),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  replacement: Center(
                    child: _croppedData == null ? SizedBox.shrink() : Image.memory(_croppedData!),
                  ),
                ),
              ),
              if (_croppedData == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.crop_7_5),
                            onPressed: () {
                              _isCircleUi = false;
                              _cropController.aspectRatio = 16 / 4;
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.crop_16_9),
                            onPressed: () {
                              _isCircleUi = false;
                              _cropController.aspectRatio = 16 / 9;
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.crop_5_4),
                            onPressed: () {
                              _isCircleUi = false;
                              _cropController.aspectRatio = 4 / 3;
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.crop_square),
                            onPressed: () {
                              _isCircleUi = false;
                              _cropController
                                ..withCircleUi = false
                                ..aspectRatio = 1;
                            },
                          ),
                          IconButton(
                              icon: Icon(Icons.circle),
                              onPressed: () {
                                _isCircleUi = true;
                                _cropController.withCircleUi = true;
                              }),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Show Grid'),
                          Switch(
                            value: _isOverlayActive,
                            onChanged: (value) {
                              setState(() {
                                _isOverlayActive = value;
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _undoEnabled ? () => _cropController.undo() : null,
                            child: Text('UNDO'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _redoEnabled ? () => _cropController.redo() : null,
                            child: Text('REDO'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isCropping = true;
                            });
                            _isCircleUi ? _cropController.cropCircle() : _cropController.crop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('CROP IT!'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(_statusText),
              const SizedBox(height: 16),
            ],
          ),
          replacement: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Expanded _buildThumbnail(Uint8List data) {
    final index = _imageDataList.indexOf(data);
    return Expanded(
      child: InkWell(
        onTap: () {
          _croppedData = null;
          currentImage = index;
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            border: index == _currentImage
                ? Border.all(
                    width: 8,
                    color: Colors.blue,
                  )
                : null,
          ),
          child: Image.memory(
            data,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// class GridPainter extends CustomPainter {
//   final divisions = 2;
//   final strokeWidth = 1.0;
//   final Color color = Colors.black54;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..strokeWidth = strokeWidth
//       ..color = color;

//     final spacing = size / (divisions + 1);
//     for (var i = 1; i < divisions + 1; i++) {
//       // draw vertical line
//       canvas.drawLine(
//         Offset(spacing.width * i, 0),
//         Offset(spacing.width * i, size.height),
//         paint,
//       );

//       // draw horizontal line
//       canvas.drawLine(
//         Offset(0, spacing.height * i),
//         Offset(size.width, spacing.height * i),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(GridPainter oldDelegate) => false;
// }

class CameraIconPainter extends CustomPainter {
  // A CustomPainter class that paints the camera icon in the center of a 100x100 pixel area.

  final Color? color; // Added color property for more flexibility

  CameraIconPainter({this.color}); // Constructor with optional color

  @override
  void paint(Canvas canvas, Size size) {
    //size is the size of the area we are painting on.
    // Calculate the center of the canvas
    final centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Create a Paint object to define the painting style.
    final paint = Paint()
      ..color = color ?? Colors.black // Use provided color or default to default color
      ..style = PaintingStyle.fill
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Use a PictureRecorder to record the drawing of the icon.
    final recorder = PictureRecorder();
    final Canvas pictureCanvas = Canvas(recorder);

    // Create a TextPainter to draw the icon.
    const IconData cameraIcon = Icons.camera_outlined;
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(cameraIcon.codePoint),
      style: TextStyle(
        fontFamily: 'MaterialIcons', // Use the MaterialIcons font
        fontSize: 28, // The size of the icon
        color: color ?? Colors.blue,
      ),
    );
    textPainter.layout(); // Lay out the text painter

    // Calculate the position to draw the icon at the center
    final iconX = centerX - textPainter.width / 2;
    final iconY = centerY - textPainter.height / 2;

    // Draw the icon on the pictureCanvas
    textPainter.paint(pictureCanvas, Offset(iconX, iconY));

    // Finish recording and get the Picture
    final Picture picture = recorder.endRecording();

    // Draw the picture onto the main canvas.
    canvas.drawPicture(picture);
    //draw the rectangle
    final newPaint = Paint()
      ..color = Colors.black // Use provided color or default to default color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, newPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //  Should return true if the painter needs to repaint (e.g., if the color changes).
    if (oldDelegate is CameraIconPainter) {
      return oldDelegate.color != color;
    }
    return true;
  }
}
