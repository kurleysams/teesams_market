class TenantOrderFilter {
  final String lifecycle;
  final String? status;
  final String? orderType;
  final String? search;
  final String? date;
  final int page;
  final int perPage;

  const TenantOrderFilter({
    this.lifecycle = 'active',
    this.status,
    this.orderType,
    this.search,
    this.date,
    this.page = 1,
    this.perPage = 20,
  });

  TenantOrderFilter copyWith({
    String? lifecycle,
    String? status,
    String? orderType,
    String? search,
    String? date,
    int? page,
    int? perPage,
    bool clearStatus = false,
    bool clearOrderType = false,
    bool clearSearch = false,
    bool clearDate = false,
  }) {
    return TenantOrderFilter(
      lifecycle: lifecycle ?? this.lifecycle,
      status: clearStatus ? null : (status ?? this.status),
      orderType: clearOrderType ? null : (orderType ?? this.orderType),
      search: clearSearch ? null : (search ?? this.search),
      date: clearDate ? null : (date ?? this.date),
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }

  Map<String, dynamic> toQuery() {
    final map = <String, dynamic>{
      'lifecycle': lifecycle,
      'page': page,
      'per_page': perPage,
    };

    if (status != null && status!.isNotEmpty) {
      map['status'] = status;
    }
    if (orderType != null && orderType!.isNotEmpty) {
      map['order_type'] = orderType;
    }
    if (search != null && search!.trim().isNotEmpty) {
      map['search'] = search!.trim();
    }
    if (date != null && date!.trim().isNotEmpty) {
      map['date'] = date!.trim();
    }

    return map;
  }
}
