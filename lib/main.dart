import 'dart:async';
import 'dart:math';
import 'package:bizidealcennetine/yaveran/widgets.dart';
import 'package:bizidealcennetine/yaveran/Degiskenler.dart';
import 'package:bizidealcennetine/yaveran/Notifier.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:uni_links/uni_links.dart';
import 'yaveran/HttpService.dart';
import 'yaveran/JsonHelper.dart';
import 'yaveran/AudioService.dart';

final Degiskenler degiskenler = Degiskenler();
final AudioService _audioService =
    AudioService(); // AudioService nesnesini oluşturun
AkanYazi _akanYazi =
    AkanYazi("..."); // Varsayılan metni burada belirleyebilirsiniz

void main() {
  runApp(MyApp());
  if(!Degiskenler.hazirlaniyor) arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
  initUniLinks();
}

Future<void> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    final initialLink = await getInitialLink();
    print("initialLink $initialLink");
    if (initialLink!=null) {
      Degiskenler.currentNoticeNotifier.value=initialLink;
      Degiskenler.showDialogNotifier.value = true;
    }
    Degiskenler.currentNoticeNotifier.value='https://benolanben.com/dinle/baska&908';
    Degiskenler.showDialogNotifier.value = true;

    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope( //geri tuşunu dinlemek için
        onWillPop: () async {
          /*bool shouldExit = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Çıkmak istediğinize emin misiniz?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Hayır'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Evet'),
                  ),
                ],
              );
            },
          );*/
          FocusScope.of(context).unfocus(); // Klavyeyi gizler
          return true; // Geri tuşuna izin verir
        },

        child: MainScreen(),
      ),
    );
  }
}
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EkranBoyutNotifier()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: MyCustomLayout(),
          ),
        ),
      ),
    );
  }
}
class MyCustomLayout extends StatefulWidget {
  @override
  _MyCustomLayoutState createState() => _MyCustomLayoutState();
}
class _MyCustomLayoutState extends State<MyCustomLayout> {

  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ekranBoyutNotifier = Provider.of<EkranBoyutNotifier>(context);

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: ekranBoyutNotifier.ustEkranAktifIndex,
                  children: [
                    //ConfettiWidgetExample(),
                    KenBurnsViewWidget(),
                    ListeWidget(),
                    // Diğer widget'ları buraya ekleyebilirsiniz
                  ],
                ),
              ),
              AudioControlButtons(),
            ],
          ),
        ),
        Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: Degiskenler.showDialogNotifier,
                builder: (context, goster, child) {
                  return Visibility(
                    visible: goster,
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomDialog(icerik: Degiskenler.currentNoticeNotifier.value),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<ButtonState>( //mana yükleniyor
              valueListenable: AudioService.playButtonNotifier,
              builder: (context, value, child) {
                switch (value) {
                  case ButtonState.loading:
                    return Align(
                      alignment: Alignment.center,
                      child: LoadingWidget(),
                    );
                  default:
                    return Container(); // Diğer durumlarda bir şey gösterme
                }
              },
            ),
          ],
        ),

      ],
    );
  }
}
class LoadingWidget extends StatelessWidget {
  double calculateFontSize(BuildContext context, EkranBoyutNotifier ekranBoyutNotifier) {
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize =
        screenHeight * (ekranBoyutNotifier.altEkranBoyut / 100) * 0.11;
    return fontSize;
  }
  late EkranBoyutNotifier ekranBoyutNotifier;

