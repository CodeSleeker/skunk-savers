import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/user.dart';

class Peer {
  String? uid;
  bool? hasNewMessage;
  Timestamp? createdAt;
  Timestamp? modifiedAt;
  SSCUser? user;
  String? peek;
  Peer({
    this.uid,
    this.hasNewMessage,
    this.createdAt,
    this.user,
    this.peek,
    this.modifiedAt,
  });
  Peer.fromJson(Map<String, dynamic> json) {
    // uid = json['uid'];
    hasNewMessage = json['has_new_message'];
    createdAt = json['created_at'];
    modifiedAt = json['modified_at'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['uid'] = uid;
    data['has_new_message'] = hasNewMessage;
    data['created_at'] = createdAt;
    data['modified_at'] = modifiedAt;
    return data;
  }

  static List<Peer> fromList(List<dynamic> list) {
    List<Peer> peers = [];
    for (var data in list) {
      Peer peer = Peer.fromJson(data.data());
      peer.uid = data.id;
      peers.add(peer);
    }
    return peers;
  }
}
