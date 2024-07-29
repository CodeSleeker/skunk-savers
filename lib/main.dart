import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/view_models/members_vm.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/auth/login.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  registerNotification();
  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Basic Notifications',
        importance: NotificationImportance.High,
        channelShowBadge: true,
        soundSource: 'resource://raw/res_notification',
      )
    ],
  );
  runApp(const MyApp());
}

registerNotification() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(handleMessage);
  RemoteMessage? message = await messaging.getInitialMessage();
  if (message != null) {
    handleMessage(message);
  }
  // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

@pragma("vm:entry-point")
Future handleMessage(RemoteMessage message) async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'basic_channel',
      title: message.data['title'],
      body: message.data['body'],
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVM>(create: (_) => UserVM()),
        ChangeNotifierProvider<MembersVM>(create: (_) => MembersVM()),
        ChangeNotifierProvider<AccountVM>(create: (_) => AccountVM()),
        ChangeNotifierProvider<HomeVM>(create: (_) => HomeVM()),
        ChangeNotifierProvider<MessageVM>(create: (_) => MessageVM()),
      ],
      builder: (_, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Login(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
