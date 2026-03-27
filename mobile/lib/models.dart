class Book {
  final int? id;
  final String title;
  final String author;
  final double price;
  final int copies;

  Book({this.id, required this.title, required this.author, required this.price, required this.copies});

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'] ?? '',
    author: json['author'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    copies: json['copies'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'author': author, 'price': price, 'copies': copies,
  };
}

class Magazine {
  final int? id;
  final String title;
  final double price;
  final int copies;
  final int orderQty;
  final String currentIssue;

  Magazine({this.id, required this.title, required this.price, required this.copies, required this.orderQty, required this.currentIssue});

  factory Magazine.fromJson(Map<String, dynamic> json) => Magazine(
    id: json['id'],
    title: json['title'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    copies: json['copies'] ?? 0,
    orderQty: json['orderQty'] ?? 0,
    currentIssue: json['currentIssue'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'price': price, 'copies': copies, 'orderQty': orderQty, 'currentIssue': currentIssue,
  };
}

class CartItem {
  final int id;
  final String title;
  final String type;
  final double price;

  CartItem({required this.id, required this.title, required this.type, required this.price});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    title: json['title'] ?? json['description'] ?? 'Unknown Item',
    type: json['productType'] ?? 'Unknown',
    price: (json['price'] ?? 0).toDouble(),
  );
}