  @override
  Widget build(BuildContext context) {
    ekranBoyutNotifier = Provider.of<EkranBoyutNotifier>(context, listen: true);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.57, // Yarı genişlik
        height: MediaQuery.of(context).size.height * 0.23, // Yarı yükseklik
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0), // Border radius ekleyin
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image.asset(
                  'assets/images/atesiask.jpg', // Kullanmak istediğiniz resmin yolunu belirtin
                  height: MediaQuery.of(context).size.height * 0.12, // Yarı yükseklik
                ),
                /*const Text(
                  'ATEŞ-İ AŞK  ', // Başlık metni
                  style: TextStyle(
                    fontSize: 21.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
              ],
            ),
            const SizedBox(height: 6.0), // Boşluk eklemek için

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Image.asset(
                    'assets/images/loading.gif', // Kullanmak istediğiniz resmin yolunu belirtin
                    height: MediaQuery.of(context).size.height * 0.05, // Yarı yükseklik
                  ),
                ),
                Text(
                  '  Mana Yükleniyor...', // Başlık metni
                  style: TextStyle(
                    fontSize: calculateFontSize(context, ekranBoyutNotifier),
                    color: Colors.white,
                    //fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class KenBurnsViewWidget extends StatefulWidget {
  @override
  _KenBurnsViewWidgetState createState() => _KenBurnsViewWidgetState();
}
class _KenBurnsViewWidgetState extends State<KenBurnsViewWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Siyah arka plan rengi
      child: Stack(
        children: [
          KenBurns(
            minAnimationDuration: Duration(milliseconds: 10000),
            maxAnimationDuration: Duration(milliseconds: 13000),
            maxScale: 1.3,
            child: Base64ImageWidget()
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

    String setEpigram(String text) {
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
      return finalText;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.5),
      child: ValueListenableBuilder<String>(
        valueListenable: Degiskenler.currentEpigramNotifier,
        builder: (_, title, __) {
          return TextScroll(
            setEpigram(title),
            // title değişkenini kullanmak istediğinizi varsayıyorum
            mode: TextScrollMode.endless,
            velocity: Velocity(pixelsPerSecond: Offset(50, 0)),
            delayBefore: Duration(milliseconds: 500),
            numberOfReps: 99999,
            pauseBetween: Duration(milliseconds: 50),
            style: TextStyle(color: Colors.white, fontSize: yaziBoyutu),
            textAlign: TextAlign.right,
            selectable: true,
          );
        },
      ),
    );
  }
}
class ListeWidget extends StatefulWidget {
  @override
  _ListeWidgetState createState() => _ListeWidgetState();
}
class _ListeWidgetState extends State<ListeWidget> {
  TextEditingController _searchController =
      TextEditingController(); // Arama çubuğu kontrolcüsü
  List<dynamic> filteredSongList = []; // Filtrelenmiş şarkı listesi
  String searchText = "";
  late EkranBoyutNotifier ekranBoyutNotifier;
  FocusNode _focusNode = FocusNode();
  Timer? _timer;

  @override
  void dispose() {
    _focusNode.dispose(); // Ekran kapatıldığında FocusNode'u temizle
    _timer?.cancel(); // Timer'ı iptal et
    super.dispose();
  }
  void _autoUnfocus() {
    // Belirli bir süre sonra klavyeyi kapat
    _timer?.cancel(); // Önceki Timer'ı iptal et
    _timer = Timer(Duration(seconds: 3), () {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    ekranBoyutNotifier = Provider.of<EkranBoyutNotifier>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dinle..')),
        actions: [
          // Arama çubuğunu ekliyoruz
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Arama çubuğuna tıklandığında bir şey yapabilirsiniz
              // Örneğin, arama işlemini başlatmak için burada bir işlev çağırabilirsiniz.
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Arama çubuğu yüksekliği
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: _focusNode, // FocusNode'u TextField'a atayın
              controller: _searchController, // Arama çubuğu kontrolcüsü
              onChanged: (value) {
                // Arama çubuğundaki değeri alın
                searchText = value
                    .toLowerCase(); // Aramayı küçük harfe çevirin (büyük/küçük harf duyarlılığı olmadan arama yapmak için)

                // Filtreleme işlemini gerçekleştirin ve sonucu yeni bir liste olarak saklayın
                List<dynamic> filteredList =
                    Degiskenler.songListNotifier.value.where((song) {
                  String songName = song['parca_adi']
                      .toLowerCase(); // Şarkı adını küçük harfe çevirin
                  String singerName = song['seslendiren']
                      .toLowerCase(); // Seslendiren adını küçük harfe çevirin
                  String replaceTurkishCharacters(String text) {
                    text = text.replaceAll("â", "a");
                    text = text.replaceAll("ş", "s");
                    text = text.replaceAll("ö", "o");
                    text = text.replaceAll("ü", "u");
                    text = text.replaceAll("ı", "i");
                    text = text.replaceAll("ç", "c");
                    text = text.replaceAll("ğ", "g");
                    return text;
                  }

                  // Şarkı adı veya seslendiren adı içinde aranan metni içeren öğeleri filtreleyin
                  return replaceTurkishCharacters(songName)
                          .contains(replaceTurkishCharacters(searchText)) ||
                      replaceTurkishCharacters(singerName)
                          .contains(replaceTurkishCharacters(searchText));
                }).toList();
                // Filtrelenmiş liste ile UI'yi güncelleyin
                setState(() {
                  filteredSongList = filteredList;
                });
                _autoUnfocus();
              },
              onTap: () {
                // TextField'a tıklandığında klavyenin otomatik kapanmasını iptal et
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                } else _autoUnfocus(); // Klavyeyi otomatik kapatmak için

              },
              decoration: InputDecoration(
                hintText: "Ara...", // Arama çubuğunda görüntülenen metin
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<dynamic>>(
        valueListenable: Degiskenler.songListNotifier,
        builder: (context, songList, child) {
          // Filtrelenmiş liste veya orijinal liste üzerinden dönün
          List<dynamic> displayList =
              filteredSongList.isNotEmpty ? filteredSongList : songList;
          displayList=displayList.reversed.toList();
          if (filteredSongList.isEmpty && searchText.isNotEmpty) {
            // Arama sonucunda eşleşen öğe yoksa hiçbir şey göstermeyin
            return Center(
              child: Text("Hiçbir sonuç bulunamadı."),
            );
          } //filter bulunamadı
          else {
            // Eşleşen öğeler varsa listeyi gösterin
            return ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text.rich(
                    TextSpan(
                      text: displayList[index]['parca_adi'], // Bu kısmı bold yapmak istiyoruz
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Metni kalın yapar
                      ),
                      children: [
                        TextSpan(
                          text: " [" + displayList[index]['seslendiren'] + "]",
                          style: TextStyle(
                            fontWeight: FontWeight.normal, // Normal kalınlıkta metin
                          ),
                        ),
                      ],
                    ),
                  ),
                  //leading: Image.asset('images/atesiask.png'), // Fotoğrafı ekleyin
                  onTap: () {
                    // Şarkıya tıklanıldığında yapılacak işlemleri burada gerçekleştirin
                    // Örneğin, çalma işlemi veya şarkı ayrıntıları sayfasına yönlendirme
                    _audioService.playAtId(displayList[index]['sira_no']);
                    ekranBoyutNotifier.ustEkranAktifIndex = 0;
                    ekranBoyutNotifier.altEkranBoyut = 20;
                    ekranBoyutNotifier.ustEkranBoyut = 80;
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String buttonText;
  final String icerik;

  CustomDialog({
    required this.icerik,
  }) : buttonText = icerik.contains('https://benolanben.com/dinle/') ? 'Dinle' : 'Teşekkürler';

  void closeDialog() {
    //Değişen değeri bildirerek listener'ları tetikleyin.
    Degiskenler.showDialogNotifier.value=false;
  }
  void hediye() {
    var hediye=icerik.replaceAll('https://benolanben.com/dinle/', '');
    var link=hediye.split('&')[0];
    var id=hediye.split('&')[1];
    if (link.isNotEmpty && id.isNotEmpty) {
      // Your code here when link and id are not empty
      print('Link: $link');
      print('ID: $id');
      _audioService.addTrackToPlaylist('adımız','sesimiz','https://www.mediafire.com/file/8srljirmndryh4l/secret_yemre.mp3',99999,);
    }
    else {
      // Your code here when link or id is empty
      print('Link or ID is empty.');
    }
    closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    String noticeText = icerik.contains('https://benolanben.com/dinle/') ? ' Dinle! Hediyeyi Duyacaksın' : icerik;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.59, // Yarı genişlik
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0), // Border radius ekleyin
          color: Colors.black,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:9.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Image.asset(
                    'assets/images/atesiask.jpg', // Kullanmak istediğiniz resmin yolunu belirtin
                    height: MediaQuery.of(context).size.height * 0.12, // Yarı yükseklik
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0), // Boşluk eklemek için
            //Text('),
            Padding(
              padding: EdgeInsets.all(16.0), // Yastıklama (padding) ekleyin
              child: SelectableText(
                noticeText,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: ElevatedButton(
                onPressed: () async {
                  if(icerik.contains('https://benolanben.com/dinle/')){
                    hediye();
                  }
                  else {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('bildirim_goster', true);
                    closeDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0), // Padding ekleyin
                  child: Text(buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void arkaplanIslemleri() async {
  Degiskenler.hazirlaniyor=true;
  _audioService.init();

  print("${Degiskenler.kaynakYolu}/kaynak/menba.json");
  final Future<Map<String, dynamic>> jsonMenba =
      compute(getirJsonData, "${Degiskenler.kaynakYolu}/kaynak/menba.json");
  final Future<Map<String, dynamic>> jsonSozler =
      compute(getirJsonData, "${Degiskenler.kaynakYolu}/kaynak/sozler.json");
  final Future<Map<String, dynamic>> jsonFotograflar = compute(
      getirJsonData, "${Degiskenler.kaynakYolu}/kaynak/fotograflar.json");

  //_showDialogStreamController.add(true); // Diyaloğu göstermek için Stream'e true değeri gönder
  // 10 saniye sonra diyaloğu gizlemek için bir Timer kullanın
  /*Timer(Duration(seconds: 5), () {
        _showDialogStreamController.add(false);
      });*/
  jsonFotograflar.then((jsonDataMap) {
    if (jsonDataMap.containsKey("fotograflar")) {
      final List<dynamic> fotograflarListesi = jsonDataMap["fotograflar"];
      if (fotograflarListesi.isNotEmpty) {
        /*final Random random = Random();
        final int randomIndex = random.nextInt(fotograflarListesi.length);
        final String secilen = fotograflarListesi[randomIndex]['path'];
        Degiskenler.currentImageNotifier.value = secilen;*/
        //print("Rastgele Seçilen fotograf: $secilen");
        //print('Bu bir log mesajıdır.');
        //print(logMessage);
        degiskenler.listFotograflar = fotograflarListesi;
      }
      else {
        print("fotograf listesi boş.");
      }
    }
    else {
      print("Verilerde 'fotograf' anahtarı bulunamadı.");
    }
  });
  jsonSozler.then((jsonDataMap) {
    if (jsonDataMap.containsKey("sozler")) {
      final List<dynamic> sozlerListesi = jsonDataMap["sozler"];
      if (sozlerListesi.isNotEmpty) {
        /*final Random random = Random();
        final int randomIndex = random.nextInt(sozlerListesi.length);
        final String secilenSoz = sozlerListesi[randomIndex];
        Degiskenler.currentEpigramNotifier.value = secilenSoz;
        print("Rastgele Seçilen Söz: $secilenSoz");*/
        degiskenler.listSozler = sozlerListesi;
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
        Degiskenler.liste_link=link;
        compute(getirJsonData, "${Degiskenler.kaynakYolu}/kaynak/$link.json")
            .then((data) {
          List<dynamic> listDinle = data["sesler"];
          //setPlaylist(listDinle.reversed.toList());
          setPlaylist(listDinle);
          //print(degiskenler.listDinle);
        });
      }
      //print("id: $id, link: $link, caption: $caption, explanation: $explanation");
    }

    Map<String, dynamic> bildirim = jsonData["bildirim"];
    bildirimKontrol(bildirim);

    degiskenler.versionMenba = versiyon;
    degiskenler.dinlemeListeleri = dinlemeListeleri;

    //print(jsonData["aktifliste"]);
  });

