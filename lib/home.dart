import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _shift = TextEditingController();
  final TextEditingController _hashController =
      TextEditingController(); // For verification
  final TextEditingController _keyController =
      TextEditingController(); // For verification
  String _output = ""; // To store the result (encrypted or decrypted)
  String _generatedHash = ""; // Store generated hash
  String _generatedKey = ""; // Store generated key
  int _currentIndex = 0; // To track the selected tab

  /// Generate a random key
  String generateRandomKey() {
    final random = Random();
    final keyBytes =
        List<int>.generate(16, (_) => random.nextInt(256)); // 16 bytes key
    return base64UrlEncode(keyBytes);
  }

  /// Perform HMAC-SHA256 hash
  String createHash(String text, String key) {
    final keyBytes = utf8.encode(key);
    final inputBytes = utf8.encode(text);
    final hmac = Hmac(sha256, keyBytes); // Create HMAC-SHA256 instance
    final digest = hmac.convert(inputBytes);
    return base64UrlEncode(digest.bytes); // Return hash in base64 encoding
  }

  /// Apply shift cipher to the text
  String applyShiftCipher(String text, int shift) {
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

  /// Encrypt with shift cipher and generate hash
  void encryptWithShiftAndHash(String text, int shift) {
    // Apply the shift cipher
    final shiftedText = applyShiftCipher(text, shift);
    // Generate a random key
    final randomKey = generateRandomKey();
    _generatedKey = randomKey; // Store the generated key
    // Generate hash
    final hash = createHash(shiftedText, randomKey);
    _generatedHash = hash; // Store the generated hash
    _output = shiftedText; // Store the encrypted (shifted) text for display
  }

  /// Verify hash
  String verifyHash(String hash, String key, String shiftedText) {
    // Verify hash
    final computedHash = createHash(shiftedText, key);
    if (computedHash != hash) {
      return "Hash verification failed! Data may have been tampered with.";
    }
    return "Hash verified successfully! Data is intact.";
  }

  /// Handle encryption or verification
  void _processText() {
    final int shiftValue = int.tryParse(_shift.text) ?? 0;
    setState(() {
      if (_currentIndex == 0) {
        // Encrypt
        encryptWithShiftAndHash(_input.text, shiftValue);
      } else {
        // Verify
        _output = verifyHash(
          _hashController.text,
          _keyController.text,
          _input.text,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_currentIndex == 0 ? 'Encrypt Text' : 'Verify Hash'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentIndex == 0) ...[
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
                child: const Text('Encrypt'),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shifted Text:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      _output.isEmpty ? "No result yet" : _output,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hash:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      _generatedHash.isEmpty ? "No result yet" : _generatedHash,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      _generatedKey.isEmpty ? "No result yet" : _generatedKey,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: _input,
                decoration: const InputDecoration(
                  labelText: 'Shifted Text',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white54,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _hashController,
                decoration: const InputDecoration(
                  labelText: 'Hash',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white54,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Key',
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
                child: const Text('Verify'),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      _output.isEmpty ? "No result yet" : _output,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _output = "";
            _input.text = ''; // Clear the input and output when switching tabs
            _hashController.clear();
            _keyController.clear();
            _shift.clear();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Encrypt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Verify',
          ),
        ],
      ),
    );
  }
}
