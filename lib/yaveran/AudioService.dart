import 'package:audio_session/audio_session.dart';
import 'package:bizidealcennetine/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

import 'Notifier.dart';

class AudioService {
  static AudioPlayer? _player;
  static BehaviorSubject<Duration>? _positionSubject;
  static String parca_adi="...";
  static String seslendiren="...";
  static List<MediaItem> parca_listesi=[];

  AudioInfoNotifier _audioInfoNotifier;
  AudioService(this._audioInfoNotifier);

  final currentSongTitleNotifier = ValueNotifier<String>('');

  //final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  //final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  static final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

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

      player.currentIndexStream.listen((index) {
        print("currentIndexStream $index");
        setCurrentTrack(index);

      });
      player.playerStateStream.listen((playerState) {

        final isPlaying = playerState.playing;
        final processingState = playerState.processingState;



        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          playButtonNotifier.value = ButtonState.loading;
        } else if (!isPlaying) {
          playButtonNotifier.value = ButtonState.paused;
        } else if (processingState != ProcessingState.completed) {
          playButtonNotifier.value = ButtonState.playing;
        } else {
          player.seek(Duration.zero);
          player.pause();
        }
        print("TEST playerStateStream: ${isPlaying} ${playButtonNotifier.value}");
      });
      _initialized = true;



    }
  }

  Future<void> setPlaylist(List<AudioSource> sources) async {
    try {
      await player.setAudioSource(ConcatenatingAudioSource(children: sources));
      parca_listesi=sources.cast<MediaItem>();
    } catch (e, stackTrace) {
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }
  setCurrentTrack(index){
    parca_adi=degiskenler.listDinle[index]["parca_adi"];
    seslendiren=degiskenler.listDinle[index]["seslendiren"];
    /*if (index >= 0 && index < parca_listesi.length) {
      // İstenilen index numarası geçerli bir aralıkta mı kontrol ediyoruz
      var desiredAudio = parca_listesi[index];
      //MediaItem mediaItem = desiredAudio. as MediaItem;
      //MediaItem mediaItem = desiredAudio.tag as MediaItem;

      print("Parça Adı: ${desiredAudio.title}");
      print("Seslendiren: ${desiredAudio.artist}");
      //print("URL: ${desiredAudio.uri}");
      print("Resim URL: ${desiredAudio.artUri}");
    } else {
      print("Geçersiz index numarası.");
    }*/
    // Güncellenen bilgileri AudioInfoNotifier aracılığıyla bildir
    //_audioInfoNotifier.setTrackInfo(player.playing, parca_adi, seslendiren);
  }
  Future<void> play() async {
    print("TEST play: ${player.playing}");
    await player.play();
    _audioInfoNotifier.setTrackInfo(true, parca_adi, seslendiren);
  }
  Future<void> pause() async {
    print("TEST pause: ${player.playing}");
    _audioInfoNotifier.setTrackInfo(false, parca_adi, seslendiren);
    await player.pause();

  }
  Future<void> play_pause() async {
    print("TEST play_pause: ${player.playing}");
    if(player.playing) await pause();
    else await play();
  }
  Future<void> next() async {
    await player.seekToNext();
    if (player.playing) {
      _audioInfoNotifier.setTrackInfo(true, parca_adi, seslendiren);
    } else {
      _audioInfoNotifier.setTrackInfo(false, parca_adi, seslendiren);
    }
  }
  Future<void> previous() async {
    await player.seekToPrevious();
    if (player.playing) {
      _audioInfoNotifier.setTrackInfo(true, parca_adi, seslendiren);
    } else {
      _audioInfoNotifier.setTrackInfo(false, parca_adi, seslendiren);
    }
  }
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= player.audioSource!.sequence.length) {
      print("Invalid index: $index");
      return;
    }

    await player.seek(Duration.zero, index: index);
    await play();
  }
  dynamic getCurrentTrackName() {
    print("Dinleniyor: ${parca_adi}");
    return parca_adi;
  }
  dynamic getCurrentTrackName2() {
    print("Dinleniyor: ${seslendiren}");
    return seslendiren;
  }

  void dispose() {
    _player?.dispose();
    _positionSubject?.close();
    _initialized = false;
  }

// Add more methods as needed...




  void onRepeatButtonPressed() {
    // TODO
  }

  void onPreviousSongButtonPressed() {
    // TODO
  }

  void onNextSongButtonPressed() {
    // TODO
  }

  void onShuffleButtonPressed() async {
    // TODO
  }
}

