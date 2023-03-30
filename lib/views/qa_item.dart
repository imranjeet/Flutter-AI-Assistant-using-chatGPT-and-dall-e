import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:myassistant/my_colors.dart';
import 'package:myassistant/services/custom_logger.dart';

class QAItem extends StatefulWidget {
  const QAItem({
    Key? key,
    required this.question,
    required this.answer,
    required this.type,
  }) : super(key: key);

  final String question;
  final String answer;
  final String type;

  @override
  State<QAItem> createState() => _QAItemState();
}

class _QAItemState extends State<QAItem> {
  String? imageId;
  int _progress = 0;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: ExpansionTile(
        trailing: const Icon(
          Icons.arrow_drop_down,
          size: 30,
        ),
        title: Text(
          widget.question,
          style: const TextStyle(
              fontFamily: 'Cera Pro',
              fontSize: 18,
              color: MyColors.mainFontColor,
              fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: widget.type == "image"
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(widget.answer),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              imageId = await ImageDownloader.downloadImage(
                                  widget.answer,
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
                              CustomLogger.instance.singleLine(error.toString());
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
                    widget.answer,
                    style: const TextStyle(
                        fontFamily: 'Cera Pro',
                        color: MyColors.mainFontColor,
                        fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }
}
