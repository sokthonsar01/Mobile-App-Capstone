import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/saved/data/saved_internships_store.dart';
import 'helpers/test_fixtures.dart';

void main() {
  test('SavedInternshipsStore starts with no dummy bookmarks and saves/removes items', () async {
    final store = SavedInternshipsStore.instance;

    // 1. Verify no dummy hardcoded IDs exist
    expect(store.savedIds.contains('cm-01'), isFalse);
    expect(store.savedIds.contains('cellcard-03'), isFalse);

    // 2. Add an opportunity
    final testItem = testInternships.first;
    await store.save(testItem.id, item: testItem);

    expect(store.isSaved(testItem.id), isTrue);
    expect(store.getSavedOpportunities().any((i) => i.id == testItem.id), isTrue);

    // 3. Remove the opportunity
    await store.remove(testItem.id);
    expect(store.isSaved(testItem.id), isFalse);
    expect(store.getSavedOpportunities().any((i) => i.id == testItem.id), isFalse);
  });
}
