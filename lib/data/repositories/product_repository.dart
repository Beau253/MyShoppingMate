// A simple data model for a product. In a larger app, this would be in its own file.
class Product {
  final String name;
  final String brand;
  final double price;
  final String store;
  final String img;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.store,
    required this.img,
  });
}

class ProductRepository {
  // This is our FAKE database for the purpose of this simulation.
  // In a real app, this list would not exist here.
  final _mockProductDatabase = [
    Product(name: 'Organic Whole Milk', brand: 'Horizon', price: 4.19, store: 'Target', img: 'https://via.placeholder.com/150/FFC0CB/000000?Text=Milk'),
    Product(name: 'Free-Range Eggs', brand: 'Happy Egg Co.', price: 4.50, store: 'Walmart', img: 'https://via.placeholder.com/150/ADD8E6/000000?Text=Eggs'),
    Product(name: 'Sourdough Bread', brand: 'Bakery Fresh', price: 5.25, store: 'Walmart', img: 'https://via.placeholder.com/150/90EE90/000000?Text=Bread'),
    Product(name: 'Ground Coffee Beans', brand: 'Starbucks', price: 12.99, store: 'Target', img: 'https://via.placeholder.com/150/FFFF00/000000?Text=Coffee'),
    Product(name: 'Organic Chicken Breast', brand: 'Perdue', price: 8.99, store: 'Target', img: 'https://via.placeholder.com/150/FFA500/000000?Text=Chicken'),
  ];

  /// Simulates fetching search results from a backend API.
  Future<List<Product>> searchProducts(String query) async {
    // Simulate network latency.
    await Future.delayed(const Duration(seconds: 1));
    
    if (query.isEmpty) {
      return [];
    }

    final queryLower = query.toLowerCase();
    final results = _mockProductDatabase.where((product) {
      final nameLower = product.name.toLowerCase();
      final brandLower = product.brand.toLowerCase();
      return nameLower.contains(queryLower) || brandLower.contains(queryLower);
    }).toList();

    return results;
  }
}