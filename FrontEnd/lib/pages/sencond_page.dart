import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/main.dart';
import 'package:text_to_speech/text_to_speech.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final String defaultLanguage = 'en-US';

  TextToSpeech tts = TextToSpeech();

  String text = 'A person is standing in front of you';
  // String newText = text + "!";
  double volume = 1; // Range: 0-1

  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String? voice;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = text;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initLanguages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    readOnly: false,
                    textAlign: TextAlign.center,
                    controller: textEditingController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Text will be shown here...'),
                    onChanged: (String newText) {
                      setState(() {
                        text = newText;
                        speak();
                      });
                      // if (newText.endsWith("!")) {
                      if (text.endsWith("!")) {
                      speak();
                      Timer(Duration(seconds: 5), () {
                        // <-- Delay here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                        setState(() {});
                      });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get supportPause => defaultTargetPlatform != TargetPlatform.android;

  bool get supportResume => defaultTargetPlatform != TargetPlatform.android;

  void speak() {
    tts.setVolume(volume);
    if (languageCode != null) {
      tts.setLanguage(languageCode!);
    }
    tts.setPitch(1.0);
    tts.speak(text);
  }
}
