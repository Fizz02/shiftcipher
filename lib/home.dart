import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _shift = TextEditingController();
  String _output = ""; // To store the result (encrypted or decrypted)
  int _currentIndex = 0; // To track the selected tab

  /// Function to perform Shift Cipher encryption
  String encrypt(String text, int shift) {
    shift = shift % 26; // Ensure the shift is within 0-25
    return text.split('').map((char) {
      if (RegExp(r'[a-z]').hasMatch(char)) {
        return String.fromCharCode(
            ((char.codeUnitAt(0) - 97 + shift) % 26) + 97);
      } else if (RegExp(r'[A-Z]').hasMatch(char)) {
        return String.fromCharCode(
            ((char.codeUnitAt(0) - 65 + shift) % 26) + 65);
      }
      return char; // Return non-alphabet characters as-is
    }).join();
  }

  /// Function to perform Shift Cipher decryption
  String decrypt(String text, int shift) {
    shift = shift % 26; // Ensure the shift is within 0-25
    return text.split('').map((char) {
      if (RegExp(r'[a-z]').hasMatch(char)) {
        return String.fromCharCode(
            ((char.codeUnitAt(0) - 97 - shift + 26) % 26) + 97);
      } else if (RegExp(r'[A-Z]').hasMatch(char)) {
        return String.fromCharCode(
            ((char.codeUnitAt(0) - 65 - shift + 26) % 26) + 65);
      }
      return char; // Return non-alphabet characters as-is
    }).join();
  }

  /// Function to handle encryption or decryption based on the selected tab
  void _processText() {
    final int shiftValue = int.tryParse(_shift.text) ?? 0;
    setState(() {
      if (_currentIndex == 0) {
        _output = encrypt(_input.text, shiftValue);
      } else {
        _output = decrypt(_input.text, shiftValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_currentIndex == 0 ? 'Encrypt Text' : 'Decrypt Text'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _input,
              decoration: const InputDecoration(
                labelText: 'Input Text',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white54,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              controller: _shift,
              decoration: const InputDecoration(
                labelText: 'Shift Value',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white54,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processText,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[200],
                shadowColor: Colors.black,
                elevation: 5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(_currentIndex == 0 ? 'Encrypt' : 'Decrypt'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Result:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                _output.isEmpty ? "No result yet" : _output,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _output = ""; // Clear the output when switching tabs
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Encrypt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            label: 'Decrypt',
          ),
        ],
      ),
    );
  }
}
