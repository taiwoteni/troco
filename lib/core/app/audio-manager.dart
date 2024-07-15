import 'package:audioplayers/audioplayers.dart';
import 'package:troco/core/app/asset-manager.dart';

class AudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final _ac = AudioContextConfig(
    route: AudioContextConfigRoute.system,
    focus: AudioContextConfigFocus.mixWithOthers,
    respectSilence: false,
  ).build();
  static final AssetSource sendSource = AssetSource(AssetManager.audioFile(name: "send").substring(AssetManager.audioFile(name: "send").indexOf("/")+1));
  static final AssetSource receiveSource = AssetSource(AssetManager.audioFile(name: "receive").substring(AssetManager.audioFile(name: "receive").indexOf("/")+1));


  static Future<void> playSound({required String sound}) async {
    _audioPlayer.setSourceAsset(sound.substring(sound.indexOf("/") + 1));
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setAudioContext(_ac);
    await _audioPlayer.resume();
  }

  static Future<void> playSource({required Source source}) async {
    _audioPlayer.setSource(source);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _audioPlayer.setAudioContext(_ac);
    await _audioPlayer.resume();
  }
}
