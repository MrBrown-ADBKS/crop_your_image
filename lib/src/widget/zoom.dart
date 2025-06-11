import 'package:flutter/material.dart';

import '../logic/models/zoom_display_mode.dart';

class Zoom extends StatelessWidget {
  static const double _sliderWidth = 200;
  static const double _iconSmallSize = 16;
  static const double _iconBigSize = 32;

  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ZoomDisplayMode displayMode;
  final ValueChanged<double>? onZoomChanged;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const Zoom({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.displayMode,
    this.onZoomChanged,
    this.onZoomIn,
    this.onZoomOut,
  })  : assert(
          displayMode != ZoomDisplayMode.sliderOnly || onZoomChanged != null,
          'onZoomChanged is required when displayMode is sliderOnly',
        ),
        assert(
          displayMode != ZoomDisplayMode.buttonsOnly || (onZoomIn != null && onZoomOut != null),
          'onZoomIn and onZoomOut are required when displayMode is buttonsOnly',
        ),
        assert(
          displayMode != ZoomDisplayMode.sliderWithButtons &&
                  displayMode != ZoomDisplayMode.separateButtonsAndSlider ||
              (onZoomChanged != null && onZoomIn != null && onZoomOut != null),
          'onZoomChanged, onZoomIn, and onZoomOut are required when displayMode is sliderWithButtons or separateButtonsAndSlider',
        );

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    switch (displayMode) {
      case ZoomDisplayMode.sliderOnly:
        children.addAll([
          Icon(
            Icons.image,
            size: _iconSmallSize,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(
            width: _sliderWidth,
            child: Slider(
              thumbColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.primary,
              min: minZoom,
              max: maxZoom,
              value: currentZoom,
              onChanged: onZoomChanged,
            ),
          ),
          Icon(
            Icons.photo,
            size: _iconBigSize,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ]);
        break;

      case ZoomDisplayMode.buttonsOnly:
        children.addAll([
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: onZoomOut,
            icon: Icon(
              Icons.zoom_out,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: onZoomIn,
            icon: Icon(
              Icons.zoom_in,
            ),
          ),
        ]);
        break;

      case ZoomDisplayMode.sliderWithButtons:
        children.addAll([
          IconButton(
            icon: Icon(
              Icons.zoom_out,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onZoomOut,
          ),
          SizedBox(
            width: _sliderWidth,
            child: Slider(
              thumbColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.primary,
              min: minZoom,
              max: maxZoom,
              value: currentZoom,
              onChanged: onZoomChanged,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.zoom_in,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onZoomIn,
          ),
        ]);
        break;

      case ZoomDisplayMode.separateButtonsAndSlider:
        children.addAll([
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: onZoomOut,
            icon: Icon(
              Icons.zoom_out,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.secondary,
            onPressed: onZoomIn,
            icon: Icon(
              Icons.zoom_in,
            ),
          ),
          Spacer(),
          Icon(
            Icons.image,
            size: _iconSmallSize,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(
            width: _sliderWidth,
            child: Slider(
              thumbColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.primary,
              min: minZoom,
              max: maxZoom,
              value: currentZoom,
              onChanged: onZoomChanged,
            ),
          ),
          Icon(
            Icons.photo,
            size: _iconBigSize,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ]);
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
