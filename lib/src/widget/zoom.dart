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
        children = _buildSliderOnly(context);
        break;
      case ZoomDisplayMode.buttonsOnly:
        children = _buildButtonsOnly(context);
        break;
      case ZoomDisplayMode.sliderWithButtons:
        children = _buildSliderWithButtons(context);
        break;
      case ZoomDisplayMode.separateButtonsAndSlider:
        children = _buildSeparateButtonsAndSlider(context);
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  List<Widget> _buildSliderOnly(BuildContext context) => [
        _icon(Icons.image, _iconSmallSize, context),
        _slider(context),
        _icon(Icons.photo, _iconBigSize, context),
      ];

  List<Widget> _buildButtonsOnly(BuildContext context) => [
        _zoomButton(Icons.zoom_out, onZoomOut!, context),
        _zoomButton(Icons.zoom_in, onZoomIn!, context),
      ];

  List<Widget> _buildSliderWithButtons(BuildContext context) => [
        _zoomButton(Icons.zoom_out, onZoomOut!, context),
        _slider(context),
        _zoomButton(Icons.zoom_in, onZoomIn!, context),
      ];

  List<Widget> _buildSeparateButtonsAndSlider(BuildContext context) => [
        _zoomButton(Icons.zoom_out, onZoomOut!, context),
        _zoomButton(Icons.zoom_in, onZoomIn!, context),
        const Spacer(),
        _icon(Icons.image, _iconSmallSize, context),
        _slider(context),
        _icon(Icons.photo, _iconBigSize, context),
      ];

  Widget _slider(BuildContext context) => SizedBox(
        width: _sliderWidth,
        child: Slider(
          thumbColor: Theme.of(context).colorScheme.primary,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.secondary,
          min: minZoom,
          max: maxZoom,
          value: currentZoom,
          onChanged: onZoomChanged,
        ),
      );

  Widget _zoomButton(IconData icon, VoidCallback onPressed, BuildContext context) => IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        onPressed: onPressed,
      );

  Widget _icon(IconData icon, double size, BuildContext context) => Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.secondary,
      );
}
