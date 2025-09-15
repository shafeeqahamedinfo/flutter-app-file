import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: const TtsPage(),
    );
  }
}

class TtsPage extends StatefulWidget {
  const TtsPage({super.key});

  @override
  State<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textCtrl =
      TextEditingController(text: 'Hello, this is a voice demo with controls!');
  bool _isSpeaking = false;

  // history
  final List<String> _history = [];

  // controls
  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;

  Future<void> _speak([String? text]) async {
    final speakText = (text ?? _textCtrl.text).trim();
    if (speakText.isEmpty) return;

    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(_volume);

    _tts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        if (!_history.contains(speakText)) {
          _history.insert(0, speakText);
        }
      });
    });
    _tts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });

    await _tts.speak(speakText);
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _clearText() => setState(() => _textCtrl.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("text to voice "),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Enter text',
                labelStyle: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),

            // Animated mic
            Center(
              child: _isSpeaking
                  ? BounceInDown(
                      child: Icon(Icons.mic,
                          size: 80, color: Colors.deepPurpleAccent),
                    )
                  : FadeIn(
                      child: Icon(Icons.mic_none,
                          size: 80, color: Colors.grey[600]),
                    ),
            ),

            const SizedBox(height: 20),

            // Controls
            Row(
              children: [
                const Text("Speed", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: _rate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: _rate.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _rate = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Pitch", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _pitch.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _pitch = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Volume", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _volume.toStringAsFixed(2),
                    onChanged: (v) => setState(() => _volume = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Speak / Stop
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text("Speak"),
                  onPressed: _speak,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  icon: const Icon(Icons.stop, color: Colors.white),
                  label: const Text("Stop"),
                  onPressed: _stop,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Clear"),
                  onPressed: _clearText,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white54),

            // History
            const Text("History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      title: Text(item, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () => _speak(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
