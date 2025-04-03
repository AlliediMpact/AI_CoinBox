import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_coinbox/services/auth_service.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    authService = AuthService();
  });

  group('AuthService', () {
    test('signOut should call FirebaseAuth.signOut', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});
      await authService.signOut();
      verify(mockAuth.signOut()).called(1);
    });

    test('deleteAccount should delete the current user', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.delete()).thenAnswer((_) async {});

      await authService.deleteAccount();
      verify(mockUser.delete()).called(1);
    });

    test('resetPassword should send a password reset email', () async {
      const email = 'test@example.com';
      when(mockAuth.sendPasswordResetEmail(email: email)).thenAnswer((_) async {});

      await authService.resetPassword(email);
      verify(mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });

    test('sendOTP should generate and store an OTP', () async {
      const email = 'test@example.com';
      await AuthService.sendOTP(email);
      expect(AuthService._otpStorage[email], isNotNull);
    });

    test('verifyOTP should return true for correct OTP', () async {
      const email = 'test@example.com';
      const otp = '123456';
      AuthService._otpStorage[email] = otp;

      final result = await AuthService.verifyOTP(email, otp);
      expect(result, isTrue);
    });

    test('verifyOTP should return false for incorrect OTP', () async {
      const email = 'test@example.com';
      const otp = '123456';
      AuthService._otpStorage[email] = otp;

      final result = await AuthService.verifyOTP(email, '654321');
      expect(result, isFalse);
    });
  });
}
