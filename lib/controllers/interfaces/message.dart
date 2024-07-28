import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/chat.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/response.dart';

abstract class IMessageController {
  late CollectionReference messages;
  Future<SSCResponse> addNotification(String uid, SSCNotification notification);
  Future<SSCResponse> removeNotification(String uid, String id);
  Future<SSCResponse> updateNotification(
      String uid, String id, Map<String, dynamic> data);
  Future<SSCResponse> sendMessage(ChatData chat);
  Future<SSCResponse> seenMessage(String uid, String peerId);
  Future<SSCResponse> removeChats(String uid, String peerId);
  Future<SSCResponse> removeChat(String uid, String peerId, String docId);
  Future<SSCResponse> batchRemoveChat(
      String uid, String peerId, List<String> docIds);
  Future<SSCResponse> sendNotification(PushNotification notification);
}
