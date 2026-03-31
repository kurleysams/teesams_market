class SaveBusinessDetailsRequest {
  final String legalName;
  final String businessEmail;
  final String businessPhone;
  final String businessType;
  final String? registrationNumber;
  final String? taxNumber;

  SaveBusinessDetailsRequest({
    required this.legalName,
    required this.businessEmail,
    required this.businessPhone,
    required this.businessType,
    this.registrationNumber,
    this.taxNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'legal_name': legalName,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'business_type': businessType,
      'registration_number': registrationNumber,
      'tax_number': taxNumber,
    };
  }
}
