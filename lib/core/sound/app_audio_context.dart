import 'package:audioplayers/audioplayers.dart';

final AudioContext kiddoAudioContext = AudioContextConfig(
  route: AudioContextConfigRoute.system,
  focus: AudioContextConfigFocus.gain,
  respectSilence: false,
).build();
