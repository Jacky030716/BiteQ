// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> loadImage(Uint8List bytes) async {
  print('[WEB] loadImage(Uint8List) called');
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);

}
