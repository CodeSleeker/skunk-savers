class PushNotification {
  String? to;
  Data? data;
  PushNotification({
    this.to,
    this.data,
  });
  PushNotification.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    data = json['data'] == null ? null : Data.fromJson(json['data']);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['to'] = to;
    data['data'] = this.data!.toJson();
    return data;
  }
}

class Data {
  String? title;
  String? body;
  String? uid;
  String? type;
  Data({
    this.body,
    this.title,
    this.uid,
    this.type,
  });
  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    uid = json['uid'];
    type = json['type'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['uid'] = uid;
    data['type'] = type;
    return data;
  }
}
