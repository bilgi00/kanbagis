import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore_for_file: use_build_context_synchronously

class UpdateService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Mevcut app versiyonu (pubspec.yaml ile senkron olmalı)
  static const String currentVersion = '1.0.3';
  static const int currentBuildNumber = 3;
  
  // Firebase'de version bilgisini kontrol et
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      debugPrint('🔍 Güncelleme kontrolü yapılıyor...');
      
      DocumentSnapshot versionDoc = await _firestore
          .collection('app_versions')
          .doc('latest')
          .get();
          
      if (!versionDoc.exists) {
        debugPrint('❌ Versiyon bilgisi bulunamadı');
        return null;
      }
      
      Map<String, dynamic> versionData = versionDoc.data() as Map<String, dynamic>;
      
      String latestVersion = versionData['version'] ?? currentVersion;
      int latestBuildNumber = versionData['buildNumber'] ?? currentBuildNumber;
      bool forceUpdate = versionData['forceUpdate'] ?? false;
      String downloadUrl = versionData['downloadUrl'] ?? '';
      String updateNotes = versionData['updateNotes'] ?? 'Yeni güncelleme mevcut';
      
      debugPrint('📱 Mevcut versiyon: $currentVersion (Build: $currentBuildNumber)');
      debugPrint('🆕 En son versiyon: $latestVersion (Build: $latestBuildNumber)');
      
      // Versiyon karşılaştırma
      if (_isNewerVersion(latestVersion, latestBuildNumber)) {
        debugPrint('✅ Yeni güncelleme mevcut!');
        return {
          'hasUpdate': true,
          'latestVersion': latestVersion,
          'currentVersion': currentVersion,
          'downloadUrl': downloadUrl,
          'forceUpdate': forceUpdate,
          'updateNotes': updateNotes,
          'buildNumber': latestBuildNumber,
        };
      } else {
        debugPrint('📱 Uygulama güncel');
        return {'hasUpdate': false};
      }
      
    } catch (e) {
      debugPrint('❌ Güncelleme kontrolü hatası: $e');
      return null;
    }
  }
  
  // Versiyon karşılaştırma
  static bool _isNewerVersion(String latestVersion, int latestBuildNumber) {
    // Build number karşılaştırması daha güvenilir
    return latestBuildNumber > currentBuildNumber;
  }
  
  // Güncelleme dialog'unu göster
  static void showUpdateDialog(BuildContext context, Map<String, dynamic> updateInfo) {
    final bool forceUpdate = updateInfo['forceUpdate'] ?? false;
    
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate, // Zorunlu güncellemede kapatılamaz
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              forceUpdate ? Icons.warning : Icons.system_update,
              color: forceUpdate ? Colors.red : const Color(0xFFE53935),
            ),
            const SizedBox(width: 8),
            Text(forceUpdate ? 'Zorunlu Güncelleme' : 'Yeni Güncelleme'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (forceUpdate)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu güncelleme zorunludur. Devam etmek için uygulamayı güncellemeniz gerekiyor.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (forceUpdate) const SizedBox(height: 16),
              
              Text(
                'Versiyon ${updateInfo['latestVersion']} mevcut',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mevcut versiyon: ${updateInfo['currentVersion']}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Güncelleme Notları:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  updateInfo['updateNotes'] ?? 'Yeni özellikler ve iyileştirmeler',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '📋 Güncelleme Adımları:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. "İndir" butonuna tıklayın\n'
                '2. APK dosyası indirilecek\n'
                '3. İndirilen dosyayı açın\n'
                '4. "Güncelle" seçeneğini seçin\n'
                '5. Uygulama otomatik güncellenecek',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _markUpdateReminded();
              },
              child: const Text('Sonra Hatırlat'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadUpdate(context, updateInfo['downloadUrl']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('İndir'),
          ),
        ],
      ),
    );
  }
  
  // Güncelleme indirme
  static void _downloadUpdate(BuildContext context, String downloadUrl) {
    if (downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ İndirme bağlantısı bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Güncelleme İndiriliyor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
            ),
            const SizedBox(height: 16),
            const Text('Google Drive\'dan güncelleme indiriliyor...'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 İpucu: İndirme tamamlandığında bildirim göreceksiniz. '
                'APK dosyasını açarak uygulamayı güncelleyebilirsiniz.',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Tarayıcıda aç
              _openDownloadUrl(downloadUrl);
            },
            child: const Text('Tarayıcıda Aç'),
          ),
        ],
      ),
    );
    
    // 2 saniye sonra tarayıcıda aç
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _openDownloadUrl(downloadUrl);
    });
  }
  
  // URL'yi tarayıcıda aç
  static Future<void> _openDownloadUrl(String url) async {
    try {
      debugPrint('🌐 Tarayıcıda açılıyor: $url');
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ URL açılamıyor: $url');
      }
    } catch (e) {
      debugPrint('❌ URL açma hatası: $e');
    }
  }
  
  // Hatırlatma işareti
  static Future<void> _markUpdateReminded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_update_reminder', DateTime.now().toIso8601String());
  }
  
  // Son hatırlatma kontrolü
  static Future<bool> shouldShowUpdateReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReminder = prefs.getString('last_update_reminder');
    
    if (lastReminder == null) return true;
    
    final lastReminderDate = DateTime.parse(lastReminder);
    final daysSinceReminder = DateTime.now().difference(lastReminderDate).inDays;
    
    // 3 günde bir hatırlat
    return daysSinceReminder >= 3;
  }
  
  // Uygulama başlatıldığında otomatik kontrol
  static Future<void> autoCheckForUpdates(BuildContext context) async {
    try {
      final updateInfo = await checkForUpdates();
      
      if (updateInfo != null && updateInfo['hasUpdate'] == true) {
        final shouldShow = await shouldShowUpdateReminder();
        final isForceUpdate = updateInfo['forceUpdate'] ?? false;
        
        if (isForceUpdate || shouldShow) {
          // Kısa bir gecikme sonrası göster
          Future.delayed(const Duration(seconds: 2), () {
            // Context mounted kontrolü eklendi
            if (context.mounted) {
              showUpdateDialog(context, updateInfo);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Otomatik güncelleme kontrolü hatası: $e');
    }
  }
}

// Firebase'e versiyon bilgisi ekleme helper'ı (Admin için)
class VersionManager {
  // Google Drive klasör linki - sabit
  static const String googleDriveFolderUrl = 'https://drive.google.com/drive/u/1/folders/1PpWxe86lY1yLGcx5-_n5lbPhT0mGyzoy';
  
  static Future<void> publishNewVersion({
    required String version,
    required int buildNumber,
    required String downloadUrl,
    required String updateNotes,
    bool forceUpdate = false,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('app_versions')
          .doc('latest')
          .set({
        'version': version,
        'buildNumber': buildNumber,
        'downloadUrl': downloadUrl,
        'updateNotes': updateNotes,
        'forceUpdate': forceUpdate,
        'publishDate': FieldValue.serverTimestamp(),
        'publishedBy': 'admin',
        'googleDriveFolder': googleDriveFolderUrl, // Sabit klasör linki
      });
      
      debugPrint('✅ Yeni versiyon yayınlandı: $version (Build: $buildNumber)');
    } catch (e) {
      debugPrint('❌ Versiyon yayınlama hatası: $e');
    }
  }
  
  // Google Drive klasörüne direkt erişim
  static String getGoogleDriveFolderUrl() {
    return googleDriveFolderUrl;
  }
}