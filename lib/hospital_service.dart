import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HospitalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  


  // Firestore'dan şehirleri çekme fonksiyonu
  static Future<List<String>> getCitiesFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('ilceler').get();
      
      Set<String> regions = {};
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['region'] != null && data['region'].toString().isNotEmpty) {
          regions.add(data['region'].toString());
        }
      }
      
      List<String> regionList = regions.toList()..sort();
      if (kDebugMode) debugPrint('✅ Firestore\'dan ${regionList.length} şehir yüklendi');
      
      // Eğer Firestore'da veri yoksa, boş liste döndür
      if (regionList.isEmpty) {
        if (kDebugMode) debugPrint('⚠️ Firestore\'da şehir verisi bulunamadı');
        return [];
      }
      
      return regionList;
    } catch (e) {
      debugPrint('❌ Firestore\'dan şehirler yüklenirken hata: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Firestore'dan belirli bir şehirin ilçelerini çekme fonksiyonu
  static Future<List<String>> getDistrictsFromFirestore(String city) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('ilceler')
          .where('region', isEqualTo: city)
          .get();
      
      List<String> districts = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['district'] != null && data['district'].toString().isNotEmpty) {
          districts.add(data['district'].toString());
        }
      }
      
      districts.sort();
      if (kDebugMode) debugPrint('✅ $city için ${districts.length} ilçe yüklendi');
      
      // Eğer Firestore'da ilçe bulunamazsa veya ilçe listesi boşsa, boş liste döndür
      if (districts.isEmpty) {
        if (kDebugMode) debugPrint('⚠️ $city için Firestore\'da ilçe bulunamadı');
        return [];
      }
      
      return districts;
    } catch (e) {
      debugPrint('❌ $city ilçeleri yüklenirken hata: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }
  
  // Hastane ekleme fonksiyonu
  static Future<void> addHospital({
    required String hospitalName,
    required String region,
    required String phoneNumber,
    required String contactPerson,
    String? address,
    String? email,
    String? website,
  }) async {
    try {
      await _firestore.collection('hospitals').add({
        'hospitalName': hospitalName,
        'region': region,
        'phoneNumber': phoneNumber,
        'contactPerson': contactPerson,
        'address': address ?? '',
        'email': email ?? '',
        'website': website ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      debugPrint('✅ Hastane başarıyla eklendi: $hospitalName');
    } catch (e) {
      debugPrint('❌ Hastane ekleme hatası: $e');
      rethrow;
    }
  }





  // Hastaneleri getirme fonksiyonu
  static Future<List<Map<String, dynamic>>> getHospitals({String? region}) async {
    try {
      Query query = _firestore.collection('hospitals').where('isActive', isEqualTo: true);
      
      if (region != null && region.isNotEmpty) {
        query = query.where('region', isEqualTo: region);
        debugPrint('🔍 Bölge filtresi uygulanıyor: $region');
      } else {
        debugPrint('📋 Tüm hastaneler getiriliyor');
      }
      
      QuerySnapshot snapshot = await query.get();
      debugPrint('📊 Firestore\'dan ${snapshot.docs.length} hastane bulundu');
      
      List<Map<String, dynamic>> hospitals = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Manuel sıralama (Firestore index sorunu olmaması için)
      hospitals.sort((a, b) => (a['hospitalName'] ?? '').compareTo(b['hospitalName'] ?? ''));
      
      debugPrint('✅ ${hospitals.length} hastane listesi hazırlandı');
      for (var hospital in hospitals) {
        debugPrint('   - ${hospital['hospitalName']} (${hospital['region']})');
      }
      
      return hospitals;
    } catch (e) {
      debugPrint('❌ Hastane listesi getirme hatası: $e');
      return [];
    }
  }

  // Bölgeleri getirme fonksiyonu
  static Future<List<String>> getRegions() async {
    try {
      debugPrint('🗺️ Bölge listesi getiriliyor...');
      QuerySnapshot snapshot = await _firestore
          .collection('hospitals')
          .where('isActive', isEqualTo: true)
          .get();
      
      Set<String> regions = {};
      for (var doc in snapshot.docs) {
        String region = (doc.data() as Map<String, dynamic>)['region'] ?? '';
        if (region.isNotEmpty) {
          regions.add(region);
        }
      }
      
      List<String> regionList = regions.toList();
      regionList.sort();
      
      debugPrint('✅ ${regionList.length} bölge bulundu: ${regionList.join(', ')}');
      return regionList;
    } catch (e) {
      debugPrint('❌ Bölge listesi getirme hatası: $e');
      return [];
    }
  }

  // Bölgeye göre hastane isimlerini getirme fonksiyonu
  static Future<List<Map<String, String>>> getHospitalsByRegion(String region) async {
    try {
      debugPrint('🏥 $region bölgesindeki hastaneler getiriliyor...');
      
      QuerySnapshot snapshot = await _firestore
          .collection('hospitals')
          .where('isActive', isEqualTo: true)
          .where('region', isEqualTo: region)
          .get();
      
      List<Map<String, String>> hospitalList = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        hospitalList.add({
          'id': doc.id,
          'name': data['hospitalName']?.toString() ?? '',
          'region': data['region']?.toString() ?? '',
        });
      }
      
      // İsme göre sırala
      hospitalList.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      
      debugPrint('✅ ${hospitalList.length} hastane bulundu: ${hospitalList.map((h) => h['name']).join(', ')}');
      return hospitalList;
    } catch (e) {
      debugPrint('❌ Bölgeye göre hastane getirme hatası: $e');
      return [];
    }
  }

  // Hastane güncelleme fonksiyonu
  static Future<void> updateHospital(String hospitalId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('hospitals').doc(hospitalId).update(data);
      debugPrint('✅ Hastane başarıyla güncellendi');
    } catch (e) {
      debugPrint('❌ Hastane güncelleme hatası: $e');
      rethrow;
    }
  }

  // Hastane silme (pasif yapma) fonksiyonu
  static Future<void> deleteHospital(String hospitalId) async {
    try {
      await _firestore.collection('hospitals').doc(hospitalId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Hastane başarıyla pasif yapıldı');
    } catch (e) {
      debugPrint('❌ Hastane silme hatası: $e');
      rethrow;
    }
  }

}
