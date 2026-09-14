
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const NumberGuessingApp());
}

class NumberGuessingApp extends StatelessWidget {
  const NumberGuessingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Guessing Game',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  const GameHomePage({Key? key}) : super(key: key);

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();
  
  late int _targetNumber;
  int _attempts = 0;
  String _message = 'Guess a number between 1 and 100';
  bool _isGameOver = false;

  // إعلانات AdMob
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // معرّفات الإعلانات الخاصة بك
  final String _adUnitId = 'ca-app-pub-4306511348482333/9316804501';

  @override
  void initState() {
    super.initState();
    _startNewGame();
    _loadBannerAd();
  }

  void _startNewGame() {
    setState(() {
      _targetNumber = _random.nextInt(100) + 1;
      _attempts = 0;
      _message = 'Guess a number between 1 and 100';
      _isGameOver = false;
      _controller.clear();
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _checkGuess() {
    if (_isGameOver) return;

    final input = _controller.text;
    final guess = int.tryParse(input);

    if (guess == null) {
      setState(() {
        _message = 'Please enter a valid number!';
      });
      return;
    }

    setState(() {
      _attempts++;
      if (guess < _targetNumber) {
        _message = 'Too Low! Try a higher number.';
      } else if (guess > _targetNumber) {
        _message = 'Too High! Try a lower number.';
      } else {
        _message = '🎉 Correct! You found it in $_attempts attempts.';
        _isGameOver = true;
      }
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // لوجو اللعبة مع اسم اللعبة
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.games,
                color: Colors.indigo,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Number Guessing Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🧠 Can you guess the secret number?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isGameOver ? Colors.green : Colors.indigo[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (!_isGameOver) ...[
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter your guess',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkGuess,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Guess', style: TextStyle(fontSize: 18)),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _startNewGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // مكان عرض بانر الإعلانات لتحقيق الأرباح
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
