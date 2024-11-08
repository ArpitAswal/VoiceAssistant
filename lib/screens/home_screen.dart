import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controllers/home_controller.dart';
import '../widgets/feature_box.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController(), permanent: true);
  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
            child: const Text(
          "Voice Genie",
          style: TextStyle(fontWeight: FontWeight.w400, fontFamily: "Cera"),
        )),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.lightGreenAccent.shade100],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: ZoomIn(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 600),
          child: Obx(() => (controller.textResponse.value == false)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 16.0),
                  child: FloatingActionButton(
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
                    shape: const CircleBorder(
                        side: BorderSide(color: Colors.white, width: 2)),
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Obx(
                      () => Icon(
                        (controller.speechListen.value)
                            ? Icons.stop
                            : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : ExpandableFab(
                  key: _key,
                  fanAngle: 90,
                  distance: 80,
                  openButtonBuilder: RotateFloatingActionButtonBuilder(
                    child: const Icon(Icons.menu_open_rounded),
                    fabSize: ExpandableFabSize.regular,
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                  ),
                  closeButtonBuilder: RotateFloatingActionButtonBuilder(
                    child: const Icon(Icons.close),
                    fabSize: ExpandableFabSize.small,
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: const CircleBorder(),
                  ),
                  children: [
                    FloatingActionButton(
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
                      shape: const CircleBorder(
                          side: BorderSide(color: Colors.white, width: 2)),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Obx(
                        () => Icon(
                          (controller.speechListen.value)
                              ? Icons.stop
                              : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        (controller.isStopped.value)
                            ? controller.playTTs()
                            : controller.stopTTs();
                      },
                      shape: const CircleBorder(
                          side: BorderSide(color: Colors.white, width: 2)),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        (controller.isStopped.value)
                            ? Icons.play_arrow
                            : Icons.stop,
                        color: Colors.white,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        final state = _key.currentState;
                        if (state != null) {
                          state.toggle();
                          controller.resetAll();
                        }
                      },
                      shape: const CircleBorder(
                          side: BorderSide(color: Colors.white, width: 2)),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.white,
                      ),
                    )
                  ],
                )),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.02,
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 600),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 125,
                      width: 125,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade300,
                            Colors.lightGreenAccent.shade100
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 125,
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
            ),
            FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Obx(
                () => Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.blueGrey.shade600, width: 1.25),
                      borderRadius: BorderRadius.circular(24).copyWith(
                          topLeft: Radius.zero, bottomRight: Radius.zero),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (controller.messages.isEmpty)
                              ? AnimatedTextKit(
                                  key: ValueKey(controller.textResponse.value),
                                  animatedTexts: [
                                    TyperAnimatedText(
                                        "${controller.greetingMessage}, what can I do for you?",
                                        textStyle: const TextStyle(
                                            fontFamily: 'Cera',
                                            color: Colors.black54,
                                            fontSize: 16),
                                        textAlign: TextAlign.start),
                                  ],
                                  isRepeatingAnimation: false,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: controller.messages.map((msg) {
                                    if (msg.isImage) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.file(
                                              File(msg.parts.first.text)),
                                        ),
                                      );
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AnimatedTextKit(
                                            key: ValueKey(
                                                controller.textResponse.value),
                                            displayFullTextOnTap: true,
                                            animatedTexts: [
                                              TyperAnimatedText(
                                                  (msg.role == "user")
                                                      ? "Q. ${msg.parts.first.text}"
                                                      : msg.parts.first.text,
                                                  textStyle: TextStyle(
                                                      fontFamily: 'Cera',
                                                      color: (msg.role ==
                                                              "user")
                                                          ? Colors.black87
                                                          : (msg.parts.first
                                                                      .text ==
                                                                  "Failed")
                                                              ? Colors.red
                                                              : Colors.grey,
                                                      fontSize: 16),
                                                  textAlign:
                                                      (msg.role == "model" &&
                                                              msg.parts.first
                                                                      .text ==
                                                                  "Failed")
                                                          ? TextAlign.end
                                                          : TextAlign.start),
                                            ],
                                            isRepeatingAnimation: false,
                                          ),
                                        ],
                                      );
                                    }
                                  }).toList()),
                          (controller.isLoading.value)
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: LoadingAnimationWidget.progressiveDots(
                                      color: Colors.grey.shade400, size: 40),
                                )
                              : const SizedBox.shrink()
                        ])),
              ),
            ),
            Obx(
              () => Visibility(
                visible: !controller.textResponse.value,
                child: SlideInLeft(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Here are a few features',
                      style: TextStyle(
                        fontFamily: 'Cera',
                        color: Colors.indigo.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: !controller.textResponse.value,
                child: Column(
                  children: [
                    SlideInRight(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Gemini',
                        descriptionText:
                            'A smarter way to stay organized and informed with Gemini AI',
                      ),
                    ),
                    SlideInLeft(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Imagine AI',
                        descriptionText:
                            'Get inspired and stay creative with your personal assistant powered by Imagine, Your commercial Generative AI solution',
                      ),
                    ),
                    SlideInRight(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      child: const FeatureBox(
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Get the best of both worlds with a voice assistant powered by Imagine and Gemini',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
