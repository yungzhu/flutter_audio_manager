import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_audio_manager/flutter_audio_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioInput _currentInput = AudioInput("unknow", 0);
  List<AudioInput> _availableInputs = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    FlutterAudioManager.setListener(() async {
      print("-----changed-------");
      await _getInput();
      setState(() {});
    });

    await _getInput();
    if (!mounted) return;
    setState(() {});
  }

  _getInput() async {
    _currentInput = await FlutterAudioManager.getCurrentOutput();
    print("current:$_currentInput");
    _availableInputs = await FlutterAudioManager.getAvailableInputs();
    print("available $_availableInputs");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text(
                  "current output:${_currentInput.name} ${_currentInput.port}",
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      AudioInput input = _availableInputs[index];
                      return Row(
                        children: <Widget>[
                          Expanded(child: Text("${input.name}")),
                          Expanded(child: Text("${input.port}")),
                        ],
                      );
                    },
                    itemCount: _availableInputs.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bool res = false;
            if (_currentInput.port == AudioPort.receiver) {
              res = await FlutterAudioManager.changeToSpeaker();
              print("change to speaker:$res");
            } else {
              res = await FlutterAudioManager.changeToReceiver();
              print("change to receiver:$res");
            }
            await _getInput();
          },
        ),
      ),
    );
  }
}
