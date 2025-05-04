import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UploadService {
  static Future<String> uploadImage(File image) async {
    try {
      // Lấy phần mở rộng của file
      String extension = image.path.split('.').last;

      // Tạo một tên duy nhất cho tệp
      final ref = FirebaseStorage.instance.ref().child('blog_images/${Uuid().v4()}.$extension');

      // Tải ảnh lên Firebase Storage
      await ref.putFile(image);

      // Lấy URL tải xuống
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Lỗi tải ảnh lên Firebase: $e');
    }
  }
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Lấy reference đến ảnh từ URL
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);

      // Xóa ảnh khỏi Firebase Storage
      await ref.delete();
    } catch (e) {
      throw Exception('Lỗi xóa ảnh: $e');
    }
  }
}
