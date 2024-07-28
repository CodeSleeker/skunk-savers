import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  String? from;
  String? to;
  String? content;
  Timestamp? createdAt;
  String? type;
  String? id;
  ChatData({
    this.from,
    this.to,
    this.createdAt,
    this.content,
    this.type,
    this.id,
  });
  ChatData.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    createdAt = json['created_at'];
    content = json['content'];
    type = json['type'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    data['content'] = content;
    data['created_at'] = createdAt;
    data['type'] = type;
    return data;
  }

  static List<ChatData> fromList(List<dynamic> list) {
    List<ChatData> chats = [];
    for (var data in list) {
      ChatData chat = ChatData.fromJson(data.data());
      chat.id = data.id;
      chats.add(chat);
    }
    return chats;
  }
}
