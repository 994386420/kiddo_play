import 'package:flutter/material.dart';

import 'figma_home_icons.dart';

String _figmaSvgColor(Color color) {
  final value = color.toARGB32();
  return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

class FigmaPauseIcon extends StatelessWidget {
  const FigmaPauseIcon({
    required this.size,
    this.color = const Color(0xFF1E6EEB),
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(
      svg: _pauseSvg(_figmaSvgColor(color)),
      size: size,
    );
  }
}

class FigmaSpeakerIcon extends StatelessWidget {
  const FigmaSpeakerIcon({
    required this.size,
    this.color = const Color(0xFF1E6EEB),
    this.muted = false,
    super.key,
  });

  final double size;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(
      svg: muted
          ? _speakerOffSvg(_figmaSvgColor(color))
          : _speakerOnSvg(_figmaSvgColor(color)),
      size: size,
    );
  }
}

class FigmaReplayIcon extends StatelessWidget {
  const FigmaReplayIcon({
    required this.size,
    this.color = const Color(0xFF1E6EEB),
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(
      svg: _replaySvg(_figmaSvgColor(color)),
      size: size,
    );
  }
}

String _pauseSvg(String fill) => '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="5.2" y="4" width="4.8" height="16" rx="2.4" fill="$fill"/>
  <rect x="14" y="4" width="4.8" height="16" rx="2.4" fill="$fill"/>
</svg>
''';

String _speakerOnSvg(String fill) => '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 9.8C4 9.36 4.36 9 4.8 9H8.7L13.5 5.2C14.02 4.79 14.8 5.16 14.8 5.83V18.17C14.8 18.84 14.02 19.21 13.5 18.8L8.7 15H4.8C4.36 15 4 14.64 4 14.2V9.8Z" fill="$fill"/>
  <path d="M17.3 9C18.72 10.43 18.72 13.57 17.3 15" stroke="$fill" stroke-width="2" stroke-linecap="round"/>
  <path d="M19.9 6.6C22.65 9.36 22.65 14.64 19.9 17.4" stroke="$fill" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

String _speakerOffSvg(String fill) => '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 9.8C4 9.36 4.36 9 4.8 9H8.7L13.5 5.2C14.02 4.79 14.8 5.16 14.8 5.83V18.17C14.8 18.84 14.02 19.21 13.5 18.8L8.7 15H4.8C4.36 15 4 14.64 4 14.2V9.8Z" fill="$fill"/>
  <path d="M18.6 8.2L13.8 13" stroke="$fill" stroke-width="2.2" stroke-linecap="round"/>
  <path d="M13.8 8.2L18.6 13" stroke="$fill" stroke-width="2.2" stroke-linecap="round"/>
</svg>
''';

String _replaySvg(String fill) => '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M7.4 8.8H3.8V5.2" stroke="$fill" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M4.2 8.5C5.86 5.97 8.69 4.4 11.8 4.4C16.77 4.4 20.8 8.43 20.8 13.4C20.8 18.37 16.77 22.4 11.8 22.4C7.94 22.4 4.64 19.97 3.37 16.56" stroke="$fill" stroke-width="2.2" stroke-linecap="round"/>
</svg>
''';
