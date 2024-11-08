import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/repository/network_requests.dart';
import 'package:voice_assistant/utils/alert_messages.dart';

import '../models/chat_model.dart';

class HomeController extends GetxController {
  final stt.SpeechToText speech = stt.SpeechToText();
  final flutterTts = FlutterTts();
  final _service = NetworkRequests();

  final RxString greetingMessage = "Good Morning".obs;
  final RxString _userVoiceMsg = "".obs;
  final RxBool _speechEnabled = false.obs;
  final RxBool speechListen = false.obs;
  final RxBool textResponse = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isStopped = false.obs; // Flag to check if the TTS should stop
  final RxList<Contents> messages = <Contents>[].obs;

  List<String> messageQueue = [];

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

  Future<void> askPermission() async{
    var requestStatus = await Permission.microphone.request();
    if(requestStatus.isDenied || requestStatus.isPermanentlyDenied){
      await openAppSettings();
    } else if(requestStatus.isGranted){
      speechInitialize();
    }
  }

  Future<void> callGeminiAPI() async {
    final data = await _service.geminiAPI(messages: messages);
    if (data != null && data.candidates != null) {
      final botResponse = data.candidates!.first.content.parts.first.text;
      messages.add(Contents(role: "model", parts: [Parts(text: botResponse)], isImage: false));
      speakTTs(botResponse);
    } else {
      messages.add(Contents(role: "model", parts: [Parts(text: "Sorry, I am not able to gives you a response of your prompt")], isImage: false));
      speakTTs("Sorry, I am not able to gives you a response of your prompt");
    }
    isLoading.value = false;
  }

  Future<void> callImagineAPI(String input) async {
    final data = await _service.imagineAPI(input);
    if (!data.contains("Error")) {
      messages.add(Contents(role: "user", parts: [
        Parts(text: "Here, is a comprehensive desire image output of your prompt"),
      ], isImage: false));
      messages.add(Contents(role: "model", parts: [
        Parts(text: data)
      ], isImage: true));
    } else {
      messages.add(Contents(role: "model", parts: [
        Parts(text: data),
      ], isImage: false));
      speakTTs(data);
    }
    isLoading.value = false;
  }

  Future<void> audioPermission(String error) async{
    await Get.bottomSheet(
            elevation: 8.0,
            ignoreSafeArea: true,
            persistent: true,
            isDismissible: false,
            enableDrag: false,
        AlertMessages.bottomSheet(msg: "Error: $error"));
  }

  Future<void> initialize() async {
    greetingMessage.value = getGreeting();
    await speechInitialize();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    flutterTts.setCompletionHandler(_onSpeakCompleted);
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // Callback to handle changes in the speech recognition status
  void _onSpeechStatus(String status) async{
    if (status == "notListening") {
      // When the user stops speaking
      speechListen.value = false;
     await Future.delayed(const Duration(seconds: 2));
       _sendRequest(_userVoiceMsg.value); // Process the captured input
       stopListening();
    }
  }

  void _onSpeakCompleted() {
    if (!isStopped.value) {
      _speakNextMessage(); // Speak the next message if not stopped
    }
  }

  void playTTs() async{
    int i = 0;
    while(i<messages.length){
      if(!messages[i].isImage){
        messageQueue.add(messages[i].parts.first.text);
      }
      i++;
    }
    isStopped.value = false;
    flutterTts.setCompletionHandler(_onSpeakCompleted);
    await _speakNextMessage(); // Start speaking
  }

  void resetAll(){
    messages.clear();
    messageQueue.clear();
    textResponse.value = false;
    stopTTs();
    stopListening();
  }

  // Method to send the input text to ChatGPT API and receive a response
  Future<void> _sendRequest(String input) async {
    textResponse.value = true;
    if(input.isNotEmpty){
      messages.add(Contents(role: "user", parts: [Parts(text: input)], isImage: false));
      isLoading.value = true;
    final response = await _service.isArtPromptAPI(input);
    if(input.contains("draw") || input.contains("image") || input.contains("picture")){
        await callImagineAPI(input);
    } else if(response == "NO"){
        await callGeminiAPI();
      }
     else if(response == "YES") {
      await callImagineAPI(input);
    } else {
      // Speak out the response
      isLoading.value = false;
      messages.add(Contents(role: "model", parts: [Parts(text: response)], isImage: false));
      speakTTs(response);
    } }
    else{
      messages.add(Contents(role: "user", parts: [Parts(text: "Please provide me with some context or a question so I can assist you.")], isImage: false));
      messageQueue.add("Please provide me with some context or a question so I can assist you.");
      messages.add(Contents(role: "model", parts: [Parts(text: "For example: Give me some Interview Tips.")], isImage: false));
      messageQueue.add("For example: Give me some Interview Tips.");
      await _speakNextMessage();
    }
  }

  Future<void> speechInitialize() async{
    _speechEnabled.value = await speech.initialize(
      onStatus: (status) => _onSpeechStatus(status), // Listen for status changes
      onError: (error) =>  AlertMessages.showSnackBar(error.errorMsg)// Listen when error occur
    );
    if (!_speechEnabled.value) {
      audioPermission("Speech recognition is not available on this device.");
    }
  }

  Future<void> _speakNextMessage() async{
    if (messageQueue.isNotEmpty && !isStopped.value) {
      String message = messageQueue.removeAt(0); // Get the next message
      await flutterTts.speak(message);
    } else {
      isStopped.value = true; // Stop if queue is empty or stop was called
    }
  }

  Future<void> speakTTs(String botResponse) async{
    isStopped.value = false;
    messageQueue.add(botResponse);
    await _speakNextMessage();
  }

  Future<void> stopTTs() async{
    isStopped.value = true; // Set flag to prevent further speaking
    await flutterTts.stop();
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    speechListen.value = true;
    await speech.listen(onResult: (result) {
      _userVoiceMsg.value = result.recognizedWords; // Capturing spoken text
    },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation, // Use dictation mode for continuous listening
        cancelOnError: true
      ),
      pauseFor: const Duration(seconds: 2),
    );
  }

  /// Manually stop the active speech recognition session Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the listen method.
  Future<void> stopListening() async {
    _userVoiceMsg.value = "";
    speechListen.value = false;
    await speech.stop();
  }
}
