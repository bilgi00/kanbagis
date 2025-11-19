import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user_role_service.dart';
import '../services/update_service.dart';
import '../services/version_service.dart';
import '../services/localization_service.dart';

// ignore_for_file: deprecated_member_use

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'tr';
  String _selectedTheme = 'Sistem';
  
  UserRole _userRole = UserRole.guest;
  
  // Performance: SharedPreferences'ı cache'le
  SharedPreferences? _prefs;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserRole();
  }
  
  Future<void> _loadSettings() async {
    // Performance: SharedPreferences'ı sadece bir kez yükle
    _prefs ??= await SharedPreferences.getInstance();
    
    setState(() {
      _notificationsEnabled = _prefs!.getBool('notifications_enabled') ?? true;
      _soundEnabled = _prefs!.getBool('sound_enabled') ?? true;
      _vibrationEnabled = _prefs!.getBool('vibration_enabled') ?? true;
      _selectedLanguage = _prefs!.getString('selected_language') ?? 'tr';
      _selectedTheme = _prefs!.getString('theme') ?? 'Sistem';
    });
  }
  
  Future<void> _loadUserRole() async {
    final role = await UserRoleService.getCurrentUserRole();
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    // Performance: Cache'lenmiş prefs kullan
    _prefs ??= await SharedPreferences.getInstance();
    
    if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is String) {
      await _prefs!.setString(key, value);
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    await LocalizationService.setLanguage(languageCode);
    if (mounted) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      
      // Uygulama restart'ı için ScaffoldMessenger göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.isEnglish 
              ? 'Language changed to English. Please restart the app.'
              : 'Dil Türkçe\'ye değiştirildi. Uygulamayı yeniden başlatın.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showUpdateHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.update, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Güncelleme Geçmişi'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUpdateItem(
                  version: 'v1.0.3',
                  date: '6 Kasım 2025',
                  isLatest: true,
                  features: [
                    '🔧 Tek kaynak versiyon yönetimi sistemi',
                    '📱 VersionService ile otomatik versiyon senkronizasyonu',
                    '🎨 Versiyon widget\'ları eklendi',
                    '📋 Tüm ekranlarda tutarlı versiyon gösterimi',
                    '⚙️ pubspec.yaml\'dan otomatik versiyon okuma',
                    '🔄 Build numarası otomatik yönetimi',
                    '🗺️ Hastane harita entegrasyonu iyileştirildi',
                    '📍 Google Maps arama algoritması optimize edildi',
                    '🏥 Hastane adres sistemi standardize edildi',
                    '📝 Adres formatı doğrulaması eklendi',
                    '🎯 "Haritada Göster" butonları eklendi',
                    '🚫 Kullanıcı profili geri bildirim seçenekleri kaldırıldı',
                    '🌐 Çok dilli destek sistemi (Türkçe/İngilizce)',
                    '⚙️ LocalizationService eklendi',
                  ],
                  fixes: [
                    'Hakkında ekranında yanlış versiyon düzeltildi',
                    'Ayarlar debug kısmında versiyon tutarsızlığı giderildi',
                    'Ana ekran AppBar\'ında versiyon gösterimi eklendi',
                    'Profil sayfasında detaylı versiyon bilgisi eklendi',
                    'Versiyon bilgilerinin tek noktadan yönetimi sağlandı',
                    'Hastane adresi zorunlu alan haline getirildi',
                    'Google Maps sorguları hastane adı + adres birleştirilerek geliştirildi',
                    'Adres formatı "Sokak/Mahalle, İlçe, İl" standardına uygun hale getirildi',
                    'Harita açma fonksiyonları daha kapsamlı arama yapacak şekilde güncellendi',
                    'FeedbackScreen import\'u temizlendi (kullanılmayan import)',
                  ],
                ),
                const SizedBox(height: 16),
                _buildUpdateItem(
                  version: 'v1.0.1',
                  date: '23 Ekim 2025',
                  isLatest: false,
                  features: [
                    '🔧 Async context safety düzeltmeleri',
                    '📱 QR kod iletişim özelliği eklendi',
                    '🛡️ Güvenlik iyileştirmeleri',
                    '🏥 Hastane yönetimi optimize edildi',
                    '📋 Admin panel geliştirmeleri',
                  ],
                  fixes: [
                    'Firebase Auth güvenlik güncellemeleri',
                    'Context mounted kontrolleri eklendi',
                    'TODO yorumları temizlendi',
                    'Print statementları debugPrint olarak değiştirildi',
                  ],
                ),
                const SizedBox(height: 16),
                _buildUpdateItem(
                  version: 'v1.0.0',
                  date: '20 Ekim 2025',
                  features: [
                    '🎉 İlk sürüm yayınlandı',
                    '🩸 Kan bağışı talep sistemi',
                    '🏥 Hastane yönetimi',
                    '👥 Kullanıcı rol sistemi (Guest/User/Admin)',
                    '📱 QR kod entegrasyonu',
                    '🔔 Push notification sistemi',
                    '🗄️ Firebase Firestore veritabanı',
                    '🔐 Firebase Authentication',
                    '📍 Şehir/İlçe bazlı arama',
                    '🩸 Kan grubu uyumluluğu kontrolü',
                  ],
                  fixes: [],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem({
    required String version,
    required String date,
    required List<String> features,
    required List<String> fixes,
    bool isLatest = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLatest ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLatest ? Colors.green.shade700 : Colors.grey.shade700,
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'GÜNCEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '✨ Yeni Özellikler:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 4),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                feature,
                style: const TextStyle(fontSize: 13),
              ),
            )),
          ],
          if (fixes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              '🔧 Düzeltmeler:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            ...fixes.map((fix) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text(
                '• $fix',
                style: const TextStyle(fontSize: 13),
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _showAboutDeveloper() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Geliştirici Hakkında'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👨‍💻 Geliştirici: Flutter Developer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '🚀 Teknolojiler:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Flutter 3.35.6'),
            Text('• Dart 3.9.2'),
            Text('• Firebase Ecosystem'),
            Text('• Material Design 3'),
            SizedBox(height: 8),
            Text(
              '🎯 Proje Amacı:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kan bağışı ekosistemini dijitalleştirerek hayat kurtarmaya katkıda bulunmak.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '💡 Sosyal Etki:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Bu uygulama kar amacı gütmeden, toplum yararına geliştirilmiştir.',
              style: TextStyle(fontSize: 13, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    // Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
            ),
            SizedBox(height: 16),
            Text('Güncelleme kontrolü yapılıyor...'),
          ],
        ),
      ),
    );

    try {
      final updateInfo = await UpdateService.checkForUpdates();
      
      if (mounted) {
        Navigator.pop(context); // Loading dialog'unu kapat
        
        if (updateInfo != null && updateInfo['hasUpdate'] == true) {
          UpdateService.showUpdateDialog(context, updateInfo);
        } else {
          // Güncelleme yok
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('✅ Uygulamanız güncel!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Güncelleme kontrolü hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Ayarlar'.tr),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Kullanıcı Bilgisi
            if (user != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE53935),
                        child: Text(
                          (user.email?.isNotEmpty == true) 
                              ? user.email!.substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.email ?? 'Kullanıcı',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _userRole == UserRole.admin 
                                  ? 'Yönetici' 
                                  : _userRole == UserRole.user 
                                      ? 'Kullanıcı' 
                                      : 'Misafir',
                              style: TextStyle(
                                color: _userRole == UserRole.admin 
                                    ? Colors.orange 
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Bildirim Ayarları
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Color(0xFFE53935)),
                        SizedBox(width: 8),
                        Text(
                          'Bildirim Ayarları',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text('Bildirimler'.tr),
                    subtitle: Text(LocalizationService.isTurkish 
                        ? 'Kan talebi bildirimlerini al'
                        : 'Receive blood request notifications'),
                    value: _notificationsEnabled,
                    activeThumbColor: const Color(0xFFE53935),
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSetting('notifications_enabled', value);
                    },
                  ),
                  if (_notificationsEnabled) ...[
                    SwitchListTile(
                      title: Text('Ses'.tr),
                      subtitle: Text(LocalizationService.isTurkish 
                          ? 'Bildirim sesleri'
                          : 'Notification sounds'),
                      value: _soundEnabled,
                      activeThumbColor: const Color(0xFFE53935),
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        _saveSetting('sound_enabled', value);
                      },
                    ),
                    SwitchListTile(
                      title: Text('Titreşim'.tr),
                      subtitle: Text(LocalizationService.isTurkish 
                          ? 'Bildirim titreşimleri'
                          : 'Notification vibrations'),
                      value: _vibrationEnabled,
                      activeThumbColor: const Color(0xFFE53935),
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                        _saveSetting('vibration_enabled', value);
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Uygulama Ayarları
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.settings_applications, color: Color(0xFFE53935)),
                        SizedBox(width: 8),
                        Text(
                          'Uygulama Ayarları',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text('Dil'.tr),
                    subtitle: Text(LocalizationService.currentLanguageName),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Dil seçimi dialog'u
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text('Dil Seçin'.tr),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text('Türkçe'.tr),
                                leading: Radio<String>(
                                  value: 'tr',
                                  groupValue: _selectedLanguage,
                                  onChanged: (value) async {
                                    Navigator.pop(dialogContext); // Dialog'u önce kapat
                                    await _changeLanguage(value!);
                                  },
                                ),
                                onTap: () async {
                                  Navigator.pop(dialogContext); // Dialog'u önce kapat
                                  await _changeLanguage('tr');
                                },
                              ),
                              ListTile(
                                title: Text('English'.tr),
                                leading: Radio<String>(
                                  value: 'en',
                                  groupValue: _selectedLanguage,
                                  onChanged: (value) async {
                                    Navigator.pop(dialogContext); // Dialog'u önce kapat
                                    await _changeLanguage(value!);
                                  },
                                ),
                                onTap: () async {
                                  Navigator.pop(dialogContext); // Dialog'u önce kapat
                                  await _changeLanguage('en');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Tema'),
                    subtitle: Text(_selectedTheme),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Tema seçimi dialog'u
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Tema Seçin'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('Sistem'),
                                leading: Radio<String>(
                                  value: 'Sistem',
                                  groupValue: _selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTheme = value!;
                                    });
                                    _saveSetting('theme', value);
                                    Navigator.pop(context);
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTheme = 'Sistem';
                                  });
                                  _saveSetting('theme', 'Sistem');
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Açık'),
                                leading: Radio<String>(
                                  value: 'Açık',
                                  groupValue: _selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTheme = value!;
                                    });
                                    _saveSetting('theme', value);
                                    Navigator.pop(context);
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTheme = 'Açık';
                                  });
                                  _saveSetting('theme', 'Açık');
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('Koyu'),
                                leading: Radio<String>(
                                  value: 'Koyu',
                                  groupValue: _selectedTheme,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTheme = value!;
                                    });
                                    _saveSetting('theme', value);
                                    Navigator.pop(context);
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTheme = 'Koyu';
                                  });
                                  _saveSetting('theme', 'Koyu');
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Güncelleme Bilgileri
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.system_update, color: Color(0xFFE53935)),
                        SizedBox(width: 8),
                        Text(
                          'Güncelleme Bilgileri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.system_update, color: Colors.green),
                    title: const Text('Güncelleme Kontrolü'),
                    subtitle: const Text('Yeni sürüm kontrolü yap'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _checkForUpdates(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update, color: Colors.green),
                    title: const Text('Güncelleme Geçmişi'),
                    subtitle: Text('Sürüm ${VersionService.versionName} - 6 Kasım 2025'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showUpdateHistory,
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: Colors.blue),
                    title: const Text('APK İndirme Klasörü'),
                    subtitle: const Text('Google Drive klasöründen manuel indirme'),
                    trailing: const Icon(Icons.launch, size: 16),
                    onTap: _openGoogleDriveFolder,
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('Geliştirici Hakkında'),
                    subtitle: const Text('Proje bilgileri ve teknolojiler'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showAboutDeveloper,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Debug Bilgileri (Sadece Admin)
            if (_userRole == UserRole.admin)
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.bug_report, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Debug Bilgileri'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Uygulama Sürümü'),
                      subtitle: Text('v${VersionService.versionName} (Build ${VersionService.buildNumber})'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: const Text('Platform'),
                      subtitle: const Text('Android (Flutter 3.35.6)'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Veritabanı'),
                      subtitle: const Text('Firebase Firestore'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Alt bilgi
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '🩸 Bir Damla Kan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hayat kurtarmak bu kadar kolay!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 - Tüm hakları saklıdır',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Drive klasörünü aç
  Future<void> _openGoogleDriveFolder() async {
    const String googleDriveUrl = 'https://drive.google.com/drive/u/1/folders/1PpWxe86lY1yLGcx5-_n5lbPhT0mGyzoy';
    
    try {
      final uri = Uri.parse(googleDriveUrl);
      
      // İlk önce bilgi dialog'u göster
      final bool? shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_download, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text('APK İndirme Klasörü'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Google Drive klasöründen en son APK dosyasını manuel olarak indirebilirsiniz.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 İndirme Adımları:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Google Drive klasörü açılacak\n'
                      '2. En son APK dosyasını bulun\n'
                      '3. Dosyaya tıklayarak indirin\n'
                      '4. İndirilen APK\'yı açarak güncelleyin',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Google Drive\'ı Aç'),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          // Başarı mesajı
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Google Drive klasörü açıldı'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw 'URL açılamıyor';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Google Drive açılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}