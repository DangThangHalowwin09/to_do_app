import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UploadService {static Future<String> uploadImage(File image) async {
  try {
    // Verify file exists and is readable
    if (!image.existsSync()) {
      throw Exception('File does not exist at path: ${image.path}');
    }

    final extension = image.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$extension';
    final ref = FirebaseStorage.instance.ref().child('blog_images/$fileName');

    print('[UploadService] Starting upload: $fileName');

    // Start the upload task
    final uploadTask = ref.putFile(image);

    // Wait for the upload to complete and check its state
    final taskSnapshot = await uploadTask;
    if (taskSnapshot.state == TaskState.success) {
      // Upload successful, get the download URL
      final downloadUrl = await ref.getDownloadURL();
      print('[UploadService] Upload successful: $downloadUrl');
      return downloadUrl;
    } else {
      // Upload failed
      throw Exception('Upload failed with state: ${taskSnapshot.state}');
    }
  } catch (e) {
    print('[UploadService] Error uploading image: $e');
    throw Exception('Failed to upload image to Firebase: $e');
  }
}

  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      print('[UploadService] Đã xóa ảnh: $imageUrl');
    } catch (e) {
      print('[UploadService] Lỗi khi xóa ảnh: $e');
      throw Exception('Lỗi xóa ảnh: $e');
    }
  }
}
