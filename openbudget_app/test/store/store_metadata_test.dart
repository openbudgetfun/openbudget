import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The store listing text in `fastlane/metadata`, checked against the limits
/// App Store Connect and Google Play enforce on upload.
void main() {
  const ios = 'fastlane/metadata/ios';
  const android = 'fastlane/metadata/android/en-US';

  String read(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: '$path is missing');
    return file.readAsStringSync().trim();
  }

  group('store listing limits', () {
    const limits = {
      '$ios/en-US/name.txt': 30,
      '$ios/en-US/subtitle.txt': 30,
      '$ios/en-US/promotional_text.txt': 170,
      '$ios/en-US/keywords.txt': 100,
      '$ios/en-US/description.txt': 4000,
      '$ios/en-US/release_notes.txt': 4000,
      '$android/title.txt': 30,
      '$android/short_description.txt': 80,
      '$android/full_description.txt': 4000,
      '$android/changelogs/default.txt': 500,
    };

    for (final MapEntry(key: path, value: limit) in limits.entries) {
      test('$path has text within $limit characters', () {
        final text = read(path);

        expect(text, isNotEmpty);
        expect(text.runes.length, lessThanOrEqualTo(limit));
      });
    }
  });

  test('keywords are comma separated and repeat no word from the name', () {
    final keywords = read('$ios/en-US/keywords.txt').split(',');
    final taken =
        '${read('$ios/en-US/name.txt')} '
                '${read('$ios/en-US/subtitle.txt')}'
            .toLowerCase()
            .split(RegExp('[^a-z]+'))
            .toSet();

    expect(keywords.toSet(), hasLength(keywords.length));
    for (final keyword in keywords) {
      expect(keyword, keyword.trim(), reason: 'no spaces around "$keyword"');
      expect(keyword, isNotEmpty);
      for (final word in keyword.split(' ')) {
        expect(taken, isNot(contains(word)), reason: '"$word" is in the name');
      }
    }
  });

  test('the listing links are the pages the site serves', () {
    expect(read('$ios/en-US/marketing_url.txt'), 'https://openbudget.app/');
    expect(
      read('$ios/en-US/support_url.txt'),
      'https://openbudget.app/support',
    );
    expect(
      read('$ios/en-US/privacy_url.txt'),
      'https://openbudget.app/privacy',
    );
  });

  test('both stores use the same name', () {
    expect(read('$android/title.txt'), read('$ios/en-US/name.txt'));
  });

  test('the descriptions differ only in how each store bills', () {
    final apple = read('$ios/en-US/description.txt').split('\n');
    final google = read('$android/full_description.txt').split('\n');

    expect(google, hasLength(apple.length));
    final different = [
      for (final (index, line) in apple.indexed)
        if (line != google[index]) (line, google[index]),
    ];
    expect(different, hasLength(1));
    expect(different.single.$1, contains('App Store'));
    expect(different.single.$2, contains('Google Play'));
  });

  test('descriptions keep the disclaimer and the policy links', () {
    for (final path in [
      '$ios/en-US/description.txt',
      '$android/full_description.txt',
    ]) {
      final text = read(path);

      expect(
        text,
        contains('not regulated financial or tax advice'),
        reason: path,
      );
      expect(text, contains('renews automatically'), reason: path);
      expect(text, contains('https://openbudget.app/privacy'), reason: path);
      expect(text, contains('https://openbudget.app/terms'), reason: path);
      expect(text, isNot(contains('!')), reason: path);
    }
  });
}
