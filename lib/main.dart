import 'dart:async';
import 'dart:math';
import 'package:bizidealcennetine/yaveran/widgets_audio.dart';
import 'package:bizidealcennetine/yaveran/Degiskenler.dart';
import 'package:bizidealcennetine/yaveran/Notifier.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kenburns_nullsafety/kenburns_nullsafety.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';
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
  arkaplanIslemleri(); // Uygulama başladığında hemen çalıştır
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(), //SplashScreen(),
      /*Scaffold(
        body: SafeArea(
          child: MyCustomLayout(),
        ),
      ),*/
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
  final StreamController<bool> _showDialogStreamController =
      StreamController<bool>();

  @override
  void dispose() {
    _showDialogStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void closeDialog() {
    //Değişen değeri bildirerek listener'ları tetikleyin.
    //degiskenler.notifyListenersForVariable("versionMenba");
    _showDialogStreamController.add(false);
  }

  @override
  Widget build(BuildContext context) {
    final ekranBoyutNotifier = Provider.of<EkranBoyutNotifier>(context);

    return Stack(
      children: [
        /*Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Expanded(
                flex: ekranBoyutNotifier.ustEkranBoyut,
                child: IndexedStack(
                  index: ekranBoyutNotifier.ustEkranAktifIndex,
                  children: [
                    KenBurnsViewWidget(),
                    _listeWidget,
                    // Diğer widget'ları buraya ekleyebilirsiniz
                  ],
                ),
              ),
              Expanded(
                flex: ekranBoyutNotifier.altEkranBoyut,
                // flex değeri güncel flexValue'ya göre ayarlandı,
                child: AudioControlButtons(),
              ),
            ],
          ),
        ),*/
        Container(
          color: Colors.transparent,
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

/*
class KenBurnsViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          KenBurns(
            minAnimationDuration: Duration(milliseconds: 10000),
            maxAnimationDuration: Duration(milliseconds: 13000),
            maxScale: 1.3,
            child: IndexedStack(
              index: fotosira,
              children:
              [
                CachedNetworkImage(
                  imageUrl:
                      "https://kardelendergisi.com/atesiask/atesiask/bahar.jpg",
                  placeholder: (context, url) => CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                CachedNetworkImage(
                  imageUrl:
                      "https://kardelendergisi.com/atesiask/atesiask/bahar.jpg",
                  placeholder: (context, url) => CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Diğer widget'ları buraya ekleyebilirsiniz
              ],
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
*/
class KenBurnsViewWidget extends StatefulWidget {
  @override
  _KenBurnsViewWidgetState createState() => _KenBurnsViewWidgetState();
}

class _KenBurnsViewWidgetState extends State<KenBurnsViewWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
/*class ListeWidget extends StatefulWidget {
  @override
  _ListeWidgetState createState() => _ListeWidgetState();
}
class _ListeWidgetState extends State<ListeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dinle')),
      ),
      body: ListView.builder(
        itemCount: degiskenler.listDinle.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(degiskenler.listDinle[index]['parca_adi']),
            onTap: () {
              // Şarkıya tıklanıldığında yapılacak işlemleri burada gerçekleştirin
              // Örneğin, çalma işlemi veya şarkı ayrıntıları sayfasına yönlendirme
              _audioService.playAtIndex(index);
            },
          );
        },
      ),
    );
  }
}*/
class ListeWidget extends StatefulWidget {
  @override
  _ListeWidgetState createState() => _ListeWidgetState();
}
class _ListeWidgetState extends State<ListeWidget> {
  TextEditingController _searchController =
      TextEditingController(); // Arama çubuğu kontrolcüsü
  List<dynamic> filteredSongList = []; // Filtrelenmiş şarkı listesi
  String searchText = "";

  @override
  Widget build(BuildContext context) {
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

                // Filtrelenmiş liste ile UI'yi güncelleyin
                setState(() {
                  filteredSongList = filteredList;
                });
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
                  title: Text(displayList[index]['parca_adi'] +
                      " [" +
                      displayList[index]['seslendiren'] +
                      "]"),
                  //leading: Image.asset('images/atesiask.png'), // Fotoğrafı ekleyin
                  onTap: () {
                    // Şarkıya tıklanıldığında yapılacak işlemleri burada gerçekleştirin
                    // Örneğin, çalma işlemi veya şarkı ayrıntıları sayfasına yönlendirme
                    _audioService.playAtId(displayList[index]['sira_no']);
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
Future<Map<String, dynamic>> getirJsonData(String yol) async {
  final HttpService _httpService = HttpService();

  try {
    final jsonStr = await _httpService.fetchData(yol);
    final jsonDataList = JsonHelper.parseJson(
        jsonStr); // Bu satırı kullanmanıza gerek yok, veri zaten bir liste

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

/*class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Burada gerekli işlemleri yapabilirsiniz (örneğin: veri yükleme, hazırlık vs.)
    // Ardından bir süre bekleyerek ana ekranı açabiliriz.
    // Initialize the AudioService first
    initializeAudioService();

    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen()), // Ana ekran burada açılır
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Splash ekran rengi
      body: Center(
        child: Text(
          'My App', // Splash ekran metni
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}*/
void setPlaylist(data) {
  print("LAVANTA ${data[0]}");

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
            "${degiskenler.kaynakYolu}/atesiask/bahar11.jpg",
          ),
          artist: item['seslendiren'],
        ),
      ),
    );
  }

  _audioService.setPlaylist(playlist);
}
/*
Future<void> initializeAudioService() async {
  await _audioService.init();
  print("initializeAudioServiceinitializeAudioServiceinitializeAudioServiceinitializeAudioService");
}
*/
void arkaplanIslemleri() async {
  _audioService.init();

  final Future<Map<String, dynamic>> jsonMenba =
      compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/menba.json");
  final Future<Map<String, dynamic>> jsonSozler =
      compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/sozler.json");
  final Future<Map<String, dynamic>> jsonFotograflar = compute(
      getirJsonData, "${degiskenler.kaynakYolu}/kaynak/fotograflar.json");

  //_showDialogStreamController.add(true); // Diyaloğu göstermek için Stream'e true değeri gönder
  // 10 saniye sonra diyaloğu gizlemek için bir Timer kullanın
  /*Timer(Duration(seconds: 5), () {
        _showDialogStreamController.add(false);
      });*/
  jsonFotograflar.then((jsonDataMap) {
    if (jsonDataMap.containsKey("fotograflar")) {
      final List<dynamic> fotograflarListesi = jsonDataMap["fotograflar"];
      if (fotograflarListesi.isNotEmpty) {
        final Random random = Random();
        final int randomIndex = random.nextInt(fotograflarListesi.length);
        final String secilen = fotograflarListesi[randomIndex]['path'];
        Degiskenler.currentImageNotifier.value = secilen;
        degiskenler.oncekiFotografYolu = secilen;
        print("Rastgele Seçilen fotograf: $secilen");
        degiskenler.listFotograflar = fotograflarListesi;
      } else {
        print("fotograf listesi boş.");
      }
    } else {
      print("Verilerde 'fotograf' anahtarı bulunamadı.");
    }
  });
  jsonSozler.then((jsonDataMap) {
    if (jsonDataMap.containsKey("sozler")) {
      final List<dynamic> sozlerListesi = jsonDataMap["sozler"];
      if (sozlerListesi.isNotEmpty) {
        final Random random = Random();
        final int randomIndex = random.nextInt(sozlerListesi.length);
        final String secilenSoz = sozlerListesi[randomIndex];
        Degiskenler.currentEpigramNotifier.value = secilenSoz;
        print("Rastgele Seçilen Söz: $secilenSoz");
        degiskenler.listSozler = sozlerListesi;
      } else {
        print("Söz listesi boş.");
      }
    } else {
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
        compute(getirJsonData, "${degiskenler.kaynakYolu}/kaynak/$link.json")
            .then((data) {
          List<dynamic> listDinle = data["sesler"];
          setPlaylist(listDinle);
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
    print("İLKKKKKKKKKKKKKKKKK");
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
        print("yeni resim yolu $imageUrl");

        // Eğer imageUrl önceki ile aynı ise ve _imageBytes doluysa, mevcut resmi göster
        if (_currentImageUrl == imageUrl && _imageBytes != null) {
          return Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          );
        } else {
          // Değişiklik varsa veya _imageBytes null ise resmi indir
          _downloadImage(imageUrl);
          return _imageBytes != null
              ? Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          )
              : CircularProgressIndicator();
        }
      },
    );
  }
}



