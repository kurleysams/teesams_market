class SaveStoreProfileRequest {
  final String storeName;
  final String storeSlug;
  final String? tagline;
  final String city;
  final String country;
  final String? addressLine1;

  SaveStoreProfileRequest({
    required this.storeName,
    required this.storeSlug,
    this.tagline,
    required this.city,
    required this.country,
    this.addressLine1,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'store_slug': storeSlug,
      'tagline': tagline,
      'city': city,
      'country': country,
      'address_line_1': addressLine1,
    };
  }
}
