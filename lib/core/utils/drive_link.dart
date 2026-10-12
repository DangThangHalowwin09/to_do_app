/// Chuyển link chia sẻ Google Drive thành link ảnh trực tiếp để `Image.network` hiển thị được.
/// Link không phải Drive được trả về nguyên vẹn.
String driveLinkToDirect(String url) {
  const direct = 'https://drive.google.com/uc?export=view&id=';

  final fileMatch = RegExp(r'drive\.google\.com/file/d/([^/?#]+)').firstMatch(url);
  if (fileMatch != null) return '$direct${fileMatch.group(1)}';

  final idMatch = RegExp(r'drive\.google\.com/(?:open|uc)\?(?:.*&)?id=([^&#]+)').firstMatch(url);
  if (idMatch != null) return '$direct${idMatch.group(1)}';

  return url;
}
