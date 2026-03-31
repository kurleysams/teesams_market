class SavePayoutsRequest {
  final String provider;
  final bool setupComplete;
  final String? accountReference;

  SavePayoutsRequest({
    required this.provider,
    required this.setupComplete,
    this.accountReference,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'setup_complete': setupComplete,
      'account_reference': accountReference,
    };
  }
}
