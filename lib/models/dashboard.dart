class Dashboard {
  final String summary;
  // Tambahkan field lain sesuai respons API

  Dashboard({required this.summary});

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(summary: json['summary']);
  }
}
