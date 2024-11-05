
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/utils/app_colors.dart';
import 'package:voice_assistant/utils/bottomsheet.dart';

class HomeController extends GetxController{

  final stt.SpeechToText speech = stt.SpeechToText();
  final flutterTts = FlutterTts();

  final RxString _userVoiceMsg = "".obs;
  final RxBool _speechEnabled = false.obs;
  final RxBool _speechListening = false.obs;
  RxString _responseText = "Press the button and start speaking".obs; // Placeholder for response

  @override
  void onInit() {
    super.onInit();
    initialize();
  }
  @override
  void onClose(){
    speech.stop();
    flutterTts.stop();
  }

  bool get speechListening => _speechListening.value;

  /// This has to happen only once per app
  Future<void> initialize() async{
    _speechEnabled.value = await speech.initialize(
      onStatus: (status) => _onSpeechStatus(status),  // Listen for status changes
      onError: (error) => Get.bottomSheet(
        backgroundColor: AppColors.whiteColor,
        elevation: 8.0,
        ignoreSafeArea: true,
        persistent: false,
        isDismissible: false,
        enableDrag: false,
        bottomSheet(msg: "Error: $error")
      ),
    );
    if (!_speechEnabled.value) {
        _responseText.value = "Speech recognition is not available on this device.";
    }
    await flutterTts.setSharedInstance(true);
  }

  // Callback to handle changes in the speech recognition status
  void _onSpeechStatus(String status) {
    if (status == "notListening") {  // When the user stops speaking
      stopListening();
      _sendRequest(_userVoiceMsg.value);  // Process the captured input
    }
  }

  // Method to send the input text to ChatGPT API and receive a response
  Future<void> _sendRequest(String input) async {
      _responseText.value = "Processing..."; // Placeholder while awaiting response

    // Simulate an API request (Replace this with your ChatGPT API call)
    await Future.delayed(const Duration(seconds: 3));
    String simulatedResponse = "This is a response from ChatGPT based on: '$input'";

      _responseText.value = simulatedResponse;  // Update response text

    // Speak out the response
    flutterTts.speak(_responseText.value);
  }


  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    _speechListening(true);
    await speech.listen(onResult: (result) {
        _userVoiceMsg.value = result.recognizedWords;  // Capturing spoken text
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