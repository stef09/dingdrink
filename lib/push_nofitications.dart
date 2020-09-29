import 'package:dingdrink/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dingdrink/global.dart';
class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      //tkn : token sixOne
      String tkn = 'cncFAIHbT2Scy3EcdxRri1:APA91bEbQ7kr5GMlEkQo_1K3679uY0OQVpXin-HrZ3reLhzOjH3KXsITSQipVwJiOHsyZcnQhVac7ZGwowbMsA36nonlWQyes1SoCK0_wwXy8t1CM7Md6IutJU3Tv-mRDD6LgNKTLFRS';
      globalDeviceId = token;
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }


}