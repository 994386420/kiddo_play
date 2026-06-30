import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../game_models.dart';

enum FigmaFloatIconType { star, heart, sparkle, flower, fire, diamond }

String _svgColor(Color color) {
  final value = color.toARGB32();
  return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

class FigmaSvgIcon extends StatelessWidget {
  const FigmaSvgIcon({
    required this.svg,
    required this.size,
    super.key,
  });

  final String svg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class FigmaRocketIcon extends StatelessWidget {
  const FigmaRocketIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _rocketSvg, size: size);
  }
}

class FigmaGameGridIcon extends StatelessWidget {
  const FigmaGameGridIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _gameGridSvg, size: size);
  }
}

class FigmaTrophyIcon extends StatelessWidget {
  const FigmaTrophyIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _trophySvg, size: size);
  }
}

class FigmaRainbowIcon extends StatelessWidget {
  const FigmaRainbowIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _rainbowSvg, size: size);
  }
}

class FigmaTargetIcon extends StatelessWidget {
  const FigmaTargetIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _targetSvg, size: size);
  }
}

class FigmaHomeIcon extends StatelessWidget {
  const FigmaHomeIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _homeSvg, size: size);
  }
}

class FigmaBackChevronIcon extends StatelessWidget {
  const FigmaBackChevronIcon({
    required this.size,
    this.color = const Color(0xFFB56CF5),
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(
      svg: _backChevronSvg(_svgColor(color)),
      size: size,
    );
  }
}

class FigmaSparkleStarIcon extends StatelessWidget {
  const FigmaSparkleStarIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _sparkleStarSvg, size: size);
  }
}

class FigmaLockIcon extends StatelessWidget {
  const FigmaLockIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _lockSvg, size: size);
  }
}

class FigmaDownArrowIcon extends StatelessWidget {
  const FigmaDownArrowIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _downArrowSvg, size: size);
  }
}

class FigmaLightbulbIcon extends StatelessWidget {
  const FigmaLightbulbIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _lightbulbSvg, size: size);
  }
}

class FigmaPunchFistIcon extends StatelessWidget {
  const FigmaPunchFistIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _punchFistSvg, size: size);
  }
}

class FigmaFloatIcon extends StatelessWidget {
  const FigmaFloatIcon({
    required this.type,
    required this.size,
    super.key,
  });

  final FigmaFloatIconType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = switch (type) {
      FigmaFloatIconType.star => _floatStarSvg,
      FigmaFloatIconType.heart => _floatHeartSvg,
      FigmaFloatIconType.sparkle => _floatSparkleSvg,
      FigmaFloatIconType.flower => _floatFlowerSvg,
      FigmaFloatIconType.fire => _floatFireSvg,
      FigmaFloatIconType.diamond => _floatDiamondSvg,
    };
    return FigmaSvgIcon(svg: svg, size: size);
  }
}

class FigmaGameIcon extends StatelessWidget {
  const FigmaGameIcon({
    required this.gameId,
    required this.size,
    super.key,
  });

  final GameId gameId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = switch (gameId) {
      GameId.colorMatch => _colorPaletteSvg,
      GameId.numberGame => _numbersGameSvg,
      GameId.shapeMatch => _shapeMatchSvg,
      GameId.animalSound => _animalSoundSvg,
      GameId.simplePuzzle => _puzzleSvg,
      GameId.findDifferent => _findDifferentSvg,
      GameId.whackMole => _whackMoleSvg,
      GameId.memoryCard => _memoryCardSvg,
    };
    return FigmaSvgIcon(svg: svg, size: size);
  }
}

class FigmaMascotAvatar extends StatelessWidget {
  const FigmaMascotAvatar({
    required this.avatar,
    required this.size,
    super.key,
  });

  final String avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = switch (avatar) {
      '🦁' => _lionMascotSvg,
      '🐻' => _bearMascotSvg,
      '🐼' => _pandaMascotSvg,
      '🦊' => _foxMascotSvg,
      '🐥' => _chickMascotSvg,
      '🐸' => _frogMascotSvg,
      _ => _lionMascotSvg,
    };
    return FigmaSvgIcon(svg: svg, size: size);
  }
}

class FigmaLionMascotIcon extends StatelessWidget {
  const FigmaLionMascotIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _lionMascotSvg, size: size);
  }
}

class FigmaFoxMascotIcon extends StatelessWidget {
  const FigmaFoxMascotIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _foxMascotSvg, size: size);
  }
}

class FigmaChickMascotIcon extends StatelessWidget {
  const FigmaChickMascotIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return FigmaSvgIcon(svg: _chickMascotSvg, size: size);
  }
}

const _floatStarSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="fStarG" x1="14" y1="1" x2="14" y2="27" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF176" />
      <stop offset="100%" stop-color="#F4A200" />
    </linearGradient>
  </defs>
  <path d="M14 1.5 L16.9 10 L26 10 L18.8 15.3 L21.5 24 L14 18.8 L6.5 24 L9.2 15.3 L2 10 L11.1 10Z" fill="url(#fStarG)" stroke="#E08000" stroke-width="1.4" stroke-linejoin="round" />
  <ellipse cx="10.5" cy="6" rx="2.5" ry="1.4" fill="rgba(255,255,255,0.65)" transform="rotate(-30 10.5 6)" />
</svg>
''';

const _floatHeartSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="fHeartG" x1="14" y1="4" x2="14" y2="26" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF8FAB" />
      <stop offset="100%" stop-color="#E91E63" />
    </linearGradient>
  </defs>
  <path d="M14 24.5 C13.5 24 2.5 16.8 2.5 10 C2.5 6.5 5.2 3.8 8.5 3.8 C10.8 3.8 12.8 5.1 14 7 C15.2 5.1 17.2 3.8 19.5 3.8 C22.8 3.8 25.5 6.5 25.5 10 C25.5 16.8 14.5 24 14 24.5Z" fill="url(#fHeartG)" stroke="#C2185B" stroke-width="1.4" />
  <ellipse cx="8.5" cy="7.5" rx="2.5" ry="1.4" fill="rgba(255,255,255,0.6)" transform="rotate(-30 8.5 7.5)" />
</svg>
''';

const _floatSparkleSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="fSpkG" x1="14" y1="1" x2="14" y2="27" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#E8D5FF" />
      <stop offset="100%" stop-color="#9333EA" />
    </linearGradient>
  </defs>
  <path d="M14 1 L15.8 12.2 L27 14 L15.8 15.8 L14 27 L12.2 15.8 L1 14 L12.2 12.2Z" fill="url(#fSpkG)" stroke="#7B3FC4" stroke-width="1" stroke-linejoin="round" />
  <circle cx="14" cy="14" r="2.5" fill="rgba(255,255,255,0.55)" />
  <circle cx="5" cy="5" r="1.5" fill="#CE93D8" />
  <circle cx="23" cy="22" r="1.2" fill="#CE93D8" />
