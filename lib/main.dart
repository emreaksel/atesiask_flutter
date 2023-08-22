import 'dart:async';
import 'dart:math';
import 'package:bizidealcennetine/yaveran/Degiskenler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:text_scroll/text_scroll.dart';

import 'yaveran/HttpService.dart';
import 'yaveran/JsonHelper.dart';
import 'yaveran/AudioService.dart';

final Degiskenler degiskenler = Degiskenler();
final AudioService _audioService = AudioService(); // AudioService nesnesini oluşturun
AkanYazi _akanYazi = AkanYazi("..."); // Varsayılan metni burada belirleyebilirsiniz
PlaybackControlsWidget _playbackControlsState=PlaybackControlsWidget();
ListeWidget _listeWidget= ListeWidget(initialSongList: [
  {"parca_adi": "Şarkı qqqqq"},
  {"parca_adi": "Şarkı 2"},
]);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: MyCustomLayout(),
        ),
      ),
    );
  }
}
class MyCustomLayout extends StatefulWidget {
  @override
  _MyCustomLayoutState createState() => _MyCustomLayoutState();
}
class KenBurnsViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          KenBurns(
            minAnimationDuration: Duration(milliseconds: 10000),
            maxAnimationDuration: Duration(milliseconds: 13000),
            maxScale: 1.3,
            child: Image.network(
              "${degiskenler.kaynakYolu}/atesiask/bahar11.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0, // Alt boşluk
            left: 0, // Sol boşluk
            right: 0, // Sağ boşluk
            child: _akanYazi,
          ),
        ],
      ),
    );
  }
}
class AkanYazi extends StatelessWidget {
  final String text;

  AkanYazi(this.text);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double yaziBoyutu =
        screenHeight * 0.019; // Yüksekliğin %5'i kadar bir yazı boyutu

    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: yaziBoyutu)),
      textDirection: TextDirection.ltr,
    )..layout();

    double textWidth = painter.width;
    int targetLength = (textWidth / 3.34)
        .toInt(); // Yazının genişlik oranına göre hedef uzunluk hesaplayın
    String finalText;

    if (screenWidth > textWidth) {
      finalText = text + ' ' * (screenWidth / 3.9).toInt();
    } else {
      int spacesToAdd = targetLength - text.length;
      finalText = text + ' ' * spacesToAdd;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.5),
      child: TextScroll(
        finalText,
        mode: TextScrollMode.endless,
        velocity: Velocity(pixelsPerSecond: Offset(50, 0)),
        delayBefore: Duration(milliseconds: 500),
        numberOfReps: 99999,
        pauseBetween: Duration(milliseconds: 50),
        style: TextStyle(color: Colors.white, fontSize: yaziBoyutu),
        textAlign: TextAlign.right,
        selectable: true,
      ),
    );
  }
}

class ListeWidget extends StatefulWidget {
  final List<dynamic> initialSongList;
  ListeWidget({required this.initialSongList});

  @override
  _ListeWidgetState createState() => _ListeWidgetState();
}
class _ListeWidgetState extends State<ListeWidget> {
  List<dynamic> songList = []; // Başlangıçta boş bir liste

  @override
  void initState() {
    super.initState();
    updateSongList();
    // Başlangıç şarkı listesini kullanarak güncelleme işlemi
    // Burada _audioService içinden şarkı listesini almayı deneyin
    // Örneğin: songList = _audioService.getSongList();
    // Burada _audioService'in kullanımına uygun şekilde şarkı listesini çekmelisiniz.
  }
  // Bu işlev, dışarıdan songList verisini güncellemek için kullanılır
  void updateSongList() {
    print("TEST updateSongList");
    setState(() {
      if (degiskenler.listDinle.isNotEmpty) {
        songList = degiskenler.listDinle;
      } else songList=widget.initialSongList;
      if (songList.isNotEmpty) print("songList0: ${songList[0]}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dinle')),
      ),
      body: ListView.builder(
        itemCount: songList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(songList[index]['parca_adi']),
            onTap: () {
              // Şarkıya tıklanıldığında yapılacak işlemleri burada gerçekleştirin
              // Örneğin, çalma işlemi veya şarkı ayrıntıları sayfasına yönlendirme
            },
          );
        },
      ),
    );
  }
}

