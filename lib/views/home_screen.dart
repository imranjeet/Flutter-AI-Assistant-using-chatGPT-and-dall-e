import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:myassistant/provider/apiResponse.dart';
import 'package:myassistant/provider/recent_qna_provider.dart';
import 'package:myassistant/services/custom_logger.dart';
import 'package:myassistant/views/feature_card.dart';
import 'package:myassistant/views/history_screen.dart';
import 'package:myassistant/views/main_drawer.dart';
import 'package:myassistant/my_colors.dart';
import 'package:myassistant/services/openai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecentQnAProvider recentQnAProvider = RecentQnAProvider();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final OpenAIService openAIService = OpenAIService();
  final SpeechToText speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  bool speechEnabled = false;
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  String? imageId;
  int start = 200;
  int delay = 200;
  int _progress = 0;
  final _textController = TextEditingController();
  bool isLoading = false;
  bool isMicLoading = false;
  bool isSpeakerOff = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
    initSpeaker();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);

    setState(() {});
  }

  Future<void> initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initSpeaker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? speaker = prefs.getBool('speaker');
    setState(() {
      speaker == null ? null : isSpeakerOff = speaker;
    });
  }

  Future<void> startListening() async {
    generatedContent = "...";
    await speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    if (speechToText.isNotListening) {
      Timer(const Duration(seconds: 0), () async {
        CustomLogger.instance.singleLine("lastWords: $lastWords");
        final speech = await openAIService.isArtPromptAPI(lastWords);
        if (speech.contains('https')) {
          generatedImageUrl = speech;
          generatedContent = null;
          setState(() {});
        } else {
          generatedImageUrl = null;
          generatedContent = speech;
          setState(() {});
          await systemSpeak(speech);
        }
        await stopListening();
        setState(() {
          isMicLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  Future<void> systemSpeak(String content) async {
    isSpeakerOff ? null : await flutterTts.speak(content);
  }

  Future<void> setSpeaker(bool val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('speaker', val);
    Fluttertoast.showToast(msg: val ? "Speaker OFF" : "Speaker ON");
    setState(() {
      isSpeakerOff = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            "My Assistant",
            style: TextStyle(
              fontFamily: 'Cera Pro',
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          SlideInRight(
            child: IconButton(
                onPressed: () async {
                  if (isSpeakerOff) {
                    initTextToSpeech();
                    setSpeaker(false);
                  } else {
                    flutterTts.stop();
                    setSpeaker(true);
                  }
                },
                icon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: isSpeakerOff
                          ? Image.asset("assets/images/silent.png",
                              color: Colors.white)
                          : Image.asset("assets/images/volume.png",
                              color: Colors.white)),
                )),
          )
        ],
        // leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: size.height * 0.12,
                      width: size.height * 0.12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: MyColors.assistantCircleColor,
                          shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    height: size.height * 0.13,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/images/virtual_assistant.png"))),
                  ),
                ],
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  width: double.maxFinite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 20)
                      .copyWith(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20)
                        .copyWith(topLeft: Radius.zero),
                    border: Border.all(color: MyColors.borderColor),
                    color: const Color(0xff444654),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: SelectableText(
                      onTap: () {
                        Fluttertoast.showToast(msg: "Copied");
                      },
                      generatedContent == null
                          ? 'Good Morning, what task can I do for you?'
                          : "Q: $lastWords\nAns: $generatedContent",
                      style: const TextStyle(
                          fontFamily: 'Cera Pro',
                          // color: MyColors.mainFontColor,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0).copyWith(top: 30),
                child: Column(
                  children: [
                    Text(
                      "Q: $lastWords",
                      style: const TextStyle(
                          fontFamily: 'Cera Pro',
                          // color: MyColors.mainFontColor,
                          fontSize: 20),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImageUrl!),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            Fluttertoast.showToast(
                                msg: 'Image downloading started.');
                            imageId = await ImageDownloader.downloadImage(
                                generatedImageUrl!,
                                destination: AndroidDestinationType.custom(
                                    directory: 'images')
                                  ..inExternalFilesDir());

                            if (imageId == null) {
                              return;
                            }

                            ImageDownloader.callback(onProgressUpdate:
                                (String? imageId, int progress) {
                              setState(() {
                                _progress = progress;
                              });
                            });

                            Fluttertoast.showToast(msg: 'Image downloaded.');
                          } on PlatformException catch (error) {
                            Fluttertoast.showToast(
                                msg: 'Image downloading failed.');
                            CustomLogger.instance.singleLine(error.toString());
                          }
                        },
                        child: _progress == 0
                            ? const Text(
                                "Download",
                                style: TextStyle(
                                    fontFamily: 'Cera Pro',
                                    fontSize: 20,
                                    color: MyColors.whiteColor),
                              )
                            : _progress == 100
                                ? const Text(
                                    "Saved",
                                    style: TextStyle(
                                        fontFamily: 'Cera Pro',
                                        fontSize: 20,
                                        color: MyColors.whiteColor),
                                  )
                                : Text(
                                    "$_progress%",
                                    style: const TextStyle(
                                        fontFamily: 'Cera Pro',
                                        fontSize: 20,
                                        color: MyColors.whiteColor),
                                  ))
                  ],
                ),
              ),
            // FutureBuilder<ProviderResponse<List<dynamic>>>(
            //   future: recentQnAProvider.getRecentQnA(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       if (snapshot.data!.data == null) {
            //         return const SizedBox();
            //       } else {
            //         List dataList = snapshot.data!.data!;
            //         return SingleChildScrollView(
            //           child: ListView.builder(
            //               itemCount: dataList.length,
            //               shrinkWrap: true,
            //               physics: const NeverScrollableScrollPhysics(),
            //               itemBuilder: (context, index) {
            //                 return Padding(
            //                   padding: const EdgeInsets.only(
            //                       bottom: 15, left: 10, right: 10),
            //                   child: ExpansionTile(
            //                     textColor: MyColors.whiteColor,
            //                     trailing: const Icon(
            //                       Icons.arrow_drop_down,
            //                       size: 30,
            //                     ),
            //                     title: Text(
            //                       dataList[index]['question'],
            //                       style: const TextStyle(
            //                           fontFamily: 'Cera Pro',
            //                           fontSize: 18,
            //                           // color: MyColors.mainFontColor,
            //                           fontWeight: FontWeight.w500),
            //                     ),
            //                     children: [
            //                       Padding(
            //                         padding: const EdgeInsets.only(
            //                             left: 20, right: 20, bottom: 10),
            //                         child: dataList[index]['typeQue'] == "image"
            //                             ? Column(
            //                                 children: [
            //                                   ClipRRect(
            //                                     borderRadius:
            //                                         BorderRadius.circular(20),
            //                                     child: Image.network(
            //                                         dataList[index]['answer']),
            //                                   ),
            //                                   ElevatedButton(
            //                                       onPressed: () async {
            //                                         try {
            //                                           Fluttertoast.showToast(
            //                                               msg:
            //                                                   'Image downloading started.');
            //                                           imageId = await ImageDownloader
            //                                               .downloadImage(
            //                                                   dataList[index]
            //                                                       ['answer'],
            //                                                   destination: AndroidDestinationType
            //                                                       .custom(
            //                                                           directory:
            //                                                               'images')
            //                                                     ..inExternalFilesDir());

            //                                           if (imageId == null) {
            //                                             return;
            //                                           }

            //                                           ImageDownloader.callback(
            //                                               onProgressUpdate:
            //                                                   (String? imageId,
            //                                                       int progress) {
            //                                             setState(() {
            //                                               _progress = progress;
            //                                             });
            //                                           });
            //                                           Fluttertoast.showToast(
            //                                               msg:
            //                                                   'Image downloaded.');
            //                                         } on PlatformException catch (error) {
            //                                           Fluttertoast.showToast(
            //                                               msg:
            //                                                   'Image downloading failed.');
            //                                           CustomLogger.instance
            //                                               .singleLine(
            //                                                   error.toString());
            //                                         }
            //                                       },
            //                                       child: _progress == 0
            //                                           ? const Text("Download")
            //                                           : _progress == 100
            //                                               ? const Text("Saved")
            //                                               : Text("$_progress%"))
            //                                 ],
            //                               )
            //                             : Text(
            //                                 dataList[index]['answer'],
            //                                 style: const TextStyle(
            //                                     fontFamily: 'Cera Pro',
            //                                     color: MyColors.whiteColor,
            //                                     fontWeight: FontWeight.w500),
            //                               ),
            //                       ),
            //                     ],
            //                   ),
            //                 );

            //                 // InkWell(
            //                 //     onTap: () async {},
            //                 //     child: QAItem(
            //                 //         question: dataList[index]['question'],
            //                 //         answer: dataList[index]['answer'],
            //                 //         type: dataList[index]['typeQue']));
            //               }),
            //         );
            //       }
            //     } else {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //   },
            // ),

            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      // color: MyColors.mainFontColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureCard(
                      color: MyColors.firstSuggestionBoxColor,
                      headerText: "ChatGPT",
                      descText:
                          "A smarter way to stay organized and informed with ChatGPT",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureCard(
                      color: MyColors.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descText:
                          "Get inspired and stay creative with your personal assistant powered by Dall-E",
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureCard(
                      color: MyColors.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descText:
                          "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: size.height * 0.02,
            // ),
            // Padding(
            //   padding: EdgeInsets.only(left: 20, right: size.width * 0.21),
            //   child: Container(
            //     decoration:
            //         BoxDecoration(borderRadius: BorderRadius.circular(20)),
            //     child: Row(
            //       children: [
            //         SizedBox(
            //           height: size.height * 0.06,
            //           width: size.width * 0.6,
            //           child: TextField(
            //             textCapitalization: TextCapitalization.sentences,
            //             style: const TextStyle(color: Colors.white),
            //             controller: _textController,
            //             decoration: const InputDecoration(
            //               fillColor: Color(0xff444654),
            //               filled: true,
            //               // border: InputBorder(
            //               //   borderSide: BorderSide()
            //               // ),
            //               focusedBorder: InputBorder.none,
            //               enabledBorder: InputBorder.none,
            //               errorBorder: InputBorder.none,
            //               disabledBorder: InputBorder.none,
            //             ),
            //           ),
            //         ),
            //         _buildSubmit()
            //       ],
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: size.height * 0.02,
            // ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: Row(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20).copyWith(left: 35),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    SizedBox(
                      height: size.height * 0.06,
                      width: size.width * 0.55,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(color: Colors.white),
                        controller: _textController,
                        decoration: const InputDecoration(
                          fillColor: Color(0xff444654),
                          filled: true,
                          // border: InputBorder(
                          //   borderSide: BorderSide()
                          // ),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    _buildSubmit()
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: MyColors.assistantCircleColor,
              onPressed: () async {
                if (await speechToText.hasPermission &&
                    speechToText.isNotListening) {
                  await startListening();
                } else if (speechToText.isListening) {
                  // setState(() {
                  //   isMicLoading = true;
                  // });
                  // Timer(const Duration(seconds: 1), () async {
                  //   CustomLogger.instance.singleLine("lastWords: $lastWords");
                  //   final speech = await openAIService.isArtPromptAPI(lastWords);
                  //   if (speech.contains('https')) {
                  //     generatedImageUrl = speech;
                  //     generatedContent = null;
                  //     setState(() {});
                  //   } else {
                  //     generatedImageUrl = null;
                  //     generatedContent = speech;
                  //     setState(() {});
                  //     await systemSpeak(speech);
                  //   }
                  //   await stopListening();
                  //   setState(() {
                  //     isMicLoading = false;
                  //   });
                  // });
                } else {
                  await initSpeech();
                }
              },
              tooltip: 'Listen',
              child: isMicLoading
                  ? const CircularProgressIndicator()
                  : Icon(
                      speechToText.isListening ? Icons.stop : Icons.mic,
                      color: MyColors.blackColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Container(
      color: const Color(0xff444654),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(5.82),
              child: CircularProgressIndicator(),
            )
          : IconButton(
              icon: const Icon(
                Icons.send_rounded,
                size: 30,
                color: Color.fromRGBO(142, 142, 160, 1),
              ),
              onPressed: () async {
                if (_textController.text.isEmpty) return;
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                setState(() {
                  isLoading = true;
                });
                final speech =
                    await openAIService.isArtPromptAPI(_textController.text);

                if (speech.contains('https')) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                  setState(() {});
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  setState(() {});
                  await systemSpeak(speech);
                }

                lastWords = _textController.text;
                _textController.clear();
                setState(
                  () {
                    isLoading = false;
                  },
                );
              },
            ),
    );
  }
}
