// Bu dosya artık kullanılmıyor
// HospitalService.addSampleHospitals() metodu kaldırıldığı için
// Bu dosya güvenle silinebilir

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  debugPrint('🔥 Firebase başlatıldı');
  debugPrint('⚠️ Bu dosya artık kullanılmıyor - silinebilir');
  
  try {
    // Bu metod artık HospitalService'de yok
    debugPrint('❌ addSampleHospitals metodu kaldırıldı');
    debugPrint('✅ Bu dosya artık kullanılmıyor - silinebilir');
  } catch (e) {
    debugPrint('❌ Hata: $e');
  }
}