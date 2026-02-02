class InventoryItem {
  final int id;
  final String itemCode;
  final String itemName;
  final String description;
  final double availableQuantity;
  final double taxGroup; // tax percentage, e.g. 15.0
  final double price; // gross price (tax-inclusive) per unit

  InventoryItem({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.availableQuantity,
    required this.taxGroup,
    required this.price,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] as num).toInt(),
      itemCode: (json['itemCode'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0.0,
      taxGroup: (json['taxGroup'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}


