import 'package:audio_session/audio_session.dart';
import 'package:bizidealcennetine/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

class AudioService {
  static AudioPlayer? _player;
  static BehaviorSubject<Duration>? _positionSubject;
  static String parca_adi="...";
  static String seslendiren="...";
  static List<MediaItem> parca_listesi=[];

  AudioInfoNotifier _audioInfoNotifier;
  AudioService(this._audioInfoNotifier);

  final currentSongTitleNotifier = ValueNotifier<String>('');

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
    _audioInfoNotifier.setTrackInfo(player.playing, parca_adi, seslendiren);
  }
  Future<void> play() async {
    await player.play();
  }
  Future<void> pause() async {
    await player.pause();
  }
  Future<void> play_pause() async {
    if(player.playing) pause();
    else play();
  }
  Future<void> next() async {
    await player.seekToNext();
  }
  void previous() {
    player.seekToPrevious();
  }
  void playAtIndex(int index) {
    if (index < 0 || index >= player.audioSource!.sequence.length) {
      print("Invalid index: $index");
      return;
    }

    player.seek(Duration.zero, index: index);
    play();
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
}


