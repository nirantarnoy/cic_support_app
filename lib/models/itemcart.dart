class ItemCart {
  final id;
  final code;
  final name;
  String qty;
  final price;
  final line_discount;
  String remark;
  final unit_name;
  var onhand;

  ItemCart({
    this.id,
    this.code,
    this.name,
    required this.qty,
    this.price,
    this.line_discount,
    required this.remark,
    this.unit_name,
    this.onhand,
  });
}
