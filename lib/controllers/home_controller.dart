import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_assistant/repository/network_requests.dart';
import 'package:voice_assistant/utils/alert_messages.dart';

import '../exceptions/app_exception.dart';
import '../models/chat_model.dart';

class HomeController extends GetxController {
  // External services and plugins
  final stt.SpeechToText speech = stt.SpeechToText(); // Handles speech-to-text functionality
  final flutterTts = FlutterTts(); // Handles text-to-speech functionality
  final _service = NetworkRequests(); // Makes API requests to custom network services

  // Observable variables for UI updates
  final RxString greetingMessage = "Good Morning".obs; // Stores the greeting message for display
  final RxString _userVoiceMsg = "".obs; // Stores the recognized user voice message from speech-to-text
  final RxBool _speechEnabled = false.obs; // Flag to track if speech recognition is enabled
  final RxBool speechListen = false.obs; // Flag to indicate if app is actively listening to user speech
  final RxBool textResponse = false.obs; // Flag to indicate if a text response is received
  final RxBool isLoading = false.obs; // Flag to show loading state when waiting for API response
  final RxBool isStopped = true.obs; // Flag to determine if text-to-speech should stop
  final RxList<Contents> messages = <Contents>[].obs; // List to hold conversation messages

  List<String> messageQueue = []; // Queue for storing messages to be spoken by text-to-speech

  @override
  void onInit() {
    super.onInit();
    initialize(); // Initialize the controller by setting greeting and TTS configurations
  }

  @override
  void onClose() {
    stopTTs(); // Stops any active text-to-speech
    stopListening(); // Stops any active speech-to-text
  }

  Future<void> askPermission() async {  // Asks for microphone permission and opens settings if denied
    var requestStatus = await Permission.microphone.request();
    if (requestStatus.isDenied || requestStatus.isPermanentlyDenied) {
      await openAppSettings();
    } else if (requestStatus.isGranted) {
      speechInitialize(); // Initializes speech recognition if permission is granted
    }
  }

