import 'dart:convert' as convert;
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const KEY = 'AIzaSyDCHHs-nQ2pNZw2j9Lgx2x1Y0zDOUqfmm4';
const BASE_URL = 'https://texttospeech.googleapis.com';
const URL = '$BASE_URL/v1/text:synthesize?key=$KEY';


class SpeechRepository {
  Future<String> textToSpeech(id, arab) async {
    final Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final body = convert.json.encode({
      'input': {
        'text': arab,
      },
      'voice': {
        'languageCode': 'ar-AR',
        'ssmlGender': 'MALE',
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
      },
    });
    try {
      final http.Response response = await http.post(
        URL,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        final audioContent = jsonResponse['audioContent'];
        final Uint8List bytes = convert.base64.decode(audioContent);
        final String dir = (await getApplicationDocumentsDirectory()).path;
        final String fullPath = '$dir/$id.mp3';
        final File file = File(fullPath);
        await file.writeAsBytes(bytes);
        return file.path;
      } else {
        return throw Error();
      }
    } catch (e) {
      return throw Error();
    }
  }
}