</svg>
''';

const _floatFlowerSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="14" cy="7.5" rx="4.8" ry="3.2" fill="#FFB7D6" stroke="#E91E63" stroke-width="0.9" transform="rotate(0 14 7.5)" />
  <ellipse cx="20.18" cy="11.99" rx="4.8" ry="3.2" fill="#FFB7D6" stroke="#E91E63" stroke-width="0.9" transform="rotate(72 20.18 11.99)" />
  <ellipse cx="17.82" cy="19.26" rx="4.8" ry="3.2" fill="#FFB7D6" stroke="#E91E63" stroke-width="0.9" transform="rotate(144 17.82 19.26)" />
  <ellipse cx="10.18" cy="19.26" rx="4.8" ry="3.2" fill="#FFB7D6" stroke="#E91E63" stroke-width="0.9" transform="rotate(216 10.18 19.26)" />
  <ellipse cx="7.82" cy="11.99" rx="4.8" ry="3.2" fill="#FFB7D6" stroke="#E91E63" stroke-width="0.9" transform="rotate(288 7.82 11.99)" />
  <circle cx="14" cy="14" r="4.5" fill="#FFE082" stroke="#F4A200" stroke-width="1.2" />
  <circle cx="12.5" cy="12.5" r="1.2" fill="rgba(255,255,255,0.7)" />
</svg>
''';

const _floatFireSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="fFireG1" x1="14" y1="2" x2="14" y2="28" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF5722" />
      <stop offset="100%" stop-color="#FF9800" />
    </linearGradient>
    <linearGradient id="fFireG2" x1="14" y1="9" x2="14" y2="27" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFE234" />
      <stop offset="100%" stop-color="#FF6D00" />
    </linearGradient>
  </defs>
  <path d="M14 1 C14 1 20.5 7.5 21 13.5 C21.5 19 18.5 23.5 14 27 C9.5 23.5 6.5 19 7 13.5 C7.5 7.5 14 1 14 1Z" fill="url(#fFireG1)" />
  <path d="M14 8 C14 8 18 13 18 17 C18 20.5 16.2 23.5 14 25 C11.8 23.5 10 20.5 10 17 C10 13 14 8 14 8Z" fill="url(#fFireG2)" />
  <ellipse cx="14" cy="19" rx="2.5" ry="3.5" fill="rgba(255,255,255,0.35)" />
</svg>
''';

const _floatDiamondSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="fDiamG" x1="14" y1="1" x2="14" y2="27" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#A8E4FF" />
      <stop offset="100%" stop-color="#0288D1" />
    </linearGradient>
  </defs>
  <path d="M14 2 L26 12 L14 26 L2 12Z" fill="url(#fDiamG)" stroke="#0277BD" stroke-width="1.5" stroke-linejoin="round" />
  <path d="M2 12 L14 2 L26 12 L14 8Z" fill="rgba(255,255,255,0.4)" />
  <path d="M10 10 L14 4 L18 10" fill="rgba(255,255,255,0.35)" />
</svg>
''';

String _backChevronSvg(String color) => '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M14.5 5.5 L8 12 L14.5 18.5" stroke="$color" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" />
</svg>
''';

const _lockSvg = r'''
<svg viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="lockBody" x1="20" y1="18" x2="20" y2="38" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#90A4AE" />
      <stop offset="100%" stop-color="#546E7A" />
    </linearGradient>
  </defs>
  <path d="M12 20 L12 13 C12 7.5 28 7.5 28 13 L28 20" fill="none" stroke="#78909C" stroke-width="4" stroke-linecap="round" />
  <rect x="8" y="19" width="24" height="19" rx="5" fill="url(#lockBody)" stroke="#37474F" stroke-width="2" />
  <circle cx="20" cy="28" r="4" fill="#263238" />
  <rect x="18.5" y="28" width="3" height="5" rx="1.5" fill="#263238" />
  <ellipse cx="14" cy="23" rx="3" ry="1.8" fill="rgba(255,255,255,0.3)" transform="rotate(-20 14 23)" />
</svg>
''';

const _downArrowSvg = r'''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4.5 8.5 L12 15.5 L19.5 8.5" stroke="#FFD93D" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" />
  <path d="M4.5 8.5 L12 15.5 L19.5 8.5" stroke="#C85000" stroke-opacity="0.25" stroke-width="4.4" stroke-linecap="round" stroke-linejoin="round" />
</svg>
''';

const _lightbulbSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bulbGlass" x1="14" y1="2" x2="14" y2="19" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF176" />
      <stop offset="100%" stop-color="#FFB300" />
    </linearGradient>
    <linearGradient id="bulbBase" x1="14" y1="18" x2="14" y2="27" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#B0BEC5" />
      <stop offset="100%" stop-color="#78909C" />
    </linearGradient>
  </defs>
  <path d="M14 2.5 C8.8 2.5 4.7 6.5 4.7 11.5 C4.7 14.6 6.2 17.1 8.4 18.7 C9.2 19.3 9.8 20.2 10.1 21.2 L17.9 21.2 C18.2 20.2 18.8 19.3 19.6 18.7 C21.8 17.1 23.3 14.6 23.3 11.5 C23.3 6.5 19.2 2.5 14 2.5Z" fill="url(#bulbGlass)" stroke="#E08000" stroke-width="1.6" />
  <rect x="10.2" y="20.5" width="7.6" height="4.2" rx="2.1" fill="url(#bulbBase)" stroke="#546E7A" stroke-width="1.3" />
  <rect x="10.9" y="24.1" width="6.2" height="2.2" rx="1.1" fill="#78909C" />
  <path d="M11.1 10.2 C12 8.7 14.1 7.9 16 8.4" stroke="rgba(255,255,255,0.65)" stroke-width="1.5" stroke-linecap="round" />
  <circle cx="8.2" cy="5.8" r="1.2" fill="#FF9AD5" />
  <circle cx="22.3" cy="7.4" r="1.2" fill="#42D4FF" />
</svg>
''';

const _punchFistSvg = r'''
<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9.2 11.2 C8.1 10.8 7.2 11.9 7.6 12.9 L9.9 19.5 C10.4 20.9 11.7 21.9 13.2 21.9 H18.8 C20.3 21.9 21.5 20.9 22.1 19.5 L23.3 16.3 C23.8 15 22.8 13.7 21.4 13.7 H19.8 V10.6 C19.8 9.5 18.4 9 17.7 9.9 L17.2 10.6 V8.8 C17.2 7.8 15.9 7.3 15.2 8.1 L14.2 9.3 V7.8 C14.2 6.8 12.9 6.3 12.2 7.1 L11 8.6 V8 C11 7 9.7 6.5 9 7.3 C8.7 7.6 8.6 8 8.6 8.4 V13 L9.2 11.2Z" fill="#FFB74D" stroke="#E65100" stroke-width="1.4" stroke-linejoin="round" />
  <path d="M9 12.7 H21.6" stroke="rgba(255,255,255,0.45)" stroke-width="1.2" stroke-linecap="round" />
  <circle cx="5.5" cy="15.4" r="1.2" fill="#FF8FAB" />
  <circle cx="4.1" cy="18.8" r="1.1" fill="#FFD93D" />
</svg>
''';

