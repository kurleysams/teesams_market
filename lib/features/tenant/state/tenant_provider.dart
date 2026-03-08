class TenantProvider extends ChangeNotifier {
  String? _slug;

  String get slug => _slug ?? "default";

  void setTenant(String slug) {
    _slug = slug;
    notifyListeners();
  }
}
