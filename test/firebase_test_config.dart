import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

Future<void> setupFirebaseTestConfig() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}
