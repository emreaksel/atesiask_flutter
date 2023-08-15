import 'dart:async';
import 'dart:js';

import 'package:bizidealcennetine/yaveran/Degiskenler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:text_scroll/text_scroll.dart';

import 'yaveran/HttpService.dart';
import 'yaveran/JsonHelper.dart';

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
              "./atesiask/bahar11.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0, // Alt boşluk
            left: 0, // Sol boşluk
            right: 0, // Sağ boşluk
            child: AkanYazi(),
          ),
        ],
      ),
    );
  }
}
class AkanYazi extends StatelessWidget {
  final String text ='« Kafandaki düşüncelerin aslında dışarıdaki kuş sesinden hiçbir farkı yok. Sadece bunların az ya da çok alakalı olduğuna sen karar veriyorsun...   »';
  //final String text ="Ates-i Aşk";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double yaziBoyutu = screenHeight * 0.019; // Yüksekliğin %5'i kadar bir yazı boyutu

    // Yazının kapladığı genişliği hesaplayın
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: yaziBoyutu)),
      textDirection: TextDirection.ltr,
    )..layout();

    double textWidth = painter.width;
    int targetLength = (textWidth / 3.34).toInt(); // Yazının genişlik oranına göre hedef uzunluk hesaplayın
    String finalText;

    if (screenWidth > textWidth) {
      finalText = text + ' ' * (screenWidth/3.9).toInt();
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

  StreamController<bool> _showDialogStreamController = StreamController<bool>();

  @override
  void dispose() {
    _showDialogStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Degiskenler(); // değişkenleri çağıralım
    arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
  }

  void arkaplanIslemleri() async {
    final Future<Map<String,dynamic>> jsonDataFuture = compute(getirMenba, "./kaynak/menba.json");

    jsonDataFuture.then((jsonDataMap) {
      // jsonDataMap'i burada kullanabilirsiniz
      _showDialogStreamController.add(true); // Diyaloğu göstermek için Stream'e true değeri gönder

      // 10 saniye sonra diyaloğu gizlemek için bir Timer kullanın
      /*Timer(Duration(seconds: 5), () {
        _showDialogStreamController.add(false);
      });*/
    });

    //print(result); // İşlem sonucunu burada kullanabilirsiniz
  }
  void closeDialog() {
    _showDialogStreamController.add(false);
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

Future<Map<String,dynamic>> getirMenba(String yol) async {
  final HttpService _httpService = HttpService();

  try {
    final jsonStr = await _httpService.fetchData(yol);
    final jsonDataList = JsonHelper.parseJson(jsonStr); // Bu satırı kullanmanıza gerek yok, veri zaten bir liste

    int versiyon = jsonDataList["versiyon"];
    print("versiyon: $versiyon");

    int dinlemeListesiID = jsonDataList["aktifliste"]["dinlemeListesiID"];
    print("dinlemeListesiID: $dinlemeListesiID");

    List<dynamic> dinlemeListeleri = jsonDataList["dinlemeListeleri"];
    for (var item in dinlemeListeleri) {
      int id = item["id"];
      String link = item["link"];
      String caption = item["caption"];
      String explanation = item["explanation"];

      print("id: $id, link: $link, caption: $caption, explanation: $explanation");
    }



    Degiskenler().versionMenba=versiyon;
    Degiskenler().dinlemeListeleri=dinlemeListeleri;
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
            onPressed: onClose, // onClose callback fonksiyonunu kullanarak diyaloğu kapat
            child: Text('Teşekkürler'),
          ),
        ],
      ),
    );
  }
}