class PlaybackControlsWidget extends StatefulWidget {
  const PlaybackControlsWidget({Key? key}) : super(key: key);

  @override
  _PlaybackControlsWidgetState createState() => _PlaybackControlsWidgetState();
}
class _PlaybackControlsWidgetState extends State<PlaybackControlsWidget> {
  bool isInitialized = false;

  Future<void> initializeAudioService() async {
    await _audioService.init();
    setState(() {
      isInitialized = true;
    });
  }
  void _togglePlayPause() {
    setState(() {
      if (_audioService.player.playing) {
        _audioService.pause(); // Eğer çalıyorsa duraklat, değilse oynat
      } else {
        _audioService.play(); // Çalmıyorsa oynat
      }
    });
  }

  int flexValue = 2; // Başlangıçta atanacak flex değeri
  void updateFlexValue() {
    setState(() {
      // Burada yeni bir flex değeri atayabilirsiniz
      flexValue = 1; // Örnek olarak yeni bir flex değeri atadık
    });
  }

  @override
  void initState() {
    //initializeAudioService(); // Ses servisi başlatma fonksiyonunu çağır
    super.initState();
  }
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    IconData playPauseIcon = _audioService.player.playing ? FontAwesomeIcons.pauseCircle : FontAwesomeIcons.playCircle;

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              updateFlexValue();
            },
            icon: const Icon(
              FontAwesomeIcons.list,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          IconButton(
            onPressed: () {
              // Previous aksiyonunu burada çağırabilirsiniz
              _audioService.previous();
            },
            icon: const Icon(
              FontAwesomeIcons.backwardStep,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          IconButton(
            onPressed: _togglePlayPause, // Fonksiyonu doğrudan atayın
            icon: Icon(
              playPauseIcon,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          IconButton(
            onPressed: () {
              // Next aksiyonunu burada çağırabilirsiniz
              _audioService.next();
            },
            icon: const Icon(
              FontAwesomeIcons.forwardStep,
              color: Colors.white,
              size: 36.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyCustomLayoutState extends State<MyCustomLayout> {
  final StreamController<bool> _showDialogStreamController = StreamController<bool>();

  @override
  void dispose() {
    _showDialogStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    degiskenler.addListenerForVariable("versionMenba", () => DegiskenlerListener("versionMenba",degiskenler.versionMenba));
    degiskenler.addListenerForVariable("listDinle", () => DegiskenlerListener("listDinle",degiskenler.listDinle));
    arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
  }
  void DegiskenlerListener(String tag,dynamic degisenDeger) {
    // Değişen değeri işleyin
    if (tag=="listDinle") {
      setPlaylist();
      setListeWidget();
    }
    //print("Değişen değer: $degisenDeger");
  }
  void closeDialog() {
    //Değişen değeri bildirerek listener'ları tetikleyin.
    //degiskenler.notifyListenersForVariable("versionMenba");
    _showDialogStreamController.add(false);

  }
  void setPlaylist() {

    List<AudioSource> playlist = [];

    for (var item in degiskenler.listDinle) {
      playlist.add(
        AudioSource.uri(
          Uri.parse(item['url']),
          tag: MediaItem(
            id: '${item['sira_no']}',
            album: item['parca_adi'],
            title: item['parca_adi'],
            artUri: Uri.parse(
              "${degiskenler.kaynakYolu}/atesiask/bahar.jpg",
            ),
            artist: item['seslendiren'],
          ),
        ),
      );
    }

    _audioService.setPlaylist(playlist);
  }
  void setListeWidget() {
    print("TEST setListeWidget");

    setState(() {
        _playbackControlsState=PlaybackControlsWidget();
        _listeWidget=ListeWidget(initialSongList:degiskenler.listDinle);
    });
  }
  void arkaplanIslemleri() async {

    final Future<Map<String, dynamic>> jsonMenba = compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/menba.json");
    final Future<Map<String, dynamic>> jsonSozler = compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/sozler.json");

    _showDialogStreamController.add(true); // Diyaloğu göstermek için Stream'e true değeri gönder
    // 10 saniye sonra diyaloğu gizlemek için bir Timer kullanın
    /*Timer(Duration(seconds: 5), () {
        _showDialogStreamController.add(false);
      });*/

    jsonSozler.then((jsonDataMap) {
      if (jsonDataMap.containsKey("sozler")) {
        final List<dynamic> sozlerListesi = jsonDataMap["sozler"];
        if (sozlerListesi.isNotEmpty) {
          final Random random = Random();
          final int randomIndex = random.nextInt(sozlerListesi.length);
          final String secilenSoz = sozlerListesi[randomIndex];
          _akanYazi=AkanYazi(secilenSoz);
          print("Rastgele Seçilen Söz: $secilenSoz");
        }
        else {
          print("Söz listesi boş.");
        }
      }
      else {
        print("Verilerde 'sozler' anahtarı bulunamadı.");
      }
    });
    jsonMenba.then((jsonData) {
      int versiyon = jsonData["versiyon"];
      //print("versiyon: $versiyon");

      int dinlemeListesiID = jsonData["aktifliste"]["dinlemeListesiID"];
      //print("dinlemeListesiID: $dinlemeListesiID");

      List<dynamic> dinlemeListeleri = jsonData["dinlemeListeleri"];
      for (var item in dinlemeListeleri) {
        int id = item["id"];
        String link = item["link"];
        String caption = item["caption"];
        String explanation = item["explanation"];
        if (id == dinlemeListesiID) {
          compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/$link.json").then((data) {
            degiskenler.listDinle=data["sesler"];
            degiskenler.notifyListenersForVariable("listDinle");

            //print(degiskenler.listDinle);
          });
        }
        //print("id: $id, link: $link, caption: $caption, explanation: $explanation");
      }

      degiskenler.versionMenba = versiyon;
      degiskenler.dinlemeListeleri = dinlemeListeleri;

      //print(jsonData["aktifliste"]);
    });

    //print(result); // İşlem sonucunu burada kullanabilirsiniz
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: KenBurnsViewWidget(),//KenBurnsViewWidget()
              ),
              Expanded(
                flex: 3,
                child: _listeWidget,//KenBurnsViewWidget()
              ),
              Expanded(
                flex: 4, // flex değeri güncel flexValue'ya göre ayarlandı,
                child: _playbackControlsState,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: StreamBuilder<bool>(
            stream: _showDialogStreamController.stream,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Align(
                  alignment: Alignment.center,
                  child: CustomDialog(onClose: closeDialog),
                );
              } else {
                return Container(); // Diyaloğu gizle
              }
            },
          ),
        ),
      ],
    );
  }


}

Future<Map<String, dynamic>> getirJsonData(String yol) async {
  final HttpService _httpService = HttpService();

  try {
    final jsonStr = await _httpService.fetchData(yol);
    final jsonDataList = JsonHelper.parseJson(jsonStr); // Bu satırı kullanmanıza gerek yok, veri zaten bir liste

    return jsonDataList; // Gelen veriyi doğrudan döndürüyoruz
  } catch (error) {
    throw Exception('Veri çekilirken bir hata oluştu: $error');
  }
}

class CustomDialog extends StatelessWidget {
  final VoidCallback onClose;

  CustomDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Aşk Olsun'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hoşgeldin Güzeller Güzelim...'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen, // Burada rengi ayarlıyoruz
            ),
            // onClose callback fonksiyonunu kullanarak diyaloğu kapat
            child: Text('Teşekkürler'),
          ),
        ],
      ),
    );
  }
}
