class Degiskenler {
  static final Degiskenler _instance = Degiskenler._internal();
  int versionMenba = 0;
  List<dynamic> dinlemeListeleri=[];

  factory Degiskenler() {
    return _instance;
  }

  Degiskenler._internal();
}