class SSCResponse {
  bool success;
  String password;
  String uid;
  String errorMessage;
  String docId;
  SSCResponse({
    required this.success,
    this.password = '',
    this.uid = '',
    this.errorMessage = '',
    this.docId = '',
  });
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'password': password,
    };
  }

  factory SSCResponse.fromJson(Map<String, dynamic> json) => SSCResponse(
        success: json['success'],
        password: json['password'],
      );
}