  Degiskenler.hazirlaniyor=false;
  //print(result); // İşlem sonucunu burada kullanabilirsiniz
}
void setPlaylist(data) {
  //print("LAVANTA ${data[0]}");

  degiskenler.listDinle = data;
  Degiskenler.songListNotifier.value = data;

  List<AudioSource> playlist = [];
  for (var item in data) {
    //print("LAVANTA ${item}");

    playlist.add(
      AudioSource.uri(
        Uri.parse(item['url']),
        tag: MediaItem(
          id: '${item['sira_no']}',
          album: item['parca_adi'],
          title: item['parca_adi'],
          artUri: Uri.parse(
            "${Degiskenler.kaynakYolu}/atesiask/bahar11.jpg",
          ),
          artist: item['seslendiren'],
        ),
      ),
    );
  }

  _audioService.setPlaylist(playlist);
}
void bildirimKontrol(bildirim) async {
  String vakit1Str = bildirim["vakit1"];
  String vakit2Str = bildirim["vakit2"];

  // Veriyi ayrıştırma işlevi
  DateTime parseDateTime(String dateStr) {
    List<String> parts = dateStr.split(" "); // Boşluğa göre böleriz
    List<String> dateParts = parts[0].split("/"); // Tarihi ayırırız
    List<String> timeParts = parts[1].split(":"); // Saati ayırırız

    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }

  DateTime vakit1 = parseDateTime(vakit1Str);
  DateTime vakit2 = parseDateTime(vakit2Str);

  DateTime now = DateTime.now().toUtc(); // Şu anki tarihi UTC saat dilimine çevir
  DateTime suAn = now.add(Duration(hours: 3)); // 3 saat ekleyerek gelecekteki bir zamanı hesapla

  //print("KONTROLL $suAn ==> $vakit1, $vakit2");

  if (suAn.isAfter(vakit1) && suAn.isBefore(vakit2)) { //bildirim zamanında mıyız
    print("Bildirim ==> Şu an vakit1 ve vakit2 arasında.");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? yanit = prefs.getString('bildirim') ?? "bos"; // Eğer değer yoksa false kullan
    if (yanit.isNotEmpty && yanit!=bildirim["metin"]){
      if(!Degiskenler.currentNoticeNotifier.value.contains('https://benolanben.com/dinle/')) {
        Degiskenler.currentNoticeNotifier.value = bildirim["metin"];
        Degiskenler.showDialogNotifier.value = true;
      }
    }

  }
  else {
    print("Bildirim ==> Şu an vakit1 ve vakit2 arasında değil.");
  }
}
Future<Map<String, dynamic>> getirJsonData(String yol) async {
  final HttpService _httpService = HttpService();
  print("getirJsonData $yol");

  try {
    final jsonStr = await _httpService.fetchData(yol);

    final jsonDataList = JsonHelper.parseJson(
        jsonStr); // Bu satırı kullanmanıza gerek yok, veri zaten bir liste
    return jsonDataList; // Gelen veriyi doğrudan döndürüyoruz
  } catch (error) {
    throw Exception('Veri çekilirken bir hata oluştu: $error');
  }
}

