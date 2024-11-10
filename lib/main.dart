import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Management')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerPage()),
                );
              },
              child: Text('Scan QR Code'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
              },
              child: Text('Add Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckItemPage()),
                );
              },
              child: Text('Check Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BorrowItemPage()),
                );
              },
              child: Text('Borrow Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  QRScannerPageState createState() => QRScannerPageState();
}

class QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  String? scannedCode;
  bool isScanning = false;

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

  Future<void> saveToExcel(String code) async {
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/inventory.xlsx';
    var file = File(filePath);

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([code]);

    file.writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to Excel: $filePath')),
    );
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
                      stopScanning();
                    });
                    saveToExcel(code);
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 50, // Set the desired height
            width: 200, // Set the desired width
            child: ElevatedButton(
              onPressed: () {
                startScanning();
              },
              child: const Text('Scan QR Code'),
            ),
          ),
          if (scannedCode != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50, // Set the desired height
                width: 200, // Set the desired width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeResultPage(code: scannedCode!),
                      ),
                    );
                  },
                  child: const Text('Show QR Code Data'),
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

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> addItem(String item, int quantity) async {
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/inventory.xlsx';
    var file = File(filePath);

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([item, quantity, 'Available']);

    file.writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item added to Excel: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addItem(_itemController.text, int.parse(_quantityController.text));
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckItemPage extends StatefulWidget {
  @override
  _CheckItemPageState createState() => _CheckItemPageState();
}

class _CheckItemPageState extends State<CheckItemPage> {
  List<List<Data?>> items = [];

  Future<void> loadItems() async {
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/inventory.xlsx';
    var file = File(filePath);

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Sheet1'];
    items = sheetObject.rows;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Item'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index][0]?.value.toString() ?? ''),
            subtitle: Text('Quantity: ${items[index][1]?.value.toString() ?? ''}, Status: ${items[index][2]?.value.toString() ?? ''}'),
          );
        },
      ),
    );
  }
}

class BorrowItemPage extends StatefulWidget {
  @override
  _BorrowItemPageState createState() => _BorrowItemPageState();
}

class _BorrowItemPageState extends State<BorrowItemPage> {
  final TextEditingController _itemController = TextEditingController();

  Future<void> borrowItem(String item) async {
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/inventory.xlsx';
    var file = File(filePath);

    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    Sheet sheetObject = excel['Sheet1'];
    var row = sheetObject.rows.firstWhere((row) => row[0]?.value == item, orElse: () => null!);

    if (row != null && row[2]?.value == 'Available') {
      row[2]?.value = 'Borrowed';
      file.writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item borrowed: $item')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item not found or already borrowed: $item')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                borrowItem(_itemController.text);
              },
              child: Text('Borrow Item'),
            ),
          ],
        ),
      ),
    );
  }
}