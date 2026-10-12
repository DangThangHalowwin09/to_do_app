import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_to_do_list/core/utils/drive_link.dart';

void main() {
  const direct = 'https://drive.google.com/uc?export=view&id=ABC123';

  test('link dạng /file/d/<id>/view', () {
    expect(driveLinkToDirect('https://drive.google.com/file/d/ABC123/view?usp=sharing'), direct);
  });

  test('link dạng open?id=<id>', () {
    expect(driveLinkToDirect('https://drive.google.com/open?id=ABC123'), direct);
  });

  test('link dạng uc?id=<id>&export=download', () {
    expect(driveLinkToDirect('https://drive.google.com/uc?id=ABC123&export=download'), direct);
  });

  test('link không phải Drive được giữ nguyên', () {
    expect(driveLinkToDirect('https://example.com/a.png'), 'https://example.com/a.png');
    expect(driveLinkToDirect(''), '');
  });
}
