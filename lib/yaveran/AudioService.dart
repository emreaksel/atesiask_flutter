import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioService() {
    _init();
  }

  Future<void> _init() async {
    // Ses oturumu oluştur
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Çalma olaylarını dinle
    _player.playbackEventStream.listen(
          (event) {
        // Çalma olaylarıyla ilgili işlemler burada gerçekleştirilebilir
      },
      onError: (Object e, StackTrace stackTrace) {
        print('Akış hatası oluştu: $e');
      },
    );

    try {
      // Ses kaynağını yükle (örneğin, bir URL'den)
      await _player.setAudioSource(AudioSource.uri(
          Uri.parse("https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")));
    } catch (e) {
      print("Ses kaynağı yüklenirken hata oluştu: $e");
    }
  }

  // Dışarıya _player nesnesine erişimi sağla
  AudioPlayer get player => _player;

  // Nesneyi yok et
  void dispose() {
    _player.dispose();
  }
}