class Base64ImageWidget extends StatefulWidget {
  @override
  _Base64ImageWidgetState createState() => _Base64ImageWidgetState();
}
class _Base64ImageWidgetState extends State<Base64ImageWidget> {
  Uint8List? _imageBytes;
  String? _currentImageUrl; // Bu, mevcut imageUrl'i saklamak için kullanılır.
  @override
  void initState() {
    super.initState();
  }
  Future<void> _downloadImage(imageUrl) async {
    final HttpService _httpService = HttpService();
    try {
      final responseBytes = await _httpService.fetchBytes("https://kardelendergisi.com/atesiask/atesiask/$imageUrl");
      setState(() {
        _imageBytes = responseBytes;
        _currentImageUrl = imageUrl; // imageUrl'i güncelle
      });
    } catch (e) {
      print('Resim indirme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Degiskenler.currentImageNotifier,
      builder: (context, imageUrl, child) {
        //print("yeni resim yolu $imageUrl");
        // Eğer imageUrl önceki ile aynı ise ve _imageBytes doluysa, mevcut resmi göster
        if (_currentImageUrl == imageUrl && _imageBytes != null) {
          return Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          );
        }
        else {
          if (imageUrl.contains(".jpg") || imageUrl.contains(".png")){
            // Değişiklik varsa veya _imageBytes null ise resmi indir
            _downloadImage(imageUrl);
            return _imageBytes != null
                ? Image.memory(
              _imageBytes!,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/images/loading.gif', // Kullanmak istediğiniz resmin yolunu belirtin
              height: MediaQuery.of(context).size.height * 0.05, // Yarı yükseklik
            );
          }
          else return Image.asset(
            'assets/images/loading.gif', // Kullanmak istediğiniz resmin yolunu belirtin
            height: MediaQuery.of(context).size.height * 0.05, // Yarı yükseklik
          );

        }
      },
    );
  }
}

