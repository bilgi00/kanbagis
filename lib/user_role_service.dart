import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum UserRole {
  guest,    // Misafir - Sadece görüntüleme
  user,     // Kullanıcı - Talep oluşturma, profil yönetimi
  admin,    // Admin - Tüm işlemler
}

class UserRoleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının mevcut rolünü getir
  static Future<UserRole> getCurrentUserRole() async {
    try {
      User? user = _auth.currentUser;
      
      // Kullanıcı giriş yapmamışsa misafir
      if (user == null) {
        return UserRole.guest;
      }

      // Firestore'dan kullanıcı bilgilerini çek
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Kullanıcı belgesi yoksa varsayılan olarak user rolü ver
        await _setUserRole(user.uid, UserRole.user);
        return UserRole.user;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String roleString = userData['role'] ?? 'user';
      
      switch (roleString.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'user':
          return UserRole.user;
        case 'guest':
          return UserRole.guest;
        default:
          return UserRole.user;
      }
    } catch (e) {
      debugPrint('❌ Kullanıcı rolü alınırken hata: $e');
      return UserRole.guest; // Hata durumunda misafir rolü döndür
    }
  }

  // Kullanıcının rolünü ayarla
  static Future<void> _setUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Kullanıcı rolü ayarlanırken hata: $e');
    }
  }

  // Admin tarafından kullanıcı rolü güncelleme
  static Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      // Sadece admin bu işlemi yapabilir
      UserRole currentUserRole = await getCurrentUserRole();
      if (currentUserRole != UserRole.admin) {
        throw Exception('Bu işlemi sadece admin kullanıcılar yapabilir');
      }

      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Kullanıcı rolü güncellendi: $userId -> ${newRole.toString().split('.').last}');
    } catch (e) {
      debugPrint('❌ Kullanıcı rolü güncellenirken hata: $e');
      rethrow;
    }
  }

  // Yeni kullanıcı kaydında varsayılan rol atama
  static Future<void> setDefaultRoleForNewUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'user', // Yeni kullanıcılar varsayılan olarak 'user' rolüne sahip
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Yeni kullanıcıya varsayılan rol atandı: $userId -> user');
    } catch (e) {
      debugPrint('❌ Varsayılan rol atanırken hata: $e');
    }
  }

  // İlk admin kullanıcısı oluşturma (sadece development için)
  static Future<void> createFirstAdmin(String email) async {
    try {
      QuerySnapshot adminCheck = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      // Eğer hiç admin yoksa
      if (adminCheck.docs.isEmpty) {
        QuerySnapshot userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          String userId = userQuery.docs.first.id;
          await _firestore.collection('users').doc(userId).update({
            'role': 'admin',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ İlk admin kullanıcısı oluşturuldu: $email');
        }
      }
    } catch (e) {
      debugPrint('❌ İlk admin oluşturulurken hata: $e');
    }
  }

  // Acil durum admin oluşturma (development only)
  static Future<void> emergencyCreateAdmin(String email) async {
    try {
      // E-posta formatını kontrol et
      if (!email.contains('@')) {
        email = '$email@kanbagisc.com';
      }

      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String userId = userQuery.docs.first.id;
        await _firestore.collection('users').doc(userId).update({
          'role': 'admin',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('🚨 Acil admin yetkisi verildi: $email');
      } else {
        debugPrint('❌ Kullanıcı bulunamadı: $email');
      }
    } catch (e) {
      debugPrint('❌ Acil admin oluşturulurken hata: $e');
    }
  }

  // Rol kontrolü fonksiyonları
  static Future<bool> isAdmin() async {
    UserRole role = await getCurrentUserRole();
    return role == UserRole.admin;
  }

  static Future<bool> isUser() async {
    UserRole role = await getCurrentUserRole();
    return role == UserRole.user || role == UserRole.admin;
  }

  static Future<bool> isGuest() async {
    UserRole role = await getCurrentUserRole();
    return role == UserRole.guest;
  }

  // String olarak rol getir (QR kod ekranı için)
  Future<String> getUserRole() async {
    UserRole role = await getCurrentUserRole();
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
      case UserRole.guest:
        return 'guest';
    }
  }

  // Rol açıklamaları
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return 'Misafir - Sadece görüntüleme';
      case UserRole.user:
        return 'Kullanıcı - Talep oluşturma ve profil yönetimi';
      case UserRole.admin:
        return 'Admin - Tüm sistem yönetimi';
    }
  }

  // Rol renkleri
  static String getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return '#9E9E9E'; // Gri
      case UserRole.user:
        return '#2196F3'; // Mavi
      case UserRole.admin:
        return '#FF5722'; // Turuncu-Kırmızı
    }
  }

  // Tüm kullanıcıları listele (sadece admin)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      UserRole currentUserRole = await getCurrentUserRole();
      if (currentUserRole != UserRole.admin) {
        throw Exception('Bu işlemi sadece admin kullanıcılar yapabilir');
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Kullanıcılar listelenirken hata: $e');
      rethrow;
    }
  }
}