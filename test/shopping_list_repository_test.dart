import 'package:flutter_test/flutter_test.dart';
import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/data/repositories/shopping_list_repository.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Reuse the mock from product_repository_test
import 'product_repository_test.mocks.dart';

void main() {
  late ApiShoppingListRepository repository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    repository = ApiShoppingListRepository(apiService: mockApiService);
  });

  group('ShoppingListRepository', () {
    test('getListItems calls correct endpoint', () async {
      const listId = '123';
      final mockResponse = [
        {
          'id': '1',
          'productName': 'Milk',
          'quantity': 1,
          'price': 3.99,
          'isChecked': false
        }
      ];
      when(mockApiService.get('/lists/$listId/items'))
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getListItems(listId);

      verify(mockApiService.get('/lists/$listId/items')).called(1);
      expect(result.length, 1);
      expect(result.first.productName, 'Milk');
    });

    test('addListItem calls correct endpoint', () async {
      const listId = '123';
      const productName = 'Bread';
      const quantity = 2;
      const price = 2.50;
      
      final mockResponse = {
        'id': '2',
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'isChecked': false
      };

      when(mockApiService.post('/lists/$listId/items', body: {
        'productName': productName,
        'quantity': quantity,
        'price': price,
      })).thenAnswer((_) async => mockResponse);

      final result = await repository.addListItem(
        listId: listId,
        productName: productName,
        quantity: quantity,
        price: price,
      );

      verify(mockApiService.post('/lists/$listId/items', body: anyNamed('body')))
          .called(1);
      expect(result.productName, productName);
    });
  });
}
