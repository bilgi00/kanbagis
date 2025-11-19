import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BloodGroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Kan grupları koleksiyonunu oluştur ve verileri ekle
  static Future<void> createBloodGroupsCollection() async {
    try {
      debugPrint('🩸 Kan grupları koleksiyonu oluşturuluyor...');
      
      // Kan grupları verilerini tanımla
      List<Map<String, dynamic>> bloodGroups = [
        {
          'id': 1,
          'kan_grubu': 'A+',
          'kime_verebilir': 'A+, AB+',
          'kimden_alabilir': 'A+, A-, O+, O-',
          'verebilir_listesi': ['A+', 'AB+'],
          'alabilir_listesi': ['A+', 'A-', 'O+', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 2,
          'kan_grubu': 'O+',
          'kime_verebilir': 'O+, A+, B+, AB+',
          'kimden_alabilir': 'O+, O-',
          'verebilir_listesi': ['O+', 'A+', 'B+', 'AB+'],
          'alabilir_listesi': ['O+', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 3,
          'kan_grubu': 'B+',
          'kime_verebilir': 'B+, AB+',
          'kimden_alabilir': 'B+, B-, O+, O-',
          'verebilir_listesi': ['B+', 'AB+'],
          'alabilir_listesi': ['B+', 'B-', 'O+', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 4,
          'kan_grubu': 'AB+',
          'kime_verebilir': 'AB+',
          'kimden_alabilir': 'Herkesten',
          'verebilir_listesi': ['AB+'],
          'alabilir_listesi': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 5,
          'kan_grubu': 'A-',
          'kime_verebilir': 'A+, A-, AB+, AB-',
          'kimden_alabilir': 'A-, O-',
          'verebilir_listesi': ['A+', 'A-', 'AB+', 'AB-'],
          'alabilir_listesi': ['A-', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 6,
          'kan_grubu': 'O-',
          'kime_verebilir': 'Herkese',
          'kimden_alabilir': 'O-',
          'verebilir_listesi': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
          'alabilir_listesi': ['O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 7,
          'kan_grubu': 'B-',
          'kime_verebilir': 'B+, B-, AB+, AB-',
          'kimden_alabilir': 'B-, O-',
          'verebilir_listesi': ['B+', 'B-', 'AB+', 'AB-'],
          'alabilir_listesi': ['B-', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
        {
          'id': 8,
          'kan_grubu': 'AB-',
          'kime_verebilir': 'AB+, AB-',
          'kimden_alabilir': 'A-, B-, AB-, O-',
          'verebilir_listesi': ['AB+', 'AB-'],
          'alabilir_listesi': ['A-', 'B-', 'AB-', 'O-'],
          'created_at': FieldValue.serverTimestamp(),
        },
      ];

      // Her kan grubunu Firestore'a ekle
      for (var bloodGroup in bloodGroups) {
        await _firestore
            .collection('kan_gruplari')
            .doc(bloodGroup['kan_grubu'])
            .set(bloodGroup);
        
        debugPrint('✅ ${bloodGroup['kan_grubu']} kan grubu eklendi');
      }

      debugPrint('🎉 Kan grupları koleksiyonu başarıyla oluşturuldu!');
      debugPrint('📊 Toplam ${bloodGroups.length} kan grubu kaydı eklendi');
      
    } catch (e) {
      debugPrint('❌ Kan grupları koleksiyonu oluşturma hatası: $e');
      rethrow;
    }
  }

  // Tüm kan gruplarını listele (SQL SELECT * FROM kan_gruplari benzeri)
  static Future<List<Map<String, dynamic>>> getAllBloodGroups() async {
    try {
      debugPrint('📋 Kan grupları verisi getiriliyor...');
      
      QuerySnapshot snapshot = await _firestore
          .collection('kan_gruplari')
          .orderBy('id')
          .get();
      
      List<Map<String, dynamic>> bloodGroups = [];
      
      debugPrint('┌─────────────────────────────────────────────────────────────────────────────────┐');
      debugPrint('│                               KAN GRUPLARI TABLOSU                              │');
      debugPrint('├─────┬──────────┬─────────────────────────┬───────────────────────────────────────┤');
      debugPrint('│ ID  │ KAN GRUBU│ KİME VEREBİLİR         │ KİMDEN ALABİLİR                      │');
      debugPrint('├─────┼──────────┼─────────────────────────┼───────────────────────────────────────┤');
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bloodGroups.add(data);
        
        // Konsol tablosu formatında yazdır
        String id = data['id'].toString().padRight(3);
        String kanGrubu = data['kan_grubu'].toString().padRight(8);
        String kimeVerebilir = data['kime_verebilir'].toString().padRight(23);
        String kimdenAlabilir = data['kimden_alabilir'].toString().padRight(37);
        
        debugPrint('│ $id │ $kanGrubu │ $kimeVerebilir │ $kimdenAlabilir │');
      }
      
      debugPrint('└─────┴──────────┴─────────────────────────┴───────────────────────────────────────┘');
      debugPrint('✅ Toplam ${bloodGroups.length} kan grubu kaydı listelendi');
      
      return bloodGroups;
    } catch (e) {
      debugPrint('❌ Kan grupları listesi getirme hatası: $e');
      return [];
    }
  }

  // Belirli bir kan grubunun bilgilerini getir
  static Future<Map<String, dynamic>?> getBloodGroupInfo(String bloodType) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('kan_gruplari')
          .doc(bloodType)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Kan grubu bilgisi getirme hatası: $e');
      return null;
    }
  }

  // Kan grubuna göre uyumlu vericileri bul
  static Future<List<String>> getCompatibleDonors(String bloodType) async {
    try {
      Map<String, dynamic>? bloodGroupInfo = await getBloodGroupInfo(bloodType);
      
      if (bloodGroupInfo != null) {
        List<dynamic> donors = bloodGroupInfo['alabilir_listesi'] ?? [];
        return donors.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Uyumlu vericiler getirme hatası: $e');
      return [];
    }
  }

  // Kan grubuna göre uyumlu alıcıları bul
  static Future<List<String>> getCompatibleRecipients(String bloodType) async {
    try {
      Map<String, dynamic>? bloodGroupInfo = await getBloodGroupInfo(bloodType);
      
      if (bloodGroupInfo != null) {
        List<dynamic> recipients = bloodGroupInfo['verebilir_listesi'] ?? [];
        return recipients.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Uyumlu alıcılar getirme hatası: $e');
      return [];
    }
  }

  // Evrensel verici ve alıcı bilgilerini getir
  static Future<Map<String, String>> getUniversalTypes() async {
    try {
      return {
        'universal_donor': 'O-',
        'universal_recipient': 'AB+',
      };
    } catch (e) {
      debugPrint('❌ Evrensel tip bilgileri getirme hatası: $e');
      return {};
    }
  }

  // Koleksiyonun var olup olmadığını kontrol et
  static Future<bool> checkIfCollectionExists() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('kan_gruplari')
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Kan grupları istatistiklerini getir
  static Future<Map<String, dynamic>> getBloodGroupStatistics() async {
    try {
      // Firebase'den gerçek kan grubu verilerini çek
      List<Map<String, dynamic>> allGroups = await getAllBloodGroups();
      
      // Kullanıcılardan kan grubu dağılımını çek
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      Map<String, int> bloodTypeDistribution = {};
      int totalUsers = 0;
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          final bloodType = data['bloodType'] as String?;
          if (bloodType != null && bloodType.isNotEmpty) {
            bloodTypeDistribution[bloodType] = (bloodTypeDistribution[bloodType] ?? 0) + 1;
            totalUsers++;
          }
        }
      }
      
      // Negatif ve pozitif kan gruplarını say
      int negativeTypes = 0;
      int positiveTypes = 0;
      
      for (var entry in bloodTypeDistribution.entries) {
        if (entry.key.contains('-')) {
          negativeTypes += entry.value;
        } else if (entry.key.contains('+')) {
          positiveTypes += entry.value;
        }
      }
      
      // En yaygın ve en nadir kan gruplarını bul
      var sortedTypes = bloodTypeDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      List<String> mostCommonTypes = sortedTypes.take(2).map((e) => e.key).toList();
      List<String> rarestTypes = sortedTypes.reversed.take(2).map((e) => e.key).toList();
      
      Map<String, dynamic> stats = {
        'total_blood_groups': allGroups.length,
        'universal_donor': 'O-',
        'universal_recipient': 'AB+',
        'rarest_types': rarestTypes.isNotEmpty ? rarestTypes : ['AB-', 'AB+'],
        'most_common_types': mostCommonTypes.isNotEmpty ? mostCommonTypes : ['O+', 'A+'],
        'negative_types': negativeTypes,
        'positive_types': positiveTypes,
        'total_users_with_blood_type': totalUsers,
        'blood_type_distribution': bloodTypeDistribution,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ Kan grubu istatistikleri hesaplandı: ${stats['total_users_with_blood_type']} kullanıcı');
      return stats;
    } catch (e) {
      debugPrint('❌ İstatistik getirme hatası: $e');
      return {
        'total_blood_groups': 8, // Varsayılan
        'universal_donor': 'O-',
        'universal_recipient': 'AB+',
        'rarest_types': ['AB-', 'AB+'],
        'most_common_types': ['O+', 'A+'],
        'negative_types': 0,
        'positive_types': 0,
        'total_users_with_blood_type': 0,
        'error': e.toString(),
      };
    }
  }
}