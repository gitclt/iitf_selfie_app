import 'dart:io';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iitf_selfy_app/img_response.dart';
import 'package:intl/intl.dart';
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
  bool showButton = true;

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
    setState(() {
      showButton = false;
    });

    String getFormattedTimestamp() {
      final now = DateTime.now();
      final formatted = DateFormat('yyyyMMddTHH:mm').format(now);
      return formatted;
    }

    final timestamp = getFormattedTimestamp();
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/screenshot_$timestamp.png';

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
      setState(() {
        showButton = true; // Show the button after screenshot
      });
    }).catchError((error) {
      print("Error capturing screenshot: $error");
      setState(() {
        showButton =
            true; // Ensure the button is shown even if there's an error
      });
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
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            height: 200,
            // margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: SizedBox.expand(
              child: Center(
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
          body: Column(
            children: [
              Stack(
                //  fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/selfie_bg1.png',
                    fit: BoxFit.fill,
                    height: MediaQuery.of(context).size.height * 0.7,
                  ),
                  if (widget.imge != null)
                    Positioned(
                      top: 100,
                      bottom: 0,
                      child: Image.file(
                        widget.imge!,
                        fit: BoxFit.cover,
                        //  width: MediaQuery.of(context).size.width * 0.9,
                        // height: MediaQuery.of(context).size.height * 0.4,

                        // width: MediaQuery.of(context).size.width * .8,
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              if (showButton)
                TextButton(
                  onPressed: () {
                    _takeScreenshot();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    // padding: const EdgeInsets.symmetric(
                    //     vertical: 10, horizontal: 30),
                    child: const Center(
                      child: Text(
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
