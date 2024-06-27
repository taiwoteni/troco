import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playSound({required String sound}) async {
    await _audioPlayer.play(AssetSource(sound.substring(sound.indexOf("/")+1)));
  }
}
