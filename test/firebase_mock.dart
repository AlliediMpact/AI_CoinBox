import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/foundation.dart'; // Import FlutterError

class MockFirebaseCore extends FirebasePlatform {
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseApp();
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) { // Make 'name' optional
    return MockFirebaseApp();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp() : super(name: 'MockApp', options: const FirebaseOptions( // Correct super constructor
        apiKey: 'fakeApiKey',
        appId: 'fakeAppId',
        messagingSenderId: 'fakeSenderId',
        projectId: 'fakeProjectId',
      ));

  @override
  String get name => 'MockApp';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'mockApiKey',
        appId: 'mockAppId',
        messagingSenderId: 'mockSenderId',
        projectId: 'mockProjectId',
      );
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Set up mock Firebase Core
  FirebasePlatform.instance = MockFirebaseCore();
}
