import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  QRScannerPageState createState() => QRScannerPageState();
}

class QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool isScanning = false;
  bool isData = false;

  void startScanning() {
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Text("Selamat Datang"),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: MobileScanner(
                controller: cameraController,
                onDetect: (barcode) {
                  if (isScanning && barcode.barcodes.isNotEmpty) {
                    final String code =
                        barcode.barcodes.first.displayValue ?? 'Unknown';
                    setState(() {
                      scannedCode = code;
                      isData = true;
                      stopScanning();
                    });
                  } else {
                    setState(() {
                      isData = false;
                      stopScanning();
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 30,
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  startScanning();
                  isData
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QRCodeResultPage(code: scannedCode!),
                          ),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Product code not found')),
                        );
                  ;
                },
                child: const Text('Scan QR Code'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRCodeResultPage extends StatelessWidget {
  final String code;

  const QRCodeResultPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Result'),
      ),
      body: Center(
        child: Text('QR Code Data: $code'),
      ),
    );
  }
}
