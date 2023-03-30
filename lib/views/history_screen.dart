import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:myassistant/provider/apiResponse.dart';
import 'package:myassistant/provider/recent_qna_provider.dart';
import 'package:myassistant/views/qa_item.dart';

import '../my_colors.dart';
import '../services/custom_logger.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RecentQnAProvider recentQnAProvider = RecentQnAProvider();
  String? imageId;
  int _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            "History",
            style: TextStyle(
              fontFamily: 'Cera Pro',
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await recentQnAProvider.deleteAllRecentQnA();
                setState(() {});
              },
              icon: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.delete),
              ))
        ],
        // leading: const Icon(Icons.menu),
      ),
      body: FutureBuilder<ProviderResponse<List<dynamic>>>(
        future: recentQnAProvider.getRecentQnA(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.data == null) {
              return const SizedBox();
            } else {
              List dataList = snapshot.data!.data!;
              return SingleChildScrollView(
                child: ListView.builder(
                    itemCount: dataList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 15, left: 10, right: 10),
                        child: ExpansionTile(
                          textColor: MyColors.whiteColor,
                          trailing: const Icon(
                            Icons.arrow_drop_down,
                            size: 30,
                          ),
                          title: Text(
                            dataList[index]['question'],
                            style: const TextStyle(
                                fontFamily: 'Cera Pro',
                                fontSize: 18,
                                // color: MyColors.mainFontColor,
                                fontWeight: FontWeight.w500),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 10),
                              child: dataList[index]['typeQue'] == "image"
                                  ? Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.network(
                                              dataList[index]['answer']),
                                        ),
                                        ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Image downloading started.');
                                                imageId = await ImageDownloader
                                                    .downloadImage(
                                                        dataList[index]['answer'],
                                                        destination:
                                                            AndroidDestinationType
                                                                .custom(
                                                                    directory:
                                                                        'images')
                                                              ..inExternalFilesDir());
              
                                                if (imageId == null) {
                                                  return;
                                                }
              
                                                ImageDownloader.callback(
                                                    onProgressUpdate:
                                                        (String? imageId,
                                                            int progress) {
                                                  setState(() {
                                                    _progress = progress;
                                                  });
                                                });
                                                Fluttertoast.showToast(
                                                    msg: 'Image downloaded.');
                                              } on PlatformException catch (error) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Image downloading failed.');
                                                CustomLogger.instance
                                                    .singleLine(error.toString());
                                              }
                                            },
                                            child: _progress == 0
                                                ? const Text("Download")
                                                : _progress == 100
                                                    ? const Text("Saved")
                                                    : Text("$_progress%"))
                                      ],
                                    )
                                  : Text(
                                      dataList[index]['answer'],
                                      style: const TextStyle(
                                          fontFamily: 'Cera Pro',
                                          color: MyColors.whiteColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                            ),
                          ],
                        ),
                      );
              
                      // InkWell(
                      //     onTap: () async {},
                      //     child: QAItem(
                      //         question: dataList[index]['question'],
                      //         answer: dataList[index]['answer'],
                      //         type: dataList[index]['typeQue']));
                    }),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
