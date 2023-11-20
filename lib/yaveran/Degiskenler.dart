
import 'package:flutter/cupertino.dart';

class Degiskenler {
  static final Degiskenler _instance = Degiskenler._internal();
  int versionMenba = 0;

  static var hazirlaniyor=false;
  //String kaynakYolu=".";
  //String kaynakYolu="https://kardelendergisi.com/atesiask";
  static var kaynakYolu="https://raw.githubusercontent.com/emreaksel/atesiask/main/flutter";
  static var parcaIndex=-1;
  static var liste_link="baska";

  static var currentEpigramNotifier = ValueNotifier<String>('...');
  static var currentImageNotifier = ValueNotifier<String>('');
  static var songListNotifier = ValueNotifier<List<dynamic>>([]);
  static var currentNoticeNotifier = ValueNotifier<String>('Hoşgeldin Güzeller Güzelim...');
  static var showDialogNotifier = ValueNotifier<bool>(false);

  List<dynamic> dinlemeListeleri=[];
  List<dynamic> listSozler=[];
  List<dynamic> listDinle=[];
  List<dynamic> listFotograflar=[];
  /*final Map<String, List<VoidCallback>> _variableListeners = {};
  void addListenerForVariable(String variable, VoidCallback listener) {
    if (!_variableListeners.containsKey(variable)) {
      _variableListeners[variable] = [];
    }
    _variableListeners[variable]!.add(listener);
  }
  void removeListenerForVariable(String variable, VoidCallback listener) {
    _variableListeners[variable]?.remove(listener);
  }
  void notifyListenersForVariable(String variable) {
    _variableListeners[variable]?.forEach((listener) => listener());
  }*/

  factory Degiskenler() {
    return _instance;
  }

  Degiskenler._internal();
}