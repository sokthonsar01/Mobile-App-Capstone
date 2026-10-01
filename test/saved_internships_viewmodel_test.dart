import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/saved/viewmodel/saved_internships_viewmodel.dart';
import 'helpers/test_fixtures.dart';

void main() {
  test('SavedInternshipsViewModel MVVM state management and reactive notifications', () async {
    final viewModel = SavedInternshipsViewModel.instance;
    viewModel.resetToDefaults();

    // 1. Initial empty state (zero dummy data)
    expect(viewModel.savedInternships, isEmpty);
    expect(viewModel.savedIds, isEmpty);
    expect(viewModel.isLoading, isFalse);

    // 2. Add an internship
    final testItem = testInternships.first;
    int notifyCount = 0;
    viewModel.addListener(() => notifyCount++);

    await viewModel.save(testItem);

    expect(viewModel.isSaved(testItem.id), isTrue);
    expect(viewModel.savedInternships.length, 1);
    expect(viewModel.savedInternships.first.id, testItem.id);
    expect(notifyCount, greaterThan(0));

    // 3. Toggle off
    await viewModel.toggleSave(testItem);
    expect(viewModel.isSaved(testItem.id), isFalse);
    expect(viewModel.savedInternships, isEmpty);

    // 4. Toggle on
    await viewModel.toggleSave(testItem);
    expect(viewModel.isSaved(testItem.id), isTrue);
    expect(viewModel.savedInternships.length, 1);

    // 5. Clear all
    await viewModel.clearAll();
    expect(viewModel.savedInternships, isEmpty);
    expect(viewModel.savedIds, isEmpty);
  });
}