const _lionMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="lionMane" x1="28" y1="6" x2="28" y2="52" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFB300" />
      <stop offset="100%" stop-color="#E65100" />
    </linearGradient>
    <linearGradient id="lionFace" x1="28" y1="14" x2="28" y2="46" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFD54F" />
      <stop offset="100%" stop-color="#FFA000" />
    </linearGradient>
  </defs>
  <circle cx="28" cy="30" r="22" fill="url(#lionMane)" />
  <circle cx="11" cy="15" r="7" fill="#FF8F00" />
  <circle cx="11" cy="15" r="4.5" fill="#FFD54F" />
  <circle cx="45" cy="15" r="7" fill="#FF8F00" />
  <circle cx="45" cy="15" r="4.5" fill="#FFD54F" />
  <circle cx="28" cy="30" r="16" fill="url(#lionFace)" stroke="#E65100" stroke-width="1.5" />
  <ellipse cx="22" cy="23" rx="5" ry="3" fill="rgba(255,255,255,0.3)" transform="rotate(-20 22 23)" />
  <ellipse cx="22" cy="28" rx="3.5" ry="3.5" fill="white" />
  <circle cx="22" cy="28" r="2" fill="#3E2723" />
  <circle cx="22.7" cy="27.3" r="0.8" fill="white" />
  <ellipse cx="34" cy="28" rx="3.5" ry="3.5" fill="white" />
  <circle cx="34" cy="28" r="2" fill="#3E2723" />
  <circle cx="34.7" cy="27.3" r="0.8" fill="white" />
  <ellipse cx="28" cy="36" rx="8" ry="5.5" fill="#FFCC80" />
  <ellipse cx="28" cy="33" rx="3" ry="2" fill="#BF360C" />
  <ellipse cx="26.2" cy="33.5" rx="1" ry="0.7" fill="#7F2800" />
  <ellipse cx="29.8" cy="33.5" rx="1" ry="0.7" fill="#7F2800" />
  <path d="M23 37 Q28 41 33 37" fill="none" stroke="#BF360C" stroke-width="1.8" stroke-linecap="round" />
  <line x1="10" y1="34" x2="20" y2="35.5" stroke="#BF360C" stroke-width="1" opacity="0.5" />
  <line x1="10" y1="37" x2="20" y2="37" stroke="#BF360C" stroke-width="1" opacity="0.5" />
  <line x1="46" y1="34" x2="36" y2="35.5" stroke="#BF360C" stroke-width="1" opacity="0.5" />
  <line x1="46" y1="37" x2="36" y2="37" stroke="#BF360C" stroke-width="1" opacity="0.5" />
</svg>
''';

const _foxMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="foxFace" x1="28" y1="8" x2="28" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF8A65" />
      <stop offset="100%" stop-color="#E64A19" />
    </linearGradient>
  </defs>
  <path d="M12 26 L16 8 L26 22Z" fill="#E64A19" />
  <path d="M14 24 L17.5 12 L23.5 22Z" fill="#FF8A65" />
  <path d="M44 26 L40 8 L30 22Z" fill="#E64A19" />
  <path d="M42 24 L38.5 12 L32.5 22Z" fill="#FF8A65" />
  <ellipse cx="28" cy="32" rx="20" ry="20" fill="url(#foxFace)" />
  <path d="M14.5 23.5 L17.5 13 L23 21.5Z" fill="#FFCCBC" opacity="0.7" />
  <path d="M41.5 23.5 L38.5 13 L33 21.5Z" fill="#FFCCBC" opacity="0.7" />
  <ellipse cx="21" cy="24" rx="5" ry="3" fill="rgba(255,255,255,0.25)" transform="rotate(-20 21 24)" />
  <ellipse cx="28" cy="37" rx="11" ry="8" fill="white" opacity="0.9" />
  <ellipse cx="28" cy="37" rx="9" ry="6.5" fill="#FFF8F6" />
  <ellipse cx="21" cy="30" rx="4" ry="4" fill="white" />
  <circle cx="21" cy="30" r="2.5" fill="#1A237E" />
  <circle cx="21.8" cy="29.2" r="1" fill="white" />
  <ellipse cx="35" cy="30" rx="4" ry="4" fill="white" />
  <circle cx="35" cy="30" r="2.5" fill="#1A237E" />
  <circle cx="35.8" cy="29.2" r="1" fill="white" />
  <ellipse cx="28" cy="33" rx="2.8" ry="2" fill="#4E342E" />
  <ellipse cx="27" cy="32.3" rx="0.8" ry="0.5" fill="rgba(255,255,255,0.5)" />
  <path d="M23.5 37 Q28 41 32.5 37" fill="none" stroke="#BF360C" stroke-width="1.5" stroke-linecap="round" />
  <line x1="28" y1="33" x2="28" y2="37" stroke="#BF360C" stroke-width="1" opacity="0.5" />
  <line x1="9" y1="34" x2="19" y2="35" stroke="#BF360C" stroke-width="0.9" opacity="0.4" />
  <line x1="9" y1="37.5" x2="19" y2="37" stroke="#BF360C" stroke-width="0.9" opacity="0.4" />
  <line x1="47" y1="34" x2="37" y2="35" stroke="#BF360C" stroke-width="0.9" opacity="0.4" />
  <line x1="47" y1="37.5" x2="37" y2="37" stroke="#BF360C" stroke-width="0.9" opacity="0.4" />
</svg>
''';

const _chickMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="chickBody" x1="28" y1="12" x2="28" y2="52" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF176" />
      <stop offset="100%" stop-color="#FBC02D" />
    </linearGradient>
  </defs>
  <path d="M22 16 L24 8 M28 14 L28 6 M34 16 L32 8" fill="none" stroke="#FBC02D" stroke-width="3" stroke-linecap="round" />
  <ellipse cx="28" cy="34" rx="18" ry="18" fill="url(#chickBody)" />
  <ellipse cx="22" cy="27" rx="5" ry="3" fill="rgba(255,255,255,0.35)" transform="rotate(-20 22 27)" />
  <ellipse cx="22" cy="31" rx="3.5" ry="3.5" fill="white" />
  <circle cx="22" cy="31" r="2.2" fill="#263238" />
  <circle cx="22.8" cy="30.2" r="0.8" fill="white" />
  <ellipse cx="34" cy="31" rx="3.5" ry="3.5" fill="white" />
  <circle cx="34" cy="31" r="2.2" fill="#263238" />
  <circle cx="34.8" cy="30.2" r="0.8" fill="white" />
  <path d="M25 36 L28 40 L31 36Z" fill="#FF8F00" stroke="#E65100" stroke-width="1" />
  <ellipse cx="17" cy="35" rx="3" ry="2" fill="#FFAB00" opacity="0.6" />
  <ellipse cx="39" cy="35" rx="3" ry="2" fill="#FFAB00" opacity="0.6" />
  <ellipse cx="13" cy="38" rx="5.5" ry="3.5" fill="#FBC02D" transform="rotate(-25 13 38)" />
  <ellipse cx="43" cy="38" rx="5.5" ry="3.5" fill="#FBC02D" transform="rotate(25 43 38)" />
  <path d="M22 51 L20 54 M22 51 L22 54 M22 51 L24 54" stroke="#FF8F00" stroke-width="1.5" stroke-linecap="round" />
  <path d="M34 51 L32 54 M34 51 L34 54 M34 51 L36 54" stroke="#FF8F00" stroke-width="1.5" stroke-linecap="round" />
