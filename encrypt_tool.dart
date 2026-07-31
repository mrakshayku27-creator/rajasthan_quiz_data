import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() async {
  final rawBytes = [
    0x33, 0x0B, 0x26, 0x0F, 0x21, 0x32, 0x04, 0x14, 
    0x14, 0x13, 0x04, 0x42, 0x2A, 0x04, 0x18, 0x45, 
    0x53, 0x51, 0x53, 0x57, 0x3E, 0x32, 0x15, 0x00, 
    0x15, 0x08, 0x02, 0x25, 0x04, 0x02, 0x13, 0x18
  ];
  final salt = "RajasthanQuiz";
  final keyBuffer = StringBuffer();
  for (var i = 0; i < rawBytes.length; i++) {
    keyBuffer.writeCharCode(rawBytes[i] ^ salt.codeUnitAt(i % salt.length));
  }
  final secretKey = keyBuffer.toString();

  print("सीक्रेट एन्क्रिप्शन की सफलतापूर्वक जनरेट हो गई है!");

  final inputFile = File("quizzes.json");
  if (!await inputFile.exists()) {
    print("त्रुटि: टर्मक्स में 'quizzes.json' फ़ाइल नहीं मिली। कृपया पहले सादा quizzes.json यहाँ रखें।");
    return;
  }

  final rawJsonText = await inputFile.readAsString();
  
  final key = encrypt.Key.fromUtf8(secretKey);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
  );

  final encrypted = encrypter.encrypt(rawJsonText, iv: iv);
  
  final outputMap = {
    "payload": encrypted.base64
  };

  final outputFile = File("quizzes_encrypted.json");
  await outputFile.writeAsString(jsonEncode(outputMap));

  print("बधाई हो: 'quizzes_encrypted.json' बन गई है! इसे आप सुरक्षित गिटहब पर अपलोड कर सकते हैं।");
}
