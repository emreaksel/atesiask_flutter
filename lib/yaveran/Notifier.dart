import 'package:flutter/cupertino.dart';

class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  PlayButtonNotifier() : super(_initialValue);
  static const _initialValue = ButtonState.paused;
}
enum ButtonState { paused, playing, loading, }

class RepeatButtonNotifier extends ValueNotifier<RepeatState> {
  RepeatButtonNotifier() : super(_initialValue);
  static const _initialValue = RepeatState.off;

  void nextState() {
    final next = (value.index + 1) % RepeatState.values.length;
    value = RepeatState.values[next];
  }
}
enum RepeatState {
  off,
  repeatSong,
  repeatPlaylist,
}