import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/repository/netwrok_requests.dart';
import 'package:voice_assistant/utils/app_colors.dart';
import 'package:voice_assistant/utils/bottomsheet.dart';

import '../models/chat_model.dart';

class HomeController extends GetxController {
  final stt.SpeechToText speech = stt.SpeechToText();
  final flutterTts = FlutterTts();
  final _service = NetworkRequests();

  final RxString _userVoiceMsg = "".obs;
  final RxBool _speechEnabled = false.obs;
  final RxBool _speechListening = false.obs;
  final RxString _responseText =
      "Press the button and start speaking".obs; // Placeholder for response
  final RxList<Contents> messages = <Contents>[].obs;
  late Rx<File?> imageFile = null.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    speech.stop();
    flutterTts.stop();
  }

  bool get speechListening => _speechListening.value;

  Future<void> callGeminiAPI() async {
    final data = await _service.geminiAPI(messages: messages);
    if (data != null && data.candidates != null) {
      final botResponse = data.candidates!.first.content.parts.first.text;
      _responseText.value = botResponse;
      messages.add(Contents(role: "model", parts: [Parts(text: botResponse)]));
    } else {
      _responseText.value =
          "Sorry, I am not able to gives you response of your prompt";
    }
    flutterTts.speak(_responseText.value);
  }

  Future<void> callImagenAPI(String input) async {
    final data = await _service.geminiImagenAPI(input);
    if (!data.contains("Error")) {
      imageFile.value = File(data);
      _responseText.value =
          "Here it is a comprehensive image output according to your desired prompt";
    } else {
      _responseText.value = data;
    }
    flutterTts.speak(_responseText.value);
  }

  /// This has to happen only once per app
  Future<void> initialize() async {
    _speechEnabled.value = await speech.initialize(
      onStatus: (status) =>
          _onSpeechStatus(status), // Listen for status changes
      onError: (error) => Get.bottomSheet(
          backgroundColor: AppColors.whiteColor,
          elevation: 8.0,
          ignoreSafeArea: true,
          persistent: false,
          isDismissible: false,
          enableDrag: false,
          bottomSheet(msg: "Error: $error")),
    );
    if (!_speechEnabled.value) {
      _responseText.value =
          "Speech recognition is not available on this device.";
    }
    await flutterTts.setSharedInstance(true);
  }

  // Callback to handle changes in the speech recognition status
  void _onSpeechStatus(String status) {
    if (status == "notListening") {
      // When the user stops speaking
      stopListening();
      _sendRequest(_userVoiceMsg.value); // Process the captured input
    }
  }

  // Method to send the input text to ChatGPT API and receive a response
  Future<void> _sendRequest(String input) async {
    messages.add(Contents(role: "user", parts: [Parts(text: input)]));
    _responseText.value = await _service.isArtPromptAPI(messages);
    if (_responseText.value == "YES") {
      await callImagenAPI(input);
    } else if (_responseText.value == "NO") {
      await callGeminiAPI();
    } else {
      // Speak out the response
      flutterTts.speak(_responseText.value);
    }
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    _speechListening(true);
    await speech.listen(onResult: (result) {
      _userVoiceMsg.value = result.recognizedWords; // Capturing spoken text
    });
  }

  /// Manually stop the active speech recognition session Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the listen method.
  Future<void> stopListening() async {
    _speechListening(false);
    await speech.stop();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }
}
