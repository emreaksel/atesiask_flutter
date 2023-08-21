import 'dart:async';
import 'dart:math';
import 'package:bizidealcennetine/yaveran/Degiskenler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:text_scroll/text_scroll.dart';

import 'yaveran/HttpService.dart';
import 'yaveran/JsonHelper.dart';
import 'yaveran/AudioService.dart';
import 'yaveran/AudioController.dart';

AkanYazi akanYazi = AkanYazi("..."); // Varsayılan metni burada belirleyebilirsiniz
final Degiskenler degiskenler = Degiskenler();

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
            child: akanYazi,
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
void updateAkanYazi(String newText) {
  akanYazi = AkanYazi(newText);
}
class PlaybackControlsWidget extends StatelessWidget {
  const PlaybackControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // Implement your rewind action here
            },
            icon: const Icon(
              FontAwesomeIcons.backwardStep,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          IconButton(
            onPressed: () {
              // Implement your play/pause action here
            },
            icon: const Icon(
              FontAwesomeIcons.circlePlay,
              color: Colors.white,
              size: 36.0,
            ),
          ),
          IconButton(
            onPressed: () {
              // Implement your fast forward action here
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
  final AudioService _audioService = AudioService();
  final AudioController _audioController = AudioController();

  @override
  void dispose() {
    _showDialogStreamController.close();
    _audioService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    degiskenler.addListenerForVariable("versionMenba", () => DegiskenlerListener(degiskenler.versionMenba));
    degiskenler.addListenerForVariable("kaynakYolu", () => DegiskenlerListener(degiskenler.kaynakYolu));
    arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
  }
  void DegiskenlerListener(dynamic degisenDeger) {
    // Değişen değeri işleyin
    print("Değişen değer: $degisenDeger");
  }
  void closeDialog() {
    //degiskenler.versionMenba=13254;
    //Değişen değeri bildirerek listener'ları tetikleyin.
    //degiskenler.notifyListenersForVariable("versionMenba");
    _audioController.startAudio();
    _showDialogStreamController.add(false);
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
          updateAkanYazi(secilenSoz);
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
                flex: 8,
                child: KenBurnsViewWidget(),
              ),
              Expanded(
                flex: 2,
                child: PlaybackControlsWidget(),
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