</svg>
''';

const _bearMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bearFace" x1="28" y1="10" x2="28" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#A1887F" />
      <stop offset="100%" stop-color="#5D4037" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="52" rx="16" ry="3" fill="rgba(0,0,0,0.08)" />
  <circle cx="12" cy="16" r="9" fill="#5D4037" />
  <circle cx="12" cy="16" r="6" fill="#BCAAA4" />
  <circle cx="44" cy="16" r="9" fill="#5D4037" />
  <circle cx="44" cy="16" r="6" fill="#BCAAA4" />
  <circle cx="28" cy="30" r="20" fill="url(#bearFace)" stroke="#3E2723" stroke-width="1.5" />
  <ellipse cx="21" cy="22" rx="5.5" ry="3" fill="rgba(255,255,255,0.2)" transform="rotate(-20 21 22)" />
  <ellipse cx="28" cy="37" rx="9.5" ry="7" fill="#BCAAA4" />
  <ellipse cx="21" cy="29" rx="4" ry="4" fill="white" />
  <circle cx="21" cy="29" r="2.5" fill="#1B0000" />
  <circle cx="21.8" cy="28.2" r="1" fill="white" />
  <ellipse cx="35" cy="29" rx="4" ry="4" fill="white" />
  <circle cx="35" cy="29" r="2.5" fill="#1B0000" />
  <circle cx="35.8" cy="28.2" r="1" fill="white" />
  <ellipse cx="28" cy="34" rx="3.5" ry="2.5" fill="#1B0000" />
  <ellipse cx="27" cy="33.2" rx="1" ry="0.7" fill="rgba(255,255,255,0.4)" />
  <path d="M23 38 Q28 42 33 38" fill="none" stroke="#3E2723" stroke-width="1.8" stroke-linecap="round" />
  <line x1="28" y1="34" x2="28" y2="38" stroke="#3E2723" stroke-width="1.2" opacity="0.5" />
  <ellipse cx="16" cy="35" rx="4" ry="2.5" fill="#FF8A65" opacity="0.5" />
  <ellipse cx="40" cy="35" rx="4" ry="2.5" fill="#FF8A65" opacity="0.5" />
</svg>
''';

const _pandaMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="28" cy="52" rx="16" ry="3" fill="rgba(0,0,0,0.08)" />
  <circle cx="12" cy="16" r="9" fill="#263238" />
  <circle cx="44" cy="16" r="9" fill="#263238" />
  <circle cx="28" cy="30" r="20" fill="white" stroke="#CFD8DC" stroke-width="1.5" />
  <ellipse cx="21" cy="22" rx="5" ry="3" fill="rgba(200,220,240,0.5)" transform="rotate(-20 21 22)" />
  <ellipse cx="20" cy="28" rx="6" ry="6.5" fill="#263238" transform="rotate(-15 20 28)" />
  <ellipse cx="36" cy="28" rx="6" ry="6.5" fill="#263238" transform="rotate(15 36 28)" />
  <ellipse cx="20" cy="28" rx="3.5" ry="3.5" fill="white" />
  <circle cx="20" cy="28" r="2.2" fill="#1B0000" />
  <circle cx="20.8" cy="27.2" r="0.9" fill="white" />
  <ellipse cx="36" cy="28" rx="3.5" ry="3.5" fill="white" />
  <circle cx="36" cy="28" r="2.2" fill="#1B0000" />
  <circle cx="36.8" cy="27.2" r="0.9" fill="white" />
  <ellipse cx="28" cy="37" rx="9" ry="6.5" fill="#F5F5F5" stroke="#E0E0E0" stroke-width="1" />
  <ellipse cx="28" cy="34" rx="2.8" ry="2" fill="#37474F" />
  <path d="M23 38.5 Q28 42.5 33 38.5" fill="none" stroke="#37474F" stroke-width="1.8" stroke-linecap="round" />
  <line x1="28" y1="34" x2="28" y2="38.5" stroke="#37474F" stroke-width="1.2" opacity="0.5" />
  <ellipse cx="17" cy="36" rx="3.5" ry="2.2" fill="#FF8A65" opacity="0.5" />
  <ellipse cx="39" cy="36" rx="3.5" ry="2.2" fill="#FF8A65" opacity="0.5" />
</svg>
''';

const _frogMascotSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="frogFace" x1="28" y1="12" x2="28" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#81C784" />
      <stop offset="100%" stop-color="#2E7D32" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="52" rx="15" ry="3" fill="rgba(0,0,0,0.08)" />
  <circle cx="18" cy="19" r="9" fill="#388E3C" />
  <circle cx="38" cy="19" r="9" fill="#388E3C" />
  <ellipse cx="28" cy="34" rx="21" ry="19" fill="url(#frogFace)" />
  <ellipse cx="20" cy="26" rx="5.5" ry="3" fill="rgba(255,255,255,0.25)" transform="rotate(-20 20 26)" />
  <circle cx="18" cy="19" r="7" fill="white" />
  <circle cx="38" cy="19" r="7" fill="white" />
  <circle cx="18" cy="19" r="4.5" fill="#1B5E20" />
  <circle cx="38" cy="19" r="4.5" fill="#1B5E20" />
  <circle cx="18" cy="19" r="2.8" fill="#0A1F0A" />
  <circle cx="38" cy="19" r="2.8" fill="#0A1F0A" />
  <circle cx="19.2" cy="17.8" r="1.2" fill="white" />
  <circle cx="39.2" cy="17.8" r="1.2" fill="white" />
  <ellipse cx="28" cy="39" rx="14" ry="9" fill="#A5D6A7" opacity="0.7" />
  <path d="M16 38 Q28 48 40 38" fill="none" stroke="#1B5E20" stroke-width="2.5" stroke-linecap="round" />
  <ellipse cx="24.5" cy="32" rx="1.5" ry="1" fill="#1B5E20" />
  <ellipse cx="31.5" cy="32" rx="1.5" ry="1" fill="#1B5E20" />
</svg>
''';

