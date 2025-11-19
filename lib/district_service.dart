import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DistrictService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'ilceler';

  // Tüm ilçeleri getir
  static Future<List<Map<String, dynamic>>> getAllDistricts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('ilce')
          .get();

      List<Map<String, dynamic>> districts = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        districts.add(data);
      }

      debugPrint('✅ ${districts.length} ilçe verisi getirildi');
      return districts;
      
    } catch (e) {
      debugPrint('❌ İlçeler listesi getirme hatası: $e');
      throw Exception('İlçeler listesi getirilemedi: $e');
    }
  }

  // Belirli bir ilçenin bölgelerini getir
  static Future<List<String>> getDistrictRegions(String districtName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('ilce', isEqualTo: districtName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        List<dynamic> regions = data['bolgeler'] ?? [];
        return regions.cast<String>();
      }

      return [];
      
    } catch (e) {
      debugPrint('❌ İlçe bölgeleri getirme hatası: $e');
      throw Exception('İlçe bölgeleri getirilemedi: $e');
    }
  }

  // İlçe adlarını getir (dropdown için)
  static Future<List<String>> getDistrictNames() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('ilce')
          .get();

      List<String> districtNames = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        districtNames.add(data['ilce'] ?? '');
      }

      return districtNames;
      
    } catch (e) {
      debugPrint('❌ İlçe adları getirme hatası: $e');
      throw Exception('İlçe adları getirilemedi: $e');
    }
  }

  // Collection'ın var olup olmadığını kontrol et
  static Future<bool> checkIfCollectionExists() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
      
    } catch (e) {
      debugPrint('❌ Collection kontrol hatası: $e');
      return false;
    }
  }

  // Collection'ı sil (test amaçlı)
  static Future<void> deleteCollection() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      
      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('✅ İlçeler collection silindi');
      
    } catch (e) {
      debugPrint('❌ Collection silme hatası: $e');
      throw Exception('Collection silinemedi: $e');
    }
  }
}