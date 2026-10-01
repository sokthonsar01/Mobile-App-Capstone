import 'package:flutter_test/flutter_test.dart';
import 'package:interna/features/home/viewmodel/internships_viewmodel.dart';
import 'helpers/test_fixtures.dart';

void main() {
  group('InternshipsViewModel MVVM Unit Tests', () {
    final vm = InternshipsViewModel.instance;

    setUp(() {
      vm.clearFilters();
      vm.setInternships([]);
    });

    test('Initial state or setInternships sets items correctly', () {
      expect(vm.internships, isEmpty);
      expect(vm.isLoading, isFalse);

      vm.setInternships(testInternships);
      expect(vm.internships.length, equals(testInternships.length));
      expect(vm.filteredInternships.length, equals(testInternships.length));
    });

    test('Filtering by category returns matching category items', () {
      vm.setInternships(testInternships);

      vm.setCategory('Tech');
      for (final item in vm.filteredInternships) {
        expect(item.category.toLowerCase(), equals('tech'));
      }
    });

    test('Filtering by search query matches role or company', () {
      vm.setInternships(testInternships);

      vm.setSearch('Cellcard');
      expect(vm.filteredInternships, isNotEmpty);
      for (final item in vm.filteredInternships) {
        final matches = item.company.toLowerCase().contains('cellcard') ||
            item.role.toLowerCase().contains('cellcard');
        expect(matches, isTrue);
      }
    });

    test('clearFilters resets category and search query', () {
      vm.setCategory('Design');
      vm.setSearch('Flutter');
      expect(vm.selectedCategory, equals('Design'));
      expect(vm.searchQuery, equals('Flutter'));

      vm.clearFilters();
      expect(vm.selectedCategory, equals('All'));
      expect(vm.searchQuery, equals(''));
    });
  });
}
