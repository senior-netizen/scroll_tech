class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.variantId,
    required this.depositAmount,
    required this.status,
  });

  final String id;
  final String userId;
  final String variantId;
  final double depositAmount;
  final String status;
}
