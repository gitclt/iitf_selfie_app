import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:iitf_selfy_app/api_key_model.dart';
import 'package:iitf_selfy_app/image_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class BackgroundRemovalPage extends StatefulWidget {
  const BackgroundRemovalPage({super.key});

  @override
  _BackgroundRemovalPageState createState() => _BackgroundRemovalPageState();
}

class _BackgroundRemovalPageState extends State<BackgroundRemovalPage> {
  File? _originalImage;
  File? _processedImage;
  bool _isProcessing = false;
  var bgApiKey = 'wiKA7k2kgi5zz33g1tjVVjg2';
  // Create a ScreenshotController

  final ImagePicker _picker = ImagePicker();

  onInit() {}

  Future<void> takeSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo != null) {
      setState(() {
        _originalImage = File(photo.path);
        _processedImage = null;
      });
      await getApiKey();
    }
  }

  Future<void> getApiKey() async {
    setState(() {
      _isProcessing = true;
    });

    final url = Uri.parse(
        'http://newtest.vkcparivar.com/api/flutter/task_management/key.aspx');
    try {
      final response = await http.post(url, body: {"key": bgApiKey});
      if (response.statusCode == 200) {
        final result = response.body;
        final keyValue = apiKeyModelFromJson(result);
        setState(() {
          _isProcessing = false;
        });
        print(keyValue.data!.first.key!);
        _removeBackground(keyValue.data!.first.key!);
      } else {
        throw Exception('Failed to remove background');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _removeBackground(String apiKey) async {
    if (_originalImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Replace YOUR_API_KEY with your actual Remove.bg API key

      final url = Uri.parse('https://api.remove.bg/v1.0/removebg');

      // Prepare the image file
      final bytes = await _originalImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Make API request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': apiKey,
        },
        body: json.encode({
          'image_file_b64': base64Image,
          'size': 'auto',
          'format': 'png',
        }),
      );

      if (response.statusCode == 200) {
        // Save the processed image
        final outputFile = File('${_originalImage!.path}_no_bg.png');
        await outputFile.writeAsBytes(response.bodyBytes);

        setState(() {
          _processedImage = outputFile;
          _isProcessing = false;
        });

        Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) => ImageView(
                      imge: _processedImage!,
                    )));
      } else {
        throw Exception('Failed to remove background');
      }
    } catch (e) {
      print('Error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove background')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _isProcessing,
      blurEffectIntensity: 4,
      dismissible: false,
      opacity: 0.4,
      color: Colors.green,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/iitf.png',
                width: MediaQuery.of(context).size.width * .3,
                height: MediaQuery.of(context).size.width * .3,
                fit: BoxFit.cover,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                    onTap: () {
                      takeSelfie();

                      // Navigator.push(
                      //     // ignore: use_build_context_synchronously
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => ImageView(
                      //               imge: _processedImage,
                      //             )));
                    },
                    child: Image.asset(
                      'assets/ifram.png',
                    )),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
