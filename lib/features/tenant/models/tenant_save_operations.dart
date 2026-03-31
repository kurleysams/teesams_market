class SaveOperationsRequest {
  final bool supportsDelivery;
  final bool supportsPickup;
  final String? pickupAddress;
  final List<Map<String, dynamic>> openingHours;
  final String? deliveryNotes;

  SaveOperationsRequest({
    required this.supportsDelivery,
    required this.supportsPickup,
    this.pickupAddress,
    this.openingHours = const [],
    this.deliveryNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'supports_delivery': supportsDelivery,
      'supports_pickup': supportsPickup,
      'pickup_address': pickupAddress,
      'opening_hours': openingHours,
      'delivery_notes': deliveryNotes,
    };
  }
}
