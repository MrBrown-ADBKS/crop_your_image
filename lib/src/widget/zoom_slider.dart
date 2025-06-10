import 'package:flutter/material.dart';

class ZoomSlider extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ValueChanged<double> onZoomChanged;

  const ZoomSlider({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(
          width: 200,
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
          size: 32,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }
}
