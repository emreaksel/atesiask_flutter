import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

class AudioService {
  static AudioPlayer? _player;
  static BehaviorSubject<Duration>? _positionSubject;

  AudioService() {
    init();
  }

  AudioPlayer get player {
    if (_player == null) {
      throw Exception("AudioService has not been initialized.");
    }
    return _player!;
  }

  BehaviorSubject<Duration> get positionSubject {
    if (_positionSubject == null) {
      throw Exception("AudioService has not been initialized.");
    }
    return _positionSubject!;
  }

  static bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      );
      _player = AudioPlayer();
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      _positionSubject = BehaviorSubject<Duration>();

      _player!.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          // Handle playback completion
        }
        _positionSubject!.add(event.updatePosition);
      }, onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });

      _initialized = true;
    }
  }

  Future<void> setPlaylist(List<AudioSource> sources) async {
    try {
      await player.setAudioSource(ConcatenatingAudioSource(children: sources));
    } catch (e, stackTrace) {
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  void play() {
    player.play();
  }

  void pause() {
    player.pause();
  }
  void next() {
    player.seekToNext();
  }
  void previous() {
    player.seekToPrevious();
  }
  void dispose() {
    _player?.dispose();
    _positionSubject?.close();
    _initialized = false;
  }

// Add more methods as needed...
}
