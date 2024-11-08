import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/controllers/home_controller.dart';

class AlertMessages {
  static Widget bottomSheet({required String msg}) {
    return Card(
      elevation: 8,
      shadowColor: Colors.grey[400],
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: Get.width,
        height: Get.height * .12,
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
        child: SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.settings_voice_rounded,
                color: Colors.red,
                size: Get.height * .04,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Audio Record Permission",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "$msg Please grant audio record permission to use this feature.",
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Cera",
                          color: Colors.black54,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.red[500],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 12.0)),
                child: const Text(
                  'Enable',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Get.find<HomeController>().askPermission();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSnackBar(String message, {int? duration}) {
    Get.showSnackbar(GetSnackBar(
        message: message,
        duration: Duration(
          seconds: duration ?? 5,
        ),
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade300, Colors.lightGreenAccent.shade100],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 20,
        margin: const EdgeInsets.all(12),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        borderColor: Colors.white,
        borderWidth: 2));
  }
}
