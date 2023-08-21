import 'package:just_audio/just_audio.dart';
import 'AudioService.dart';

class AudioController {
  final AudioService _audioService = AudioService();

  void startAudio() {
    _audioService.player.play();
  }

  void pauseAudio() {
    _audioService.player.pause();
  }

  void seekAudio(Duration position) {
    _audioService.player.seek(position);
  }

  // Daha fazla işlev ekleyebilirsiniz...

  void dispose() {
    _audioService.dispose();
  }
}