const _colorPaletteSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="paletteG" x1="0" y1="0" x2="56" y2="56" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF8F0" />
      <stop offset="100%" stop-color="#F5E6D3" />
    </linearGradient>
  </defs>
  <path d="M10 28 C10 14 44 8 46 22 C48 32 40 36 36 34 C28 30 20 36 18 40 C14 44 10 40 10 36 C10 33 10 30 10 28Z" fill="url(#paletteG)" stroke="#D7B89A" stroke-width="2.5" />
  <circle cx="22" cy="36" r="6" fill="white" stroke="#D7B89A" stroke-width="2.5" />
  <circle cx="18" cy="18" r="5.5" fill="#FF4B4B" stroke="#C0392B" stroke-width="1.5" />
  <circle cx="28" cy="13" r="5.5" fill="#4B9FFF" stroke="#1976D2" stroke-width="1.5" />
  <circle cx="38" cy="17" r="5.5" fill="#FFD93D" stroke="#F4A200" stroke-width="1.5" />
  <circle cx="42" cy="28" r="5.5" fill="#4BC96A" stroke="#2E7D32" stroke-width="1.5" />
  <circle cx="38" cy="38" r="5" fill="#A855F7" stroke="#6A0DAD" stroke-width="1.5" />
  <ellipse cx="16" cy="15.5" rx="2" ry="1.3" fill="rgba(255,255,255,0.6)" transform="rotate(-30 16 15.5)" />
  <ellipse cx="26" cy="10.5" rx="2" ry="1.3" fill="rgba(255,255,255,0.6)" transform="rotate(-30 26 10.5)" />
  <ellipse cx="36" cy="14.5" rx="2" ry="1.3" fill="rgba(255,255,255,0.6)" transform="rotate(-30 36 14.5)" />
</svg>
''';

const _numbersGameSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="numBg" x1="0" y1="0" x2="56" y2="56" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#E8F5E9" />
      <stop offset="100%" stop-color="#C8E6C9" />
    </linearGradient>
  </defs>
  <rect x="4" y="4" width="48" height="48" rx="14" fill="url(#numBg)" stroke="#A5D6A7" stroke-width="2.5" />
  <rect x="9" y="9" width="16" height="17" rx="6" fill="#FF7043" stroke="#C62828" stroke-width="1.8" />
  <text x="17" y="22" text-anchor="middle" fill="white" font-size="14" font-weight="900" font-family="Arial, sans-serif">1</text>
  <rect x="31" y="9" width="16" height="17" rx="6" fill="#42A5F5" stroke="#1565C0" stroke-width="1.8" />
  <text x="39" y="22" text-anchor="middle" fill="white" font-size="14" font-weight="900" font-family="Arial, sans-serif">2</text>
  <rect x="9" y="30" width="16" height="17" rx="6" fill="#AB47BC" stroke="#6A1B9A" stroke-width="1.8" />
  <text x="17" y="43" text-anchor="middle" fill="white" font-size="14" font-weight="900" font-family="Arial, sans-serif">3</text>
  <rect x="31" y="30" width="16" height="17" rx="6" fill="#26A69A" stroke="#00695C" stroke-width="1.8" />
  <circle cx="37" cy="38" r="2" fill="white" />
  <circle cx="43" cy="38" r="2" fill="white" />
  <circle cx="40" cy="34.5" r="2" fill="white" />
</svg>
''';

const _shapeMatchSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="shapeCircleG" x1="14" y1="22" x2="42" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFE082" />
      <stop offset="100%" stop-color="#F4A200" />
    </linearGradient>
  </defs>
  <path d="M28 4 L50 44 L6 44Z" fill="#FF8FAB" stroke="#C42070" stroke-width="2.5" stroke-linejoin="round" />
  <ellipse cx="22" cy="15" rx="4" ry="2.5" fill="rgba(255,255,255,0.45)" transform="rotate(-30 22 15)" />
  <circle cx="28" cy="36" r="14" fill="url(#shapeCircleG)" stroke="#C85000" stroke-width="2.5" />
  <ellipse cx="23" cy="30" rx="4" ry="2.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 23 30)" />
  <rect x="19" y="29" width="18" height="18" rx="4" fill="#80D8FF" stroke="#0288D1" stroke-width="2" transform="rotate(-8 28 38)" />
  <ellipse cx="22" cy="31" rx="3.5" ry="2" fill="rgba(255,255,255,0.45)" transform="rotate(-28 22 31)" />
</svg>
''';

const _animalSoundSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="pawG" x1="10" y1="10" x2="46" y2="46" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFAB91" />
      <stop offset="100%" stop-color="#E64A19" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="34" rx="14" ry="12" fill="url(#pawG)" stroke="#BF360C" stroke-width="2.5" />
  <ellipse cx="23" cy="29" rx="4.5" ry="3" fill="rgba(255,255,255,0.3)" transform="rotate(-20 23 29)" />
  <circle cx="16" cy="22" r="6" fill="#FF8A65" stroke="#BF360C" stroke-width="2" />
  <circle cx="26" cy="17" r="7" fill="#FF8A65" stroke="#BF360C" stroke-width="2" />
  <circle cx="37" cy="17" r="7" fill="#FF8A65" stroke="#BF360C" stroke-width="2" />
  <circle cx="46" cy="22" r="6" fill="#FF8A65" stroke="#BF360C" stroke-width="2" />
  <ellipse cx="14.5" cy="19.5" rx="2.2" ry="1.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 14.5 19.5)" />
  <ellipse cx="24.5" cy="14.5" rx="2.5" ry="1.7" fill="rgba(255,255,255,0.4)" transform="rotate(-20 24.5 14.5)" />
  <path d="M40 34 C42 31 42 37 40 34" fill="none" stroke="#1976D2" stroke-width="2" stroke-linecap="round" />
  <path d="M43 31 C47 27 47 41 43 37" fill="none" stroke="#1976D2" stroke-width="2" stroke-linecap="round" />
  <path d="M46 28 C52 23 52 44 46 39" fill="none" stroke="#1976D2" stroke-width="1.8" stroke-linecap="round" />
</svg>
''';

const _puzzleSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M6 6 L24 6 L24 14 C24 14 26 12 28 14 C30 16 28 18 28 18 L28 24 L6 24 L6 6Z" fill="#FF8FAB" stroke="#C42070" stroke-width="2" />
  <path d="M28 6 L50 6 L50 24 L28 24 L28 18 C28 18 30 16 28 14 C26 12 24 14 24 14 L24 6 Z" fill="#80D8FF" stroke="#0288D1" stroke-width="2" />
  <path d="M6 24 L28 24 L28 32 C28 32 26 30 24 32 C22 34 24 36 24 36 L24 50 L6 50 L6 24Z" fill="#A5D6A7" stroke="#2E7D32" stroke-width="2" />
  <path d="M28 24 L50 24 L50 50 L24 50 L24 36 C24 36 22 34 24 32 C26 30 28 32 28 32 Z" fill="#FFE082" stroke="#F57F17" stroke-width="2" />
  <ellipse cx="12" cy="9" rx="4" ry="2.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 12 9)" />
  <ellipse cx="36" cy="9" rx="4" ry="2.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 36 9)" />
  <ellipse cx="12" cy="30" rx="4" ry="2.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 12 30)" />
  <ellipse cx="36" cy="30" rx="4" ry="2.5" fill="rgba(255,255,255,0.4)" transform="rotate(-20 36 30)" />
