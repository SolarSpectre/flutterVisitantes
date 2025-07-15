import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ImageService {
  static Future<String?> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    return picked?.path;
  }

  static Future<String> uploadVisitorImage(String path) async {
    final supabase = Supabase.instance.client;
    final file = File(path);
    final fileName = path.split('/').last;
    final storagePath = 'visitors/$fileName';
    await supabase.storage.from('visitors-photos').upload(storagePath, file);
    final url = supabase.storage.from('visitors-photos').getPublicUrl(storagePath);
    return url;
  }
}
