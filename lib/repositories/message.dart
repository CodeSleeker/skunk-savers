import 'package:skunk_savers/controllers/interfaces/message.dart';
import 'package:skunk_savers/controllers/message.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/repositories/interfaces/message.dart';

class MessageRepository implements IMessageRepository {
  IMessageController messageController = MessageController();
  @override
  Future<SSCResponse> addNotification(
      String uid, SSCNotification notification) async {
    return await messageController.addNotification(uid, notification);
  }

  @override
  Future<SSCResponse> removeNotification(String uid, String id) async {
    return await messageController.removeNotification(uid, id);
  }

  @override
  Future<SSCResponse> updateNotification(
      String uid, String id, Map<String, dynamic> data) async {
    return await messageController.updateNotification(uid, id, data);
  }

  @override
  Future<SSCResponse> sendMessage(chat) async {
    return await messageController.sendMessage(chat);
  }

  @override
  Future<SSCResponse> seenMessage(String uid, String peerId) async {
    return await messageController.seenMessage(uid, peerId);
  }

  @override
  Future<SSCResponse> removeChats(String uid, String peerId) async {
    return await messageController.removeChats(uid, peerId);
  }

  @override
  Future<SSCResponse> removeChat(
      String uid, String peerId, String docId) async {
    return await messageController.removeChat(uid, peerId, docId);
  }

  @override
  Future<SSCResponse> batchRemoveChat(
      String uid, String peerId, List<String> docIds) async {
    return await messageController.batchRemoveChat(uid, peerId, docIds);
  }

  @override
  Future<SSCResponse> sendNotification(PushNotification notification) async {
    return await messageController.sendNotification(notification);
  }
}
