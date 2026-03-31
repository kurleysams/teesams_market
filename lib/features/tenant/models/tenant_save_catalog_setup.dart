class SaveCatalogSetupRequest {
  final int productCount;
  final bool readyForReview;

  SaveCatalogSetupRequest({
    required this.productCount,
    required this.readyForReview,
  });

  Map<String, dynamic> toJson() {
    return {'product_count': productCount, 'ready_for_review': readyForReview};
  }
}
