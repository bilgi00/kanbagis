import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Çoklu dil desteği için localization servisi
class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'tr';
  
  static String _currentLanguage = _defaultLanguage;
  static bool _isInitialized = false;

  /// Desteklenen diller
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
  };

  /// Lokalizasyon servisini başlat
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      _isInitialized = true;
      
      debugPrint('🌍 LocalizationService initialized: $_currentLanguage');
    } catch (e) {
      debugPrint('❌ LocalizationService initialization error: $e');
      _currentLanguage = _defaultLanguage;
      _isInitialized = true;
    }
  }

  /// Mevcut dil kodunu al
  static String get currentLanguage => _currentLanguage;

  /// Mevcut dilin ismini al
  static String get currentLanguageName => supportedLanguages[_currentLanguage] ?? 'Türkçe';

  /// Dil değiştir
  static Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      debugPrint('❌ Desteklenmeyen dil kodu: $languageCode');
      return;
    }

    _currentLanguage = languageCode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      debugPrint('🌍 Dil değiştirildi: $languageCode');
    } catch (e) {
      debugPrint('❌ Dil kaydetme hatası: $e');
    }
  }

  /// Türkçe mi kontrol et
  static bool get isTurkish => _currentLanguage == 'tr';

  /// İngilizce mi kontrol et
  static bool get isEnglish => _currentLanguage == 'en';

  /// Dil kodundan Locale oluştur
  static Locale get locale => Locale(_currentLanguage);
}

/// Çeviriler için extension
extension StringLocalization on String {
  /// String'i mevcut dile göre çevir
  String get tr {
    return _translations[this]?[LocalizationService.currentLanguage] ?? this;
  }
}

/// Çeviri veritabanı
const Map<String, Map<String, String>> _translations = {
  // Ana Sayfa
  'Bir Damla Kan': {
    'tr': 'Bir Damla Kan',
    'en': 'A Drop of Blood',
  },
  'Kan Talepleri': {
    'tr': 'Kan Talepleri',
    'en': 'Blood Requests',
  },
  'Ana Sayfa': {
    'tr': 'Ana Sayfa',
    'en': 'Home',
  },
  'Profil': {
    'tr': 'Profil',
    'en': 'Profile',
  },
  'Ayarlar': {
    'tr': 'Ayarlar',
    'en': 'Settings',
  },
  'Hakkında': {
    'tr': 'Hakkında',
    'en': 'About',
  },

  // Kan Grupları
  'Kan Grubu': {
    'tr': 'Kan Grubu',
    'en': 'Blood Type',
  },
  'Belirtmek istemiyorum': {
    'tr': 'Belirtmek istemiyorum',
    'en': 'Prefer not to say',
  },

  // Butonlar
  'Kaydet': {
    'tr': 'Kaydet',
    'en': 'Save',
  },
  'İptal': {
    'tr': 'İptal',
    'en': 'Cancel',
  },
  'Tamam': {
    'tr': 'Tamam',
    'en': 'OK',
  },
  'Kapat': {
    'tr': 'Kapat',
    'en': 'Close',
  },
  'Geri': {
    'tr': 'Geri',
    'en': 'Back',
  },

  // Bildirimler
  'Başarılı': {
    'tr': 'Başarılı',
    'en': 'Success',
  },
  'Hata': {
    'tr': 'Hata',
    'en': 'Error',
  },
  'Uyarı': {
    'tr': 'Uyarı',
    'en': 'Warning',
  },
  'Bilgi': {
    'tr': 'Bilgi',
    'en': 'Info',
  },

  // Hastaneler
  'Hastaneler': {
    'tr': 'Hastaneler',
    'en': 'Hospitals',
  },
  'Hastane Listesi': {
    'tr': 'Hastane Listesi',
    'en': 'Hospital List',
  },
  'Hastane Rehberi': {
    'tr': 'Hastane Rehberi',
    'en': 'Hospital Directory',
  },

  // QR Kod
  'QR Kod': {
    'tr': 'QR Kod',
    'en': 'QR Code',
  },
  'QR Kod Tarama': {
    'tr': 'QR Kod Tarama',
    'en': 'QR Code Scan',
  },

  // Kan Uyumluluğu
  'Kan Uyumluluk Tablosu': {
    'tr': 'Kan Uyumluluk Tablosu',
    'en': 'Blood Compatibility Chart',
  },

  // Ayarlar
  'Bildirimler': {
    'tr': 'Bildirimler',
    'en': 'Notifications',
  },
  'Ses': {
    'tr': 'Ses',
    'en': 'Sound',
  },
  'Titreşim': {
    'tr': 'Titreşim',
    'en': 'Vibration',
  },
  'Dil': {
    'tr': 'Dil',
    'en': 'Language',
  },
  'Tema': {
    'tr': 'Tema',
    'en': 'Theme',
  },
  'Dil Seçin': {
    'tr': 'Dil Seçin',
    'en': 'Select Language',
  },
  'Türkçe': {
    'tr': 'Türkçe',
    'en': 'Turkish',
  },
  'English': {
    'tr': 'İngilizce',
    'en': 'English',
  },

  // Debug
  'Debug Bilgileri': {
    'tr': 'Debug Bilgileri',
    'en': 'Debug Information',
  },
  'Uygulama Sürümü': {
    'tr': 'Uygulama Sürümü',
    'en': 'App Version',
  },
  'Platform': {
    'tr': 'Platform',
    'en': 'Platform',
  },

  // Versiyon Bilgileri
  'Versiyon': {
    'tr': 'Versiyon',
    'en': 'Version',
  },
  'Build': {
    'tr': 'Build',
    'en': 'Build',
  },
  'Uygulama Bilgileri': {
    'tr': 'Uygulama Bilgileri',
    'en': 'App Information',
  },

  // Güncelleme
  'Güncelleme Geçmişi': {
    'tr': 'Güncelleme Geçmişi',
    'en': 'Update History',
  },
  'Son Güncelleme': {
    'tr': 'Son Güncelleme',
    'en': 'Last Update',
  },

  // Genel
  'Yükleniyor...': {
    'tr': 'Yükleniyor...',
    'en': 'Loading...',
  },
  'Başlıyor...': {
    'tr': 'Başlıyor...',
    'en': 'Starting...',
  },
  'Bağlanıyor...': {
    'tr': 'Bağlanıyor...',
    'en': 'Connecting...',
  },

  // Hakkında
  'Kan Bağışı Platformu': {
    'tr': 'Kan Bağışı Platformu',
    'en': 'Blood Donation Platform',
  },
  'Bir damla kan, bir hayat...': {
    'tr': 'Bir damla kan, bir hayat...',
    'en': 'A drop of blood, a life...',
  },

  // Profil
  'Kullanıcı Profili': {
    'tr': 'Kullanıcı Profili',
    'en': 'User Profile',
  },
  'Ad Soyad': {
    'tr': 'Ad Soyad',
    'en': 'Full Name',
  },
  'Telefon': {
    'tr': 'Telefon',
    'en': 'Phone',
  },
  'E-posta': {
    'tr': 'E-posta',
    'en': 'Email',
  },

  // Giriş/Çıkış
  'Giriş Yap': {
    'tr': 'Giriş Yap',
    'en': 'Sign In',
  },
  'Kayıt Ol': {
    'tr': 'Kayıt Ol',
    'en': 'Sign Up',
  },
  'Çıkış Yap': {
    'tr': 'Çıkış Yap',
    'en': 'Sign Out',
  },
  'Misafir': {
    'tr': 'Misafir',
    'en': 'Guest',
  },
};