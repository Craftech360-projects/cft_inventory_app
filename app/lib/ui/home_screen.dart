import 'package:app/functions/print_label.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _qrCodeController = TextEditingController();
  final TextEditingController _inventoryCodeController =
      TextEditingController();
  final TextEditingController _description1Controller = TextEditingController();
  final TextEditingController _description2Controller = TextEditingController();
  final TextEditingController _description3Controller = TextEditingController();
  bool _isLoading = false;

  void _printLabel() async {
    final qrData = _qrCodeController.text;
    final inventoryCode = _inventoryCodeController.text;
    final description1 = _description1Controller.text;
    final description2 = _description2Controller.text;
    final description3 = _description3Controller.text;

    if (qrData.isEmpty || inventoryCode.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please fill the required fields !',
          style: TextStyle(fontSize: 16),
        )),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await printLabel(qrData, inventoryCode, description1, description2,
          description3);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing has started!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing label: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: Text(
        'CFT Inventory App',
        style: TextStyle(fontSize: 18),
      )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _qrCodeController,
                decoration: InputDecoration(labelText: 'QR Code Data'),
              ),
              TextField(
                maxLength: 12,
                controller: _inventoryCodeController,
                decoration: InputDecoration(labelText: 'Inventory Code'),
              ),
              TextField(
                maxLength: 20,
                controller: _description1Controller,
                decoration: InputDecoration(labelText: 'Description 1'),
              ),
              TextField(
                maxLength: 16,
                controller: _description2Controller,
                decoration: InputDecoration(labelText: 'Description 2'),
              ),
              TextField(
                maxLength: 16,
                controller: _description3Controller,
                decoration: InputDecoration(labelText: 'Description 3'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      onPressed: _printLabel,
                      child: Text('Print Label'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
