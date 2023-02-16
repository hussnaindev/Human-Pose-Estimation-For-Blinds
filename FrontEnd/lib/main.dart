import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/camera_screen.dart';
import 'package:flutter_application_4/pages/sencond_page.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: MyWidget(),
      // initialRoute: '/',
      routes: {
        // '/': (context) => const FirstPage(),
        '/second': (context) => const SecondPage()
      },
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Human Pose Estimation",
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: InkWell(
          splashColor: Colors.black,
          child: const Text(
            "Single tap to open camera\n \n \nDouble tap to speak",
            style: TextStyle(fontSize: 30),
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
          onDoubleTap: () async {
            print("Double taped");
            await Navigator.push(
                context, MaterialPageRoute(builder: (context) => Speaking()));
            // Speaking();
          },
        ),
      ),
    );
  }
}

class Speaking extends StatefulWidget {
  const Speaking({super.key});

  @override
  State<Speaking> createState() => _SpeakingState();
}

class _SpeakingState extends State<Speaking> {
  final Map<String, HighlightedWord> _highlights = {
    'Highlight': HighlightedWord(
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Impaired': HighlightedWord(
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  late stt.SpeechToText _speech;
  bool _isListening = true;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    _listen();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        // child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        child: FloatingActionButton(
          onPressed: _stopListen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Human Pose Estimation",
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {

    // if (_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {});
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      // }
    }
  }

  void _stopListen() {
    setState(() => _isListening = false);
    _speech.stop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CameraScreen()));
  }
}