enum ConfettiShape { circle, heart, diamond, star }
class ConfettiWidgetExample extends StatefulWidget {
  @override
  _ConfettiWidgetExampleState createState() => _ConfettiWidgetExampleState();
}
class _ConfettiWidgetExampleState extends State<ConfettiWidgetExample> {
  late ConfettiController _controllerCenter;
  late ConfettiShape _selectedShape;

  final _shapes = [
    ConfettiShape.circle,
    ConfettiShape.heart,
    ConfettiShape.diamond,
    ConfettiShape.star,
  ];

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _selectedShape = _shapes[0];
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  void _startConfetti(ConfettiShape shape, ConfettiController controller) {
    controller.play();
    setState(() {
      _selectedShape = shape;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            gravity: 0.001,
            colors: [Color(0xFFFF0000)],
            // Sadece kırmızı renk kullanacak
            numberOfParticles: 10,
            // Konfeti parçacık sayısı
            createParticlePath: _drawShape, // Seçilen şekli kullan
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _startConfetti(_shapes[1], _controllerCenter),
                child: Text('Kalp'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Path _drawShape(Size size) {
    switch (_selectedShape) {
      case ConfettiShape.circle:
        return _drawCircle(size);
      case ConfettiShape.heart:
        return _drawHeart(size);
      case ConfettiShape.diamond:
        return _drawDiamond(size);
      case ConfettiShape.star:
        return _drawStar(size);
      default:
        return _drawCircle(size);
    }
  }

  Path _drawCircle(Size size) {
    final path = Path();
    path.addOval(Rect.fromCenter(
        center: size.center(Offset.zero), width: 20, height: 20));
    return path;
  }

  Path _drawHeart(Size size) {
    final path = Path();
    final x = size.width / 2;
    final y = size.height / 2;
    final step = size.width / 40;
    path.moveTo(x, y);
    // Sol yarı kalp
    for (double angle = 0; angle < pi; angle += 0.01) {
      final dx = 16 * pow(sin(angle), 3);
      final dy = -(13 * cos(angle) -
          5 * cos(2 * angle) -
          2 * cos(3 * angle) -
          cos(4 * angle));
      path.lineTo(x - dx * step, y - dy * step);
    }
    // Sağ yarı kalp
    for (double angle = 0; angle < pi; angle += 0.01) {
      final dx = 16 * pow(sin(angle), 3);
      final dy = -(13 * cos(angle) -
          5 * cos(2 * angle) -
          2 * cos(3 * angle) -
          cos(4 * angle));
      path.lineTo(x + dx * step, y - dy * step);
    }
    return path;
  }

  Path _drawDiamond(Size size) {
    final path = Path();
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    path.moveTo(halfWidth, 0);
    path.lineTo(size.width, halfHeight);
    path.lineTo(halfWidth, size.height);
    path.lineTo(0, halfHeight);
    path.close();

    return path;
  }

  Path _drawStar(Size size) {
    final path = Path();
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    path.moveTo(halfWidth, 0);
    path.lineTo(halfWidth + size.width * 0.05, halfHeight - size.height * 0.2);
    path.lineTo(size.width, halfHeight - size.height * 0.3);
    path.lineTo(halfWidth + size.width * 0.3, halfHeight + size.height * 0.1);
    path.lineTo(halfWidth + size.width * 0.5, size.height);
    path.lineTo(halfWidth, halfHeight + size.height * 0.4);
    path.lineTo(halfWidth - size.width * 0.5, size.height);
    path.lineTo(halfWidth - size.width * 0.3, halfHeight + size.height * 0.1);
    path.lineTo(0, halfHeight - size.height * 0.3);
    path.lineTo(halfWidth - size.width * 0.05, halfHeight - size.height * 0.2);
    path.close();

    return path;
  }
}