</svg>
''';

const _rocketSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="rocketBody" x1="28" y1="4" x2="28" y2="40" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF9AD5" />
      <stop offset="100%" stop-color="#E040A0" />
    </linearGradient>
    <linearGradient id="rocketWindow" x1="23" y1="18" x2="33" y2="28" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#A8F0FF" />
      <stop offset="100%" stop-color="#42C8F5" />
    </linearGradient>
    <linearGradient id="flameOuter" x1="28" y1="38" x2="28" y2="54" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF6B35" />
      <stop offset="100%" stop-color="#FF9A3D" />
    </linearGradient>
    <linearGradient id="flameInner" x1="28" y1="40" x2="28" y2="52" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFE234" />
      <stop offset="100%" stop-color="#FFB300" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="46" rx="6" ry="9" fill="url(#flameOuter)" />
  <ellipse cx="28" cy="45" rx="3.5" ry="6" fill="url(#flameInner)" />
  <ellipse cx="28" cy="43" rx="1.8" ry="3.2" fill="white" opacity="0.7" />
  <path d="M20 30 L11 42 L20 38 Z" fill="#FFD54F" stroke="#C8960F" stroke-width="2.2" stroke-linejoin="round" />
  <path d="M18 32 L14 40 L18 38 Z" fill="rgba(255,255,255,0.35)" />
  <path d="M36 30 L45 42 L36 38 Z" fill="#FFD54F" stroke="#C8960F" stroke-width="2.2" stroke-linejoin="round" />
  <path d="M38 32 L42 40 L38 38 Z" fill="rgba(255,255,255,0.35)" />
  <path d="M28 4 C20 8 17 16 17 24 L17 36 L28 40 L39 36 L39 24 C39 16 36 8 28 4Z" fill="url(#rocketBody)" stroke="#C42070" stroke-width="2.5" stroke-linejoin="round" />
  <path d="M22 10 C20 14 19 19 19 24 L21 24 C21 20 22 15 24 12 Z" fill="rgba(255,255,255,0.38)" />
  <circle cx="28" cy="23" r="7.5" fill="white" stroke="#C42070" stroke-width="2" />
  <circle cx="28" cy="23" r="5.8" fill="url(#rocketWindow)" />
  <circle cx="28" cy="23" r="5.8" fill="none" stroke="#5BC8F5" stroke-width="1" />
  <ellipse cx="25.5" cy="20.5" rx="2.2" ry="1.5" fill="rgba(255,255,255,0.8)" transform="rotate(-30 25.5 20.5)" />
  <path d="M8 14 L9.2 17.6 L13 17.6 L10.1 19.8 L11.1 23.4 L8 21.2 L4.9 23.4 L5.9 19.8 L3 17.6 L6.8 17.6Z" fill="#FFD93D" stroke="#F4A200" stroke-width="1" transform="translate(0,-2) scale(0.75)" />
  <circle cx="44" cy="10" r="3" fill="#B56CF5" stroke="#7B3FC4" stroke-width="1.5" />
  <circle cx="43.2" cy="9.2" r="1" fill="rgba(255,255,255,0.7)" />
  <circle cx="7" cy="28" r="2.2" fill="#FF9AD5" stroke="#C42070" stroke-width="1.2" />
</svg>
''';

const _gameGridSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="tileRed" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox">
      <stop offset="0%" stop-color="#FF8FAB" />
      <stop offset="100%" stop-color="#E0294A" />
    </linearGradient>
    <linearGradient id="tileBlue" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox">
      <stop offset="0%" stop-color="#80D8FF" />
      <stop offset="100%" stop-color="#0288D1" />
    </linearGradient>
    <linearGradient id="tileGreen" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox">
      <stop offset="0%" stop-color="#A5D6A7" />
      <stop offset="100%" stop-color="#2E7D32" />
    </linearGradient>
    <linearGradient id="tileYellow" x1="0" y1="0" x2="1" y2="1" gradientUnits="objectBoundingBox">
      <stop offset="0%" stop-color="#FFE082" />
      <stop offset="100%" stop-color="#F57F17" />
    </linearGradient>
  </defs>
  <rect x="6" y="9" width="44" height="44" rx="14" fill="rgba(0,0,0,0.1)" />
  <rect x="4" y="6" width="44" height="44" rx="14" fill="white" stroke="#D0D8F0" stroke-width="2.5" />
  <rect x="9" y="11" width="17" height="17" rx="8" fill="url(#tileRed)" stroke="#C42070" stroke-width="2" />
  <path d="M17.5 14 L18.8 17.8 L22.8 17.8 L19.6 20 L20.7 23.8 L17.5 21.6 L14.3 23.8 L15.4 20 L12.2 17.8 L16.2 17.8Z" fill="#FFD93D" stroke="#F4A200" stroke-width="0.8" />
  <ellipse cx="14.5" cy="13.5" rx="2" ry="1.2" fill="rgba(255,255,255,0.45)" transform="rotate(-20 14.5 13.5)" />
  <rect x="30" y="11" width="17" height="17" rx="8" fill="url(#tileBlue)" stroke="#0277BD" stroke-width="2" />
  <path d="M40 14 L36.5 20 L39 20 L35 28 L40.5 21 L37.5 21Z" fill="#FFD93D" stroke="#F4A200" stroke-width="0.8" />
  <ellipse cx="32.5" cy="13.5" rx="2" ry="1.2" fill="rgba(255,255,255,0.45)" transform="rotate(-20 32.5 13.5)" />
  <rect x="9" y="32" width="17" height="17" rx="8" fill="url(#tileGreen)" stroke="#1B5E20" stroke-width="2" />
  <circle cx="17.5" cy="40.5" r="3.5" fill="#FFE082" stroke="#F57F17" stroke-width="1" />
  <ellipse cx="22" cy="40.5" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(0 22 40.5)" />
  <ellipse cx="19.75" cy="44.397" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(60 19.75 44.397)" />
  <ellipse cx="15.25" cy="44.397" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(120 15.25 44.397)" />
  <ellipse cx="13" cy="40.5" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(180 13 40.5)" />
  <ellipse cx="15.25" cy="36.603" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(240 15.25 36.603)" />
  <ellipse cx="19.75" cy="36.603" rx="2.5" ry="1.8" fill="#A5D6A7" stroke="#2E7D32" stroke-width="0.8" transform="rotate(300 19.75 36.603)" />
  <ellipse cx="11.5" cy="34.5" rx="2" ry="1.2" fill="rgba(255,255,255,0.45)" transform="rotate(-20 11.5 34.5)" />
  <rect x="30" y="32" width="17" height="17" rx="8" fill="url(#tileYellow)" stroke="#E65100" stroke-width="2" />
  <path d="M38.5 44 C38.5 44 31 38.5 31 35 C31 32.8 32.8 31 35 31 C36.4 31 37.6 31.8 38.5 33 C39.4 31.8 40.6 31 42 31 C44.2 31 46 32.8 46 35 C46 38.5 38.5 44 38.5 44Z" fill="#FF6CAE" stroke="#C42070" stroke-width="1.2" transform="translate(-0.5 0.5) scale(0.85) translate(5 4)" />
  <ellipse cx="32.5" cy="34.5" rx="2" ry="1.2" fill="rgba(255,255,255,0.45)" transform="rotate(-20 32.5 34.5)" />
