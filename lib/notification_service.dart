import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blood_group_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Notification service'i başlat
  static Future<void> initialize() async {
    debugPrint('🔔 Notification Service başlatılıyor...');

    // Notification izinlerini iste
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📱 Notification izin durumu: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Kullanıcı notification izni verdi');
      await _initializeLocalNotifications();
      await _setupFCMListeners();
      await _saveUserToken();
    } else {
      debugPrint('❌ Kullanıcı notification izni vermedi');
    }
  }

  // Local notifications'ı başlat
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Local notification tıklandı: ${response.payload}');
      },
    );
  }

  // FCM listener'ları ayarla
  static Future<void> _setupFCMListeners() async {
    // Foreground mesajları
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground mesaj alındı: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background mesajları
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Background mesaj açıldı: ${message.notification?.title}');
    });

    // App terminate state'den açılan mesajlar
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔔 App kapalıyken mesaj alındı: ${initialMessage.notification?.title}');
    }
  }

  // Local notification göster
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blood_request_channel',
      'Kan Talepleri',
      channelDescription: 'Acil kan talebi bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE53935),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Kan Talebi',
      message.notification?.body ?? 'Yeni kan talebi var',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Kullanıcının FCM token'ını kaydet
  static Future<void> _saveUserToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _firestore.collection('user_tokens').doc(user.uid).set({
            'token': token,
            'userId': user.uid,
            'email': user.email,
            'lastUpdated': FieldValue.serverTimestamp(),
            'platform': 'web', // Web için
          }, SetOptions(merge: true));

          debugPrint('✅ FCM Token kaydedildi: ${token.substring(0, 20)}...');
        }
      }
    } catch (e) {
      debugPrint('❌ Token kaydetme hatası: $e');
    }
  }

  // Kullanıcının kan grubunu kaydet/güncelle
  static Future<void> updateUserBloodType(String bloodType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        await _firestore.collection('users').doc(user.uid).update({
          'bloodType': bloodType,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Kullanıcı kan grubu güncellendi: $bloodType');
      }
    } catch (e) {
      debugPrint('❌ Kan grubu güncelleme hatası: $e');
    }
  }

  // Kan talebi oluşturulduğunda uyumlu kullanıcılara bildirim gönder
  static Future<void> sendBloodRequestNotification({
    required String requiredBloodType,
    required String patientName,
    required String hospitalName,
    required String location,
    required String urgency,
  }) async {
    try {
      debugPrint('🩸 Kan talebi bildirimi gönderiliyor...');
      debugPrint('   Aranan kan grubu: $requiredBloodType');

      // Uyumlu kan gruplarını bul
      List<String> compatibleBloodTypes = await BloodGroupService.getCompatibleDonors(requiredBloodType);
      debugPrint('   Uyumlu kan grupları: $compatibleBloodTypes');

      if (compatibleBloodTypes.isEmpty) {
        debugPrint('❌ Uyumlu kan grubu bulunamadı');
        return;
      }

      // Uyumlu kan grubundaki kullanıcıları bul
      QuerySnapshot userProfiles = await _firestore
          .collection('users')
          .where('bloodType', whereIn: compatibleBloodTypes)
          .where('notificationsEnabled', isEqualTo: true)
          .get();

      debugPrint('   Uyumlu ${userProfiles.docs.length} kullanıcı bulundu');

      // Her uyumlu kullanıcıya bildirim gönder
      for (var userProfile in userProfiles.docs) {
        String userId = userProfile.id;
        
        // Kullanıcının token'ını al
        DocumentSnapshot tokenDoc = await _firestore
            .collection('user_tokens')
            .doc(userId)
            .get();

        if (tokenDoc.exists) {
          Map<String, dynamic>? userData = userProfile.data() as Map<String, dynamic>?;
          String userBloodType = userData?['bloodType'] ?? '';

          // Notification mesajını oluştur
          await _createNotificationRequest(
            userId: userId,
            bloodType: userBloodType,
            requiredBloodType: requiredBloodType,
            patientName: patientName,
            hospitalName: hospitalName,
            location: location,
            urgency: urgency,
          );
        }
      }

      debugPrint('✅ Kan talebi bildirimleri gönderildi');

    } catch (e) {
      debugPrint('❌ Bildirim gönderme hatası: $e');
    }
  }

  // Notification request kaydı oluştur (Firebase Functions ile işlenecek)
  static Future<void> _createNotificationRequest({
    required String userId,
    required String bloodType,
    required String requiredBloodType,
    required String patientName,
    required String hospitalName,
    required String location,
    required String urgency,
  }) async {
    try {
      String urgencyEmoji = urgency == 'Acil' ? '🚨' : urgency == 'Orta' ? '⚠️' : '📋';
      
      await _firestore.collection('notification_requests').add({
        'userId': userId,
        'type': 'blood_request',
        'title': '$urgencyEmoji Acil Kan Talebi - $requiredBloodType',
        'body': '$patientName için $hospitalName\'de kan gerekli ($location)',
        'data': {
          'requiredBloodType': requiredBloodType,
          'userBloodType': bloodType,
          'patientName': patientName,
          'hospitalName': hospitalName,
          'location': location,
          'urgency': urgency,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Notification request oluşturuldu: $userId ($bloodType → $requiredBloodType)');
    } catch (e) {
      debugPrint('❌ Notification request oluşturma hatası: $e');
    }
  }

  // Test notification gönder
  static Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Bildirimleri',
      channelDescription: 'Test amaçlı bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE53935),
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      '🩸 Test Bildirimi',
      'Kan bağışı notification sistemi çalışıyor!',
      platformChannelSpecifics,
    );
  }

  // FCM token'ı al
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Token alma hatası: $e');
      return null;
    }
  }
}

// Background message handler (global fonksiyon olmalı)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background mesaj alındı: ${message.notification?.title}');
}