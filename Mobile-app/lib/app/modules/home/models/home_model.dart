import 'package:meta/meta.dart';
import 'dart:convert';

class ProductsScreen {
  List<Cart> carts;
  int total;
  int skip;
  int limit;

  ProductsScreen({
    required this.carts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsScreen.fromRawJson(String str) => ProductsScreen.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductsScreen.fromJson(Map<String, dynamic> json) => ProductsScreen(
    carts: List<Cart>.from(json["carts"].map((x) => Cart.fromJson(x))),
    total: json["total"],
    skip: json["skip"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "carts": List<dynamic>.from(carts.map((x) => x.toJson())),
    "total": total,
    "skip": skip,
    "limit": limit,
  };
}

class Cart {
  int id;
  List<Product> products;
  double total;
  double discountedTotal;
  int userId;
  int totalProducts;
  int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromRawJson(String str) => Cart.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"],
    products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    total: json["total"]?.toDouble(),
    discountedTotal: json["discountedTotal"]?.toDouble(),
    userId: json["userId"],
    totalProducts: json["totalProducts"],
    totalQuantity: json["totalQuantity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
    "total": total,
    "discountedTotal": discountedTotal,
    "userId": userId,
    "totalProducts": totalProducts,
    "totalQuantity": totalQuantity,
  };
}

class Product {
  int id;
  String title;
  double price;
  int quantity;
  double total;
  double discountPercentage;
  double discountedTotal;
  String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory Product.fromRawJson(String str) => Product.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    title: json["title"],
    price: json["price"]?.toDouble(),
    quantity: json["quantity"],
    total: json["total"]?.toDouble(),
    discountPercentage: json["discountPercentage"]?.toDouble(),
    discountedTotal: json["discountedTotal"]?.toDouble(),
    thumbnail: json["thumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "quantity": quantity,
    "total": total,
    "discountPercentage": discountPercentage,
    "discountedTotal": discountedTotal,
    "thumbnail": thumbnail,
  };
}
