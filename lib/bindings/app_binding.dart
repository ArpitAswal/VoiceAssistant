
import 'package:get/get.dart';
import 'package:voice_assistant/controllers/home_controller.dart';

class AppBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(HomeController(), permanent: true);
  }

}