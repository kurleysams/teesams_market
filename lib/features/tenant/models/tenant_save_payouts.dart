class SavePayoutsRequest {
  final String? accountReference;

  const SavePayoutsRequest({this.accountReference});

  Map<String, dynamic> toJson() {
    return {'account_reference': accountReference};
  }
}
