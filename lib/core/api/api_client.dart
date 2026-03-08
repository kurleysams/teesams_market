class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl, String tenantSlug)
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {"X-Tenant": tenantSlug, "Content-Type": "application/json"},
        ),
      );
}
