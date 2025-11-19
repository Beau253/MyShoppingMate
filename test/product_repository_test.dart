import 'package:flutter_test/flutter_test.dart';
import 'package:my_shopping_mate/data/models/product_model.dart';
import 'package:my_shopping_mate/data/repositories/product_repository.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate a MockApiService
@GenerateMocks([ApiService])
import 'product_repository_test.mocks.dart';

void main() {
  late ProductRepository repository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    repository = ProductRepository(apiService: mockApiService);
  });

  group('ProductRepository', () {
    test('searchProducts calls correct endpoint and returns list of products', () async {
      // Arrange
      const query = 'milk';
      final mockResponse = [
        {
          'id': '1',
          'name': 'Organic Whole Milk',
          'brand': 'Horizon',
          'img': 'url',
          'price': 4.19,
          'store': 'Target'
        }
      ];
      when(mockApiService.get('/products/search?q=$query'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.searchProducts(query);

      // Assert
      verify(mockApiService.get('/products/search?q=$query')).called(1);
      expect(result, isA<List<Product>>());
      expect(result.length, 1);
      expect(result.first.name, 'Organic Whole Milk');
    });

    test('searchProducts returns empty list on error', () async {
      // Arrange
      const query = 'error';
      when(mockApiService.get('/products/search?q=$query'))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.searchProducts(query);

      // Assert
      expect(result, isEmpty);
    });
  });
}