</svg>
''';

const _trophySvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="trophyGold" x1="28" y1="8" x2="28" y2="38" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFE234" />
      <stop offset="100%" stop-color="#FF9A00" />
    </linearGradient>
    <linearGradient id="trophyBase" x1="18" y1="40" x2="38" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFD54F" />
      <stop offset="100%" stop-color="#F57F17" />
    </linearGradient>
    <linearGradient id="starGlow" x1="28" y1="2" x2="28" y2="18" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF176" />
      <stop offset="100%" stop-color="#FFD93D" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="50" rx="12" ry="3" fill="rgba(0,0,0,0.12)" />
  <rect x="17" y="41" width="22" height="6" rx="3" fill="url(#trophyBase)" stroke="#C85000" stroke-width="2" />
  <rect x="24" y="35" width="8" height="8" rx="2" fill="#FFD54F" stroke="#C85000" stroke-width="2" />
  <path d="M14 18 C8 18 7 26 13 28 L16 27" stroke="#F4A200" stroke-width="3" fill="none" stroke-linecap="round" />
  <path d="M42 18 C48 18 49 26 43 28 L40 27" stroke="#F4A200" stroke-width="3" fill="none" stroke-linecap="round" />
  <path d="M14 10 L14 27 C14 33 20 37 28 37 C36 37 42 33 42 27 L42 10 Z" fill="url(#trophyGold)" stroke="#C85000" stroke-width="2.5" stroke-linejoin="round" />
  <path d="M18 12 C17 15 17 20 18 25 L20 24 C19 19 19 15 20 13 Z" fill="rgba(255,255,255,0.45)" />
  <ellipse cx="28" cy="11" rx="8" ry="2.5" fill="rgba(255,255,255,0.3)" />
  <path d="M28 1 L30.4 7.8 L37.6 7.8 L32 11.8 L34 18.6 L28 14.6 L22 18.6 L24 11.8 L18.4 7.8 L25.6 7.8Z" fill="url(#starGlow)" stroke="#F4A200" stroke-width="1.8" />
  <ellipse cx="25.5" cy="5.5" rx="2" ry="1.2" fill="rgba(255,255,255,0.7)" transform="rotate(-30 25.5 5.5)" />
  <circle cx="46" cy="8" r="2.5" fill="#FF9AD5" stroke="#C42070" stroke-width="1.2" />
  <circle cx="45.4" cy="7.4" r="0.9" fill="rgba(255,255,255,0.7)" />
  <circle cx="10" cy="12" r="2" fill="#A8E4FF" stroke="#0288D1" stroke-width="1.2" />
  <path d="M48 22 L49 24 L51 25 L49 26 L48 28 L47 26 L45 25 L47 24Z" fill="#FFD93D" stroke="#F4A200" stroke-width="0.8" />
</svg>
''';

const _rainbowSvg = r'''
<svg viewBox="0 0 80 60" fill="none" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="10" cy="50" rx="10" ry="7" fill="white" />
  <ellipse cx="5" cy="46" rx="7" ry="5" fill="white" />
  <ellipse cx="70" cy="50" rx="10" ry="7" fill="white" />
  <ellipse cx="75" cy="46" rx="7" ry="5" fill="white" />
  <path d="M5 52 Q40 5 75 52" fill="none" stroke="#FF1744" stroke-width="5.5" stroke-linecap="round" />
  <path d="M8.5 52 Q40 11 71.5 52" fill="none" stroke="#FF9100" stroke-width="5.5" stroke-linecap="round" />
  <path d="M12 52 Q40 17 68 52" fill="none" stroke="#FFE234" stroke-width="5.5" stroke-linecap="round" />
  <path d="M15.5 52 Q40 23 64.5 52" fill="none" stroke="#00E676" stroke-width="5.5" stroke-linecap="round" />
  <path d="M19 52 Q40 29 61 52" fill="none" stroke="#2196F3" stroke-width="5.5" stroke-linecap="round" />
  <path d="M22.5 52 Q40 35 57.5 52" fill="none" stroke="#9C27B0" stroke-width="5" stroke-linecap="round" />
  <circle cx="40" cy="10" r="3" fill="white" opacity="0.85" />
  <circle cx="56" cy="17" r="2" fill="white" opacity="0.7" />
  <circle cx="24" cy="17" r="2" fill="white" opacity="0.7" />
</svg>
''';

const _targetSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="targetOuter" x1="28" y1="6" x2="28" y2="50" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF8FAB" />
      <stop offset="100%" stop-color="#E91E63" />
    </linearGradient>
    <linearGradient id="targetMid" x1="28" y1="12" x2="28" y2="44" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFE082" />
      <stop offset="100%" stop-color="#FFB300" />
    </linearGradient>
    <linearGradient id="targetInner" x1="28" y1="19" x2="28" y2="37" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#80D8FF" />
      <stop offset="100%" stop-color="#0288D1" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="52" rx="15" ry="3" fill="rgba(0,0,0,0.08)" />
  <circle cx="28" cy="28" r="19" fill="url(#targetOuter)" stroke="#C2185B" stroke-width="2.4" />
  <circle cx="28" cy="28" r="13" fill="white" stroke="#F8BBD9" stroke-width="2" />
  <circle cx="28" cy="28" r="8.5" fill="url(#targetMid)" stroke="#F57F17" stroke-width="2" />
  <circle cx="28" cy="28" r="4.5" fill="url(#targetInner)" stroke="#0277BD" stroke-width="1.8" />
  <path d="M38 18 L47 9" stroke="#7B3FC4" stroke-width="3" stroke-linecap="round" />
  <path d="M45.5 10.5 L49 7" stroke="#7B3FC4" stroke-width="3" stroke-linecap="round" />
  <path d="M47.5 5.5 L50.8 8.8 L48 11.6 L44.7 8.3 Z" fill="#B56CF5" stroke="#7B3FC4" stroke-width="1.4" stroke-linejoin="round" />
  <path d="M40.8 15.2 L44.6 19 L38 21.8 Z" fill="#FFD54F" stroke="#C85000" stroke-width="1.2" stroke-linejoin="round" />
  <ellipse cx="23" cy="18" rx="4.3" ry="2.2" fill="rgba(255,255,255,0.4)" transform="rotate(-25 23 18)" />
