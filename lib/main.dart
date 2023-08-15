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
  @override
  void initState() {
    super.initState();
    arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
  }

  void arkaplanIslemleri() async {
    NotificationData result = await compute(getirMenba, "https://raw.githubusercontent.com/emreaksel/atesiask/main/kaynak/menba.json");
    print(result); // İşlem sonucunu burada kullanabilirsiniz
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}


Future<NotificationData> getirMenba(String yol) async {
  final HttpService _httpService = HttpService(yol);

  try {
    final jsonStr = await _httpService.fetchData(yol);
    final jsonData = JsonHelper.parseJson(jsonStr);

    final notificationData = NotificationData.fromJson(jsonData);
    return notificationData;

  } catch (error) {
    throw Exception('Veri çekilirken bir hata oluştu: $error');
  }
}

class NotificationData {
  final int version;
  final Map<String, dynamic> notification;

  NotificationData({required this.version, required this.notification});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      version: json['versiyon'],
      notification: json['bildirim'],
    );
  }
}