import 'dart:io';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iitf_selfy_app/img_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class ImageView extends StatefulWidget {
  final File? imge;
  const ImageView({super.key, required this.imge});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  String qr = '';
  bool _isProcessing = false;
  void upload(String path) async {
    _isProcessing = true;
    setState(() {});
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://gitdgtl.com/image_upload.aspx'));
    request.files.add(await http.MultipartFile.fromPath('file', path));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());

      final result = await response.stream.bytesToString();

      final rs = imageUploadModelFromJson(result);
      qr = rs.path ?? '';
      showCustomDialog(context);
    } else {}

    _isProcessing = false;
    setState(() {});
  }

  ScreenshotController screenshotController = ScreenshotController();
  Future<void> _takeScreenshot() async {
    _isProcessing = true;
    setState(() {});
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/screenshot.png';

    // Capture the screenshot and save as a file
    screenshotController
        .captureAndSave(
      path,
      fileName: 'screenshot.png',
    )
        .then((filePath) {
      if (filePath != null) {
        upload(filePath);
      }
    }).catchError((error) {
      print("Error capturing screenshot: $error");
    });
  }

  void showCustomDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            // height: 240,
            width: 300,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: SizedBox.expand(
                child: QrImageView(
                  data: qr,
                  version: QrVersions.auto,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: Center(
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isProcessing,
      blurEffectIntensity: 4,
      dismissible: false,
      opacity: 0.4,
      color: Colors.green,
      child: Screenshot(
        controller: screenshotController,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/bg.jpg',
                fit: BoxFit.cover,
              ),
              if (widget.imge != null)
                Positioned(
                  bottom: 0,
                  child: Image.file(
                    widget.imge!,
                    // width: MediaQuery.of(context).size.width * .8,
                  ),
                ),
              Positioned(
                bottom: 50,
                child: TextButton(
                  onPressed: () {
                    _takeScreenshot();
                  },
                  child: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    child: const Text(
                      'QRCODE',
                      style: TextStyle(color: Colors.white, fontSize: 13.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