</svg>
''';

const _homeSvg = r'''
<svg viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="roof" x1="28" y1="8" x2="28" y2="30" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF8FAB" />
      <stop offset="100%" stop-color="#E91E63" />
    </linearGradient>
    <linearGradient id="wall" x1="10" y1="28" x2="46" y2="52" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF9E6" />
      <stop offset="100%" stop-color="#FFE082" />
    </linearGradient>
    <linearGradient id="door" x1="22" y1="36" x2="34" y2="52" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#CE93D8" />
      <stop offset="100%" stop-color="#7B1FA2" />
    </linearGradient>
  </defs>
  <ellipse cx="28" cy="53" rx="16" ry="3" fill="rgba(0,0,0,0.1)" />
  <rect x="9" y="28" width="38" height="24" rx="5" fill="url(#wall)" stroke="#E6A800" stroke-width="2.5" />
  <rect x="11" y="30" width="10" height="5" rx="2.5" fill="rgba(255,255,255,0.5)" />
  <path d="M5 30 L28 8 L51 30 Z" fill="url(#roof)" stroke="#C2185B" stroke-width="2.5" stroke-linejoin="round" />
  <path d="M14 28 L28 14 L42 28" stroke="rgba(255,255,255,0.4)" stroke-width="2" fill="none" stroke-linecap="round" />
  <path d="M20 27 L28 16 L32 21" stroke="rgba(255,255,255,0.5)" stroke-width="2.5" fill="none" stroke-linecap="round" />
  <rect x="12" y="32" width="11" height="10" rx="3.5" fill="#A8E4FF" stroke="#0288D1" stroke-width="2" />
  <line x1="17.5" y1="32" x2="17.5" y2="42" stroke="#0288D1" stroke-width="1.2" />
  <line x1="12" y1="37" x2="23" y2="37" stroke="#0288D1" stroke-width="1.2" />
  <ellipse cx="14.5" cy="34.5" rx="1.8" ry="1.2" fill="rgba(255,255,255,0.7)" transform="rotate(-30 14.5 34.5)" />
  <rect x="22" y="36" width="12" height="16" rx="6" fill="url(#door)" stroke="#4A148C" stroke-width="2" />
  <ellipse cx="28" cy="36" rx="6" ry="4" fill="url(#door)" stroke="#4A148C" stroke-width="2" />
  <circle cx="31" cy="45" r="1.8" fill="#FFD54F" stroke="#C85000" stroke-width="1.2" />
  <ellipse cx="25.5" cy="38.5" rx="1.5" ry="1" fill="rgba(255,255,255,0.4)" transform="rotate(-20 25.5 38.5)" />
  <circle cx="28" cy="9" r="5.5" fill="#FF6CAE" stroke="#C42070" stroke-width="2" />
  <path d="M28 13 C28 13 23.5 10 23.5 7.5 C23.5 6.1 24.6 5 26 5 C27 5 27.7 5.6 28 6.2 C28.3 5.6 29 5 30 5 C31.4 5 32.5 6.1 32.5 7.5 C32.5 10 28 13 28 13Z" fill="white" opacity="0.9" />
  <circle cx="7" cy="52" r="3" fill="#FF9AD5" stroke="#C42070" stroke-width="1.5" />
  <circle cx="7" cy="52" r="1.2" fill="#FFD93D" />
  <circle cx="48" cy="52" r="3" fill="#A5D6A7" stroke="#2E7D32" stroke-width="1.5" />
  <circle cx="48" cy="52" r="1.2" fill="#FFE082" />
</svg>
''';

const _sparkleStarSvg = r'''
<svg viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="starBody" x1="20" y1="2" x2="20" y2="38" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFF176" />
      <stop offset="100%" stop-color="#FFB300" />
    </linearGradient>
  </defs>
  <path d="M20 2 L23.5 13 L35.5 13 L25.8 20 L29.2 31 L20 24 L10.8 31 L14.2 20 L4.5 13 L16.5 13Z" fill="url(#starBody)" stroke="#F4A200" stroke-width="2" stroke-linejoin="round" />
  <ellipse cx="16" cy="8" rx="3.5" ry="2" fill="rgba(255,255,255,0.65)" transform="rotate(-30 16 8)" />
  <circle cx="31" cy="7" r="2.2" fill="#FF9AD5" stroke="#C42070" stroke-width="1.2" />
  <circle cx="30.4" cy="6.4" r="0.8" fill="rgba(255,255,255,0.7)" />
</svg>
''';

const _findDifferentSvg = r'''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="8" width="40" height="32" rx="14" fill="#DFFFF8" stroke="#0F9B8E" stroke-width="3" />
  <rect x="8.5" y="13" width="9" height="10" rx="4.5" fill="#63D4C2" />
  <rect x="19.5" y="13" width="9" height="10" rx="4.5" fill="#63D4C2" />
  <rect x="30.5" y="13" width="9" height="10" rx="4.5" fill="#FFCF5A" />
  <rect x="8.5" y="25" width="9" height="10" rx="4.5" fill="#63D4C2" />
  <rect x="19.5" y="25" width="9" height="10" rx="4.5" fill="#63D4C2" />
  <rect x="30.5" y="25" width="9" height="10" rx="4.5" fill="#63D4C2" />
  <circle cx="35" cy="18" r="2.2" fill="#FFFFFF" fill-opacity="0.55" />
</svg>
''';

const _whackMoleSvg = r'''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="24" cy="35" rx="15" ry="7" fill="#7C3F17" />
  <path d="M17 25C17 20.5817 20.5817 17 25 17H27C31.4183 17 35 20.5817 35 25V29H17V25Z" fill="#B7774E" />
  <circle cx="22" cy="26" r="2" fill="#2F1F18" />
  <circle cx="30" cy="26" r="2" fill="#2F1F18" />
  <path d="M22 31C24.6667 32.7778 27.3333 32.7778 30 31" stroke="#2F1F18" stroke-width="2.2" stroke-linecap="round" />
  <path d="M14 12.5L22.5 20" stroke="#FFB13C" stroke-width="4.8" stroke-linecap="round" />
  <rect x="9" y="8" width="8" height="8" rx="2.5" transform="rotate(-15 9 8)" fill="#FFD56C" stroke="#C97010" stroke-width="2" />
</svg>
''';

const _memoryCardSvg = r'''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="9" width="22" height="28" rx="8" fill="#FFE7F5" stroke="#E84AA5" stroke-width="3" />
  <rect x="17" y="13" width="22" height="28" rx="8" fill="#FFF7FC" stroke="#E84AA5" stroke-width="3" />
  <path d="M28 19.2C28.9 17.6 31.1 17.4 32.2 18.8C33.3 17.4 35.5 17.6 36.4 19.2C37.4 20.9 36.7 23 35.1 24.2L32.2 26.5L29.3 24.2C27.7 23 27 20.9 28 19.2Z" fill="#FF83BF" />
  <path d="M24.4 30.5L25.7 28.2L27 30.5L29.4 31.1L27.7 32.9L27.9 35.4L25.7 34.3L23.5 35.4L23.8 32.9L22.1 31.1L24.4 30.5Z" fill="#FFD54F" />
</svg>
''';
