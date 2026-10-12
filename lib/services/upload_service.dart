import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/app_logger.dart';

class UploadService {
  UploadService._();

  /// Tải ảnh lên Firebase Storage (chạy được cả mobile lẫn web) và trả về link tải về.
  static Future<String> uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final extension = image.name.contains('.') ? image.name.split('.').last.toLowerCase() : 'jpg';
      final ref = FirebaseStorage.instance.ref('blog_images/${const Uuid().v4()}.$extension');

      await ref.putData(bytes, SettableMetadata(contentType: 'image/$extension'));
      return await ref.getDownloadURL();
    } catch (e) {
      AppLog.e('Tải ảnh lên thất bại', e);
      rethrow;
    }
  }
}
