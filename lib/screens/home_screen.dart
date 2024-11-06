import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/feature_box.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        leading: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await controller.speech.hasPermission &&
              controller.speech.isNotListening) {
            await controller.startListening();
          } else if (controller.speech.isListening) {
            await controller.stopListening();
          } else {
            controller.initialize();
          }
        },
        shape:
            const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
        backgroundColor: Theme.of(context).primaryColor,
        child: Obx(
          () => Icon(
            (controller.speechListening) ? Icons.stop : Icons.mic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.02,
            ),
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBlueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/virtualAssistant.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                top: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderColor,
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero,
                ),
              ),
              child: const Text(
                'Good Morning, what task can I do for you?',
                style: TextStyle(
                  fontFamily: 'Cera',
                  color: AppColors.mainFontColor,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
              child: const Text(
                'Here are a few features',
                style: TextStyle(
                  fontFamily: 'Cera',
                  color: AppColors.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Column(
              children: [
                FeatureBox(
                  color: AppColors.lightBlueContainer,
                  headerText: 'ChatGPT',
                  descriptionText:
                      'A smarter way to stay organized and informed with ChatGPT',
                ),
                FeatureBox(
                  color: AppColors.blueGreyContainer,
                  headerText: 'Dall-E',
                  descriptionText:
                      'Get inspired and stay creative with your personal assistant powered by Dall-E',
                ),
                FeatureBox(
                  color: AppColors.lightGreenContainer,
                  headerText: 'Smart Voice Assistant',
                  descriptionText:
                      'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