  // Calls an API to get a response from the Gemini model, adding it to messages and speaking it
  Future<void> callGeminiAPI() async {
    try {
      final data = await _service.geminiAPI(messages: messages);
      if (data != null && data.candidates != null) {
        final botResponse = data.candidates!.first.content.parts.first.text;
        messages.add(Contents(role: "model", parts: [Parts(text: botResponse)], isImage: false));
        speakTTs(botResponse);
      } else {
        messages.add(Contents(
            role: "model", parts: [
              Parts(text: "Sorry, I am not able to gives you a response of your prompt")
            ], isImage: false));
        speakTTs("Sorry, I am not able to gives you a response of your prompt");
      }
    } on AppException catch (e) {
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {  // Handles errors, showing an error message
      AlertMessages.showSnackBar(e.toString());
    } finally {
      isLoading.value = false;  // Ends loading state
    }
  }

  // Calls the Imagine API to fetch an image based on input text
  Future<void> callImagineAPI(String input) async {
    try {
      final data = await _service.imagineAPI(input);
      messages.add(Contents(
          role: "user", parts: [
            Parts(text: "Here, is a comprehensive desire image output of your prompt"),
          ], isImage: false));
      messages.add(Contents(role: "model", parts: [Parts(text: data)], isImage: true));
    } on AppException catch (e) {    // Adds an error message if the call fails
      messages.add(Contents(role: "model", parts: [Parts(text: "Failed")], isImage: false));
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {    // Adds an error message if the call fails
      messages.add(Contents(role: "model", parts: [Parts(text: "Failed")], isImage: false));
      AlertMessages.showSnackBar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Shows a bottom sheet message when there's an error with audio permissions
  Future<void> audioPermission(String error) async {
    await Get.bottomSheet(
        elevation: 8.0,
        ignoreSafeArea: true,
        persistent: true,
        isDismissible: false,
        enableDrag: false,
        AlertMessages.bottomSheet(msg: "Error: $error"));
  }

  // Initializes greeting message, speech recognition, and TTS settings
  Future<void> initialize() async {
    greetingMessage.value = getGreeting(); // Sets initial greeting based on time of day
    await speechInitialize();
    await flutterTts.setLanguage("en-US"); // Sets TTS language
    await flutterTts.setSpeechRate(0.5); // Sets TTS speaking speed
    await flutterTts.setVolume(1.0); // Sets TTS volume
    await flutterTts.setPitch(1.0); // Sets TTS pitch
    flutterTts.setCompletionHandler(_onSpeakCompleted); // Sets a handler for TTS completion
  }

  // Returns a greeting based on the time of day
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
  void _onSpeechStatus(String status) async {
    if (status == "notListening") {
      speechListen.value = false;  // Updates flag when user stops speaking
      await Future.delayed(const Duration(seconds: 2)); // here delay is used to store the speech words, if not it will miss the last word of your prompt
      _sendRequest(_userVoiceMsg.value); // Process the captured input
      stopListening(); // Stops speech recognition
    }
  }

  // Called when TTS completes a message, then checks for more messages in queue
  void _onSpeakCompleted() {
    if (!isStopped.value) {
      _speakNextMessage(); // Speak the next message if not stopped
    }
  }

  // Initializes the message queue for speaking and starts TTS
  void playTTs() async {
    for (var message in messages) {
      if (!message.isImage) messageQueue.add(message.parts.first.text);
    }
    isStopped.value = false;
    flutterTts.setCompletionHandler(_onSpeakCompleted);
    await _speakNextMessage(); // Begins speaking messages in the queue
  }

  // Resets conversation messages and stops both TTS and speech recognition
  void resetAll() {
    messages.clear();
    messageQueue.clear();
    textResponse.value = false;
    stopTTs();
    stopListening();
  }

  // Sends user input to appropriate API and speaks the response if needed
  Future<void> _sendRequest(String input) async {
    try {
      textResponse.value = true;
      if (input.isNotEmpty) {
        messages.add(Contents(role: "user", parts: [Parts(text: input)], isImage: false));
        isLoading.value = true;
        final response = await _service.isArtPromptAPI(input);
        if (input.contains("draw") ||
            input.contains("image") ||
            input.contains("picture")) {
          await callImagineAPI(input); // Calls Imagine API if input asks for an image
        } else if (response == "NO") {
          await callGeminiAPI(); // Calls Gemini API if text response is expected
        } else if (response == "YES") {
          await callImagineAPI(input);  // Calls Imagine API if input asks for an image
        } else {
          isLoading.value = false;
          messages.add(Contents(role: "model", parts: [Parts(text: response)], isImage: false));
          speakTTs(response); // Speaks response if applicable
        }
      } else {
        // Adds a default prompt message when no input is provided
        messages.add(Contents(
            role: "user", parts: [
              Parts(text: "Please provide me with some context or a question so I can assist you.")
            ], isImage: false));
        messageQueue.add("Please provide me with some context or a question so I can assist you.");
        messages.add(Contents(
            role: "model", parts: [
              Parts(text: "For example: Give me some Interview Tips.")
            ], isImage: false));
        messageQueue.add("For example: Give me some Interview Tips.");
        isStopped.value = false;
        await _speakNextMessage();
      }
    } on AppException catch (e) {
      isLoading.value = false;
      messages.add(Contents(
          role: "model", parts: [Parts(text: "Failed")], isImage: false));
      AlertMessages.showSnackBar(e.message.toString());
    } catch (e) {
      isLoading.value = false;
      messages.add(Contents(role: "model", parts: [Parts(text: "Failed")], isImage: false));
      AlertMessages.showSnackBar(e.toString());
    }
  }

  // Initializes speech recognition and sets error handlers
  Future<void> speechInitialize() async {
    _speechEnabled.value = await speech.initialize(
        onStatus: (status) => _onSpeechStatus(status), // Sets status change handler
        onError: (error) => AlertMessages.showSnackBar(error.errorMsg) // Shows error on initialization failure
        );
    if (!_speechEnabled.value) {
      audioPermission("Speech recognition is not available on this device.");
    }
  }

  // Speaks the next message in the queue if available
  Future<void> _speakNextMessage() async {
    if (messageQueue.isNotEmpty && !isStopped.value) {
      await flutterTts.speak(messageQueue.removeAt(0)); // Speaks the next message in queue
    } else {
      isStopped.value = true; // Sets stopped flag when queue is empty
    }
  }

  // Adds a message to the queue and starts TTS
  Future<void> speakTTs(String botResponse) async {
    isStopped.value = false;
    messageQueue.add(botResponse);
    await _speakNextMessage();
  }

  // Adds a message to the queue and starts TTS
  Future<void> stopTTs() async {
    isStopped.value = true;
    await flutterTts.stop();
  }

  // Each time to start a speech recognition session
  Future<void> startListening() async {
    speechListen.value = true;
    await speech.listen(
      onResult: (result) {
        _userVoiceMsg.value = result.recognizedWords; // Captures user's speech as text
      },
      listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode
              .dictation, // Use dictation mode for continuous listening
          cancelOnError: true),
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
