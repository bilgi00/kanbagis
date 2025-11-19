import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kapsamlı sistem istatistikleri
  static Future<Map<String, dynamic>> getCompleteSystemStatistics() async {
    try {
      debugPrint('📊 Kapsamlı sistem istatistikleri hesaplanıyor...');
      
      final Map<String, dynamic> stats = {};
      
      // Paralel veri çekimi için Future.wait kullan
      final results = await Future.wait([
        _getUserStatistics(),
        _getBloodRequestStatistics(),
        _getHospitalStatistics(),
        _getLocationStatistics(),
        _getBloodTypeStatistics(),
      ]);
      
      // Sonuçları birleştir
      for (var result in results) {
        stats.addAll(result);
      }
      
      // Hesaplanan değerler
      stats['completion_percentage'] = _calculateCompletionPercentage(stats);
      stats['last_updated'] = DateTime.now().toIso8601String();
      stats['update_time'] = DateTime.now().millisecondsSinceEpoch;
      
      debugPrint('✅ Sistem istatistikleri başarıyla hesaplandı');
      return stats;
      
    } catch (e) {
      debugPrint('❌ Sistem istatistikleri hatası: $e');
      return _getDefaultStatistics(e.toString());
    }
  }

  // Kullanıcı istatistikleri
  static Future<Map<String, dynamic>> _getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      final Map<String, int> bloodTypeDistribution = {};
      final Map<String, int> cityDistribution = {};
      final Map<String, int> roleDistribution = {};
      int canDonateCount = 0;
      int adminCount = 0;
      int userCount = 0;
      int guestCount = 0;
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        
        // Kan grubu dağılımı
        final bloodType = data['bloodType'] as String?;
        if (bloodType != null && bloodType.isNotEmpty) {
          bloodTypeDistribution[bloodType] = (bloodTypeDistribution[bloodType] ?? 0) + 1;
        }
        
        // Şehir dağılımı
        final region = data['region'] as String?;
        if (region != null && region.isNotEmpty) {
          cityDistribution[region] = (cityDistribution[region] ?? 0) + 1;
        }
        
        // Rol dağılımı
        final role = data['role'] as String?;
        if (role != null) {
          roleDistribution[role] = (roleDistribution[role] ?? 0) + 1;
          switch (role) {
            case 'admin':
              adminCount++;
              break;
            case 'user':
              userCount++;
              break;
            case 'guest':
              guestCount++;
              break;
          }
        }
        
        // Kan verebilir durumu
        final canDonate = data['canDonateBlood'] as bool?;
        if (canDonate == true) {
          canDonateCount++;
        }
      }
      
      return {
        'total_users': usersSnapshot.docs.length,
        'blood_type_distribution': bloodTypeDistribution,
        'city_distribution': cityDistribution,
        'role_distribution': roleDistribution,
        'can_donate_count': canDonateCount,
        'admin_count': adminCount,
        'user_count': userCount,
        'guest_count': guestCount,
        'users_with_blood_type': bloodTypeDistribution.values.fold(0, (a, b) => a + b),
      };
    } catch (e) {
      debugPrint('❌ Kullanıcı istatistikleri hatası: $e');
      return {
        'total_users': 0,
        'blood_type_distribution': <String, int>{},
        'city_distribution': <String, int>{},
        'role_distribution': <String, int>{},
        'can_donate_count': 0,
        'admin_count': 0,
        'user_count': 0,
        'guest_count': 0,
        'users_with_blood_type': 0,
      };
    }
  }

  // Kan talepleri istatistikleri
  static Future<Map<String, dynamic>> _getBloodRequestStatistics() async {
    try {
      final requestsSnapshot = await _firestore.collection('blood_requests').get();
      
      final Map<String, int> requestsByBloodType = {};
      final Map<String, int> requestsByCity = {};
      final Map<String, int> requestsByStatus = {};
      int urgentRequests = 0;
      int activeRequests = 0;
      int completedRequests = 0;
      
      for (var doc in requestsSnapshot.docs) {
        final data = doc.data();
        
        // Kan grubu bazında talepler
        final bloodType = data['blood_type'] as String?;
        if (bloodType != null) {
          requestsByBloodType[bloodType] = (requestsByBloodType[bloodType] ?? 0) + 1;
        }
        
        // Şehir bazında talepler
        final city = data['city'] as String?;
        if (city != null) {
          requestsByCity[city] = (requestsByCity[city] ?? 0) + 1;
        }
        
        // Durum bazında talepler
        final status = data['status'] as String?;
        if (status != null) {
          requestsByStatus[status] = (requestsByStatus[status] ?? 0) + 1;
          
          switch (status.toLowerCase()) {
            case 'urgent':
            case 'acil':
              urgentRequests++;
              break;
            case 'active':
            case 'aktif':
              activeRequests++;
              break;
            case 'completed':
            case 'tamamlandı':
              completedRequests++;
              break;
          }
        }
        
        // Acil durumlar
        final isUrgent = data['is_urgent'] as bool?;
        if (isUrgent == true) {
          urgentRequests++;
        }
      }
      
      return {
        'total_blood_requests': requestsSnapshot.docs.length,
        'requests_by_blood_type': requestsByBloodType,
        'requests_by_city': requestsByCity,
        'requests_by_status': requestsByStatus,
        'urgent_requests': urgentRequests,
        'active_requests': activeRequests,
        'completed_requests': completedRequests,
      };
    } catch (e) {
      debugPrint('❌ Kan talepleri istatistikleri hatası: $e');
      return {
        'total_blood_requests': 0,
        'requests_by_blood_type': <String, int>{},
        'requests_by_city': <String, int>{},
        'requests_by_status': <String, int>{},
        'urgent_requests': 0,
        'active_requests': 0,
        'completed_requests': 0,
      };
    }
  }

  // Hastane istatistikleri
  static Future<Map<String, dynamic>> _getHospitalStatistics() async {
    try {
      final hospitalsSnapshot = await _firestore.collection('hospitals').get();
      
      final Map<String, int> hospitalsByCity = {};
      final Map<String, int> hospitalsByType = {};
      
      for (var doc in hospitalsSnapshot.docs) {
        final data = doc.data();
        
        // Şehir bazında hastaneler
        final city = data['city'] as String?;
        if (city != null) {
          hospitalsByCity[city] = (hospitalsByCity[city] ?? 0) + 1;
        }
        
        // Tip bazında hastaneler
        final type = data['type'] as String?;
        if (type != null) {
          hospitalsByType[type] = (hospitalsByType[type] ?? 0) + 1;
        }
      }
      
      return {
        'total_hospitals': hospitalsSnapshot.docs.length,
        'hospitals_by_city': hospitalsByCity,
        'hospitals_by_type': hospitalsByType,
      };
    } catch (e) {
      debugPrint('❌ Hastane istatistikleri hatası: $e');
      return {
        'total_hospitals': 0,
        'hospitals_by_city': <String, int>{},
        'hospitals_by_type': <String, int>{},
      };
    }
  }

  // Lokasyon istatistikleri
  static Future<Map<String, dynamic>> _getLocationStatistics() async {
    try {
      final citiesSnapshot = await _firestore.collection('sehirler').get();
      final districtsSnapshot = await _firestore.collection('ilceler').get();
      
      return {
        'total_cities': citiesSnapshot.docs.length,
        'total_districts': districtsSnapshot.docs.length,
      };
    } catch (e) {
      debugPrint('❌ Lokasyon istatistikleri hatası: $e');
      return {
        'total_cities': 0,
        'total_districts': 0,
      };
    }
  }

  // Kan grubu istatistikleri
  static Future<Map<String, dynamic>> _getBloodTypeStatistics() async {
    try {
      final bloodGroupsSnapshot = await _firestore.collection('kan_gruplari').get();
      
      return {
        'total_blood_groups': bloodGroupsSnapshot.docs.length,
        'universal_donor': 'O-',
        'universal_recipient': 'AB+',
      };
    } catch (e) {
      debugPrint('❌ Kan grubu istatistikleri hatası: $e');
      return {
        'total_blood_groups': 8, // Varsayılan
        'universal_donor': 'O-',
        'universal_recipient': 'AB+',
      };
    }
  }

  // Tamamlanma yüzdesi hesapla
  static double _calculateCompletionPercentage(Map<String, dynamic> stats) {
    try {
      final totalUsers = stats['total_users'] as int? ?? 0;
      final usersWithBloodType = stats['users_with_blood_type'] as int? ?? 0;
      
      if (totalUsers == 0) return 0.0;
      return (usersWithBloodType / totalUsers) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  // Varsayılan istatistikler (hata durumunda)
  static Map<String, dynamic> _getDefaultStatistics(String error) {
    return {
      'error': error,
      'total_users': 0,
      'total_blood_requests': 0,
      'total_hospitals': 0,
      'total_cities': 0,
      'total_districts': 0,
      'total_blood_groups': 8,
      'blood_type_distribution': <String, int>{},
      'city_distribution': <String, int>{},
      'role_distribution': <String, int>{},
      'requests_by_blood_type': <String, int>{},
      'requests_by_city': <String, int>{},
      'hospitals_by_city': <String, int>{},
      'can_donate_count': 0,
      'urgent_requests': 0,
      'active_requests': 0,
      'completed_requests': 0,
      'admin_count': 0,
      'user_count': 0,
      'guest_count': 0,
      'users_with_blood_type': 0,
      'completion_percentage': 0.0,
      'universal_donor': 'O-',
      'universal_recipient': 'AB+',
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // Önemli metrikleri al (dashboard için)
  static Future<Map<String, dynamic>> getKeyMetrics() async {
    try {
      final stats = await getCompleteSystemStatistics();
      
      return {
        'total_users': stats['total_users'] ?? 0,
        'total_blood_requests': stats['total_blood_requests'] ?? 0,
        'urgent_requests': stats['urgent_requests'] ?? 0,
        'can_donate_count': stats['can_donate_count'] ?? 0,
        'completion_percentage': stats['completion_percentage'] ?? 0.0,
        'last_updated': stats['last_updated'],
      };
    } catch (e) {
      debugPrint('❌ Anahtar metrikler hatası: $e');
      return {
        'total_users': 0,
        'total_blood_requests': 0,
        'urgent_requests': 0,
        'can_donate_count': 0,
        'completion_percentage': 0.0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }
}