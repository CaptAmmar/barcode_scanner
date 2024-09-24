import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'package:camera/camera.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(git branch -M mainMyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRViewExample(camera: camera),
    );
  }
}

class QRViewExample extends StatefulWidget {
  final CameraDescription camera;

  QRViewExample({required this.camera});

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  CameraController? cameraController;
  String qrText = "";
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    cameraController?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('QR Code Scanner')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('QR Code Scanner')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            SizedBox(height: 16),
            isScanned
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _launchURL(qrText),
                    child: Text(
                      'Scanned URL: $qrText',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetScanner,
                    child: Text('Scan Again'),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Scan a QR code'),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code ?? '';
        isScanned = true;
      });
      controller.pauseCamera(); // Pause the camera after scanning
    });
  }

  void _resetScanner() {
    setState(() {
      qrText = "";
      isScanned = false;
    });
    qrController?.resumeCamera(); // Resume the camera for scanning
  }

  @override
  void dispose() {
    qrController?.dispose();
    cameraController?.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
