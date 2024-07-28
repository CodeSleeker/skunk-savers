import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:skunk_savers/controllers/interfaces/message.dart';
import 'package:skunk_savers/models/chat.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/res/constant.dart';

class MessageController implements IMessageController {
  Dio dio = Dio();
  @override
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  @override
  Future<SSCResponse> addNotification(
      String uid, SSCNotification notification) async {
    try {
      await messages
          .doc(uid)
          .collection('notifications')
          .add(notification.toJson());
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> removeNotification(String uid, String id) async {
    try {
      await messages.doc(uid).collection('notifications').doc(id).delete();
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> updateNotification(
      String uid, String id, Map<String, dynamic> data) async {
    try {
      await messages.doc(uid).collection('notifications').doc(id).update(data);
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> sendMessage(ChatData chat) async {
    try {
      await messages
          .doc(chat.from)
          .collection('chats')
          .doc(chat.to)
          .collection('messages')
          .add(chat.toJson());
      await messages
          .doc(chat.to)
          .collection('chats')
          .doc(chat.from)
          .collection('messages')
          .add(chat.toJson());
      await messages.doc(chat.to).collection('chats').doc(chat.from).set(
          {'has_new_message': true, 'modified_at': Timestamp.now()},
          SetOptions(merge: true));
      await messages.doc(chat.from).collection('chats').doc(chat.to).set({
        'modified_at': Timestamp.now(),
        'has_new_message': false,
      }, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> seenMessage(String uid, String peerId) async {
    try {
      await messages
          .doc(uid)
          .collection('chats')
          .doc(peerId)
          .set({'has_new_message': false}, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> removeChats(String uid, String peerId) async {
    try {
      await messages.doc(uid).collection('chats').doc(peerId).delete();
      var snapshots = await messages
          .doc(uid)
          .collection('chats')
          .doc(peerId)
          .collection('messages')
          .get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> removeChat(
      String uid, String peerId, String docId) async {
    try {
      await messages
          .doc(uid)
          .collection('chats')
          .doc(peerId)
          .collection('messages')
          .doc(docId)
          .delete();
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> batchRemoveChat(
      String uid, String peerId, List<String> docIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      var snapshots = await messages
          .doc(uid)
          .collection('chats')
          .doc(peerId)
          .collection('messages')
          .get();
      for (var doc in snapshots.docs) {
        if (docIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> sendNotification(PushNotification notification) async {
    try {
      Response response = await dio.post(Constant.fcmApi,
          options: Options(
            headers: Constant.fcmHeaders,
          ),
          data: notification.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        return SSCResponse(success: true);
      }
      return SSCResponse(
        success: false,
        errorMessage: 'Error sending notification',
      );
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }
}
