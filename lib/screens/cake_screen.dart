import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

class CakeScreen extends StatefulWidget {
  final dynamic module;
  const CakeScreen({super.key, required this.module});

  @override
  State<CakeScreen> createState() => _CakeScreenState();
}

class _CakeScreenState extends State<CakeScreen> {
  final Map<int, String> submittedText = {};
  final Map<int, TextEditingController> controllers = {};
  final Map<int, String> recordedAudioPaths = {};
  final audio.AudioPlayer audioPlayer = audio.AudioPlayer();
  FlutterSoundRecorder? soundRecorder;
  
  bool isPlaying = false;
  bool isRecording = false;
  String? currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    initRecorder();
  }
  // initilizing the recorder------------
  Future<void> initRecorder() async {
    soundRecorder = FlutterSoundRecorder();
    await soundRecorder?.openRecorder();
  }
  // for the audio player part-------
  void initAudioPlayer() {
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPlayingUrl = null;
      });
    });

      audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          isPlaying = state == audio.PlayerState.playing;
        });
      });
    }

  @override
  void dispose() {
    audioPlayer.dispose();
    soundRecorder?.closeRecorder();
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> playAudio(String url) async {
    try {
      if (isPlaying && currentPlayingUrl == url) {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
          currentPlayingUrl = null;
        });
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(audio.UrlSource(url));
        setState(() {
          isPlaying = true;
          currentPlayingUrl = url;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }
//  if user wanted to record the auido-------------------
  Future<void> startRecording(int index) async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      try {
        await soundRecorder?.startRecorder(
          toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}_index_$index.aac',
          codec: Codec.aacADTS,
        );
        setState(() {
          isRecording = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied.')),
      );
    }
  }
  
  Future<void> stopRecording(int index) async {
    try {
      final path = await soundRecorder?.stopRecorder();
      setState(() {
        isRecording = false;
        recordedAudioPaths[index] = path!;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final cakes = widget.module['cakes'];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module['name']),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: cakes.length,
        itemBuilder: (context, index) {
          final cake = cakes[index];
          controllers[index] ??= TextEditingController();

          return Card(
            margin: EdgeInsets.all(height*0.01),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(height*0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cake['task'],
                    style:TextStyle(fontSize: height*0.021, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: height*0.02),
                  // if it was an image then ---------------------
                  if (cake['type'] == 'image')
                    Image.network(
                      cake['image_url'],
                      fit: BoxFit.cover,
                    ),
                    // if it was audio then this one----------------
                  if (cake['type'] == 'audio')
                    Column(
                      children: [
                        const Icon(Icons.audiotrack, size: 50, color: Colors.blue),
                        SizedBox(height: height*0.015),
                        Text(
                          isPlaying && currentPlayingUrl == cake['audio_url']
                              ? 'Now Playing...'
                              : 'Original Audio',
                          style:TextStyle(fontSize: height*0.02),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => playAudio(cake['audio_url']),
                          icon: Icon(
                            isPlaying && currentPlayingUrl == cake['audio_url']
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            isPlaying && currentPlayingUrl == cake['audio_url']
                                ? 'Pause'
                                : 'Play',
                          ),
                        ),
                        // like it was supported only in mobile so checking for web or not-------
                        if (!kIsWeb) ...[
                          SizedBox(height: height*0.02),
                          Text(
                            isRecording ? 'Recording in progress...' : 'Record Your Response',
                            style: TextStyle(fontSize: height*0.017),
                          ),
                          SizedBox(height: height*0.018),
                          ElevatedButton.icon(
                            onPressed: isRecording
                                ? () => stopRecording(index)
                                : () => startRecording(index),
                            icon: Icon(isRecording ? Icons.stop : Icons.mic),
                            label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRecording ? Colors.red : null,
                            ),
                          ),
                          if (recordedAudioPaths.containsKey(index)) ...[
                            SizedBox(height: height*0.017),
                            Text(
                              'Your Recorded Response:',
                              style: TextStyle(fontSize: height*0.017),
                            ),
                            SizedBox(height: height*0.015),
                            ElevatedButton.icon(
                              onPressed: () => playAudio(recordedAudioPaths[index]!),
                              icon: Icon(
                                isPlaying && currentPlayingUrl == recordedAudioPaths[index]
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                isPlaying && currentPlayingUrl == recordedAudioPaths[index]
                                    ? 'Pause'
                                    : 'Play Recording',
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  SizedBox(height: height*0.017),
                  if (cake['type'] != 'audio') ...[
                    if (submittedText.containsKey(index))
                      Text(
                        submittedText[index]!,
                        style:TextStyle(color: Colors.green, fontSize: height*0.017),
                      )
                    else
                      TextField(
                        controller: controllers[index],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your response',
                        ),
                      ),
                    SizedBox(height: height*0.017),
                    if (!submittedText.containsKey(index))
                      ElevatedButton(
                        onPressed: () {
                          final text = controllers[index]?.text.trim();
                          if (text != null && text.isNotEmpty) {
                            setState(() {
                              submittedText[index] = text;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Response Submitted!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a response.')),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
