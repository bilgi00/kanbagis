import 'package:flutter/material.dart';
import '../services/update_service.dart';

class VersionPublishScreen extends StatefulWidget {
  const VersionPublishScreen({super.key});

  @override
  State<VersionPublishScreen> createState() => _VersionPublishScreenState();
}

class _VersionPublishScreenState extends State<VersionPublishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _versionController = TextEditingController(text: '1.0.3');
  final _buildNumberController = TextEditingController(text: '3');
  final _downloadUrlController = TextEditingController();
  final _updateNotesController = TextEditingController(
    text: '🆕 V1.0.3 Güncellemesi - 4 Kasım 2025\n\n'
          '✅ Yeni Özellikler:\n'
          '• 📝 Geri Bildirim Sistemi: Kullanıcılar artık sorunları, önerileri ve hata bildirimlerini gönderebilir\n'
          '• 👨‍💼 Admin Geri Bildirim Yönetimi: Admin kullanıcıları geri bildirimleri kategorize edip yönetebilir\n'
          '• 🏷️ Kategori Sistemi: Sorun bildirimi, hata raporu, güncelleme talebi, özellik isteği vb.\n'
          '• ⭐ Öncelik Sistemi: Otomatik öncelik atama (Yüksek/Orta/Düşük)\n'
          '• 📅 Tarih Damgası: Tüm geri bildirimler otomatik tarih/saat ile işaretlenir\n'
          '• 🎨 Modern UI: Renkli kategori ikonları ve kullanıcı dostu arayüz\n\n'
          '🔧 İyileştirmeler:\n'
          '• 📱 Kullanıcı Profili: Geri bildirim gönderme butonu eklendi\n'
          '• 🏠 Ana Menü: Geri bildirim seçeneği eklendi\n'
          '• 👑 Admin Panel: Geri bildirim yönetimi menüsü eklendi\n'
          '• 🎯 Durum Takibi: Yeni/İnceleniyor/Çözüldü/Reddedildi durumları\n'
          '• 🔍 Filtreleme: Kategori ve durum bazlı filtreleme sistemi\n\n'
          '🛡️ Güvenlik & Stabilite:\n'
          '• Firebase güvenlik kuralları güncellendi\n'
          '• Admin yetkisi kontrolleri eklendi\n'
          '• Form validasyonları iyileştirildi\n\n'
          '📊 Teknik Detaylar:\n'
          '• StreamBuilder ile gerçek zamanlı güncellemeler\n'
          '• Responsive tasarım - tüm ekran boyutlarına uyumlu\n'
          '• Hata yönetimi ve kullanıcı bildirimleri\n'
          '• Temiz kod yapısı ve modüler mimari\n\n'
          'Bu güncelleme ile kullanıcılarımız deneyimlerini paylaşabilir ve uygulamayı birlikte geliştirebiliriz! 🚀'
  );
  bool _forceUpdate = false;
  bool _isPublishing = false;

  @override
  void dispose() {
    _versionController.dispose();
    _buildNumberController.dispose();
    _downloadUrlController.dispose();
    _updateNotesController.dispose();
    super.dispose();
  }

  Future<void> _publishVersion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      await VersionManager.publishNewVersion(
        version: _versionController.text.trim(),
        buildNumber: int.parse(_buildNumberController.text.trim()),
        downloadUrl: _downloadUrlController.text.trim(),
        updateNotes: _updateNotesController.text.trim(),
        forceUpdate: _forceUpdate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('✅ Versiyon ${_versionController.text} başarıyla yayınlandı!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Formu temizle
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Yeni Sürüm Yayınla'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık Kartı
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFD32F2F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.publish,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Yeni Sürüm Yayınla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kullanıcılara yeni güncelleme bilgisi gönder',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Versiyon Bilgileri
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: const Color(0xFFE53935), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Versiyon Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _versionController,
                              decoration: InputDecoration(
                                labelText: 'Versiyon',
                                hintText: '1.0.3',
                                prefixIcon: const Icon(Icons.tag, color: Color(0xFFE53935)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Versiyon gerekli';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _buildNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Build Number',
                                hintText: '3',
                                prefixIcon: const Icon(Icons.numbers, color: Color(0xFFE53935)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Build number gerekli';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Geçerli sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // İndirme Linki
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_download, color: const Color(0xFFE53935), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'İndirme Bağlantısı',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _downloadUrlController,
                        decoration: InputDecoration(
                          labelText: 'Google Drive Link',
                          hintText: 'https://drive.google.com/file/d/...',
                          prefixIcon: const Icon(Icons.link, color: Color(0xFFE53935)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'İndirme linki gerekli';
                          }
                          if (!value.contains('drive.google.com')) {
                            return 'Geçerli Google Drive linki girin';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.folder, color: Colors.blue.shade700, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'APK Klasörü:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              VersionManager.getGoogleDriveFolderUrl(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '📋 Adımlar:\n'
                              '1. APK\'yı klasöre yükleyin\n'
                              '2. Dosyaya sağ tıklayın → Paylaş\n'
                              '3. "Bağlantıya sahip herkes" seçin\n'
                              '4. Bağlantıyı kopyalayıp buraya yapıştırın',
                              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Güncelleme Notları
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: const Color(0xFFE53935), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Güncelleme Notları',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _updateNotesController,
                        maxLines: 12,
                        decoration: InputDecoration(
                          labelText: 'Yeni özellikler ve düzeltmeler',
                          hintText: 'Güncelleme detaylarını buraya yazın...',
                          prefixIcon: const Icon(Icons.notes, color: Color(0xFFE53935)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Güncelleme notları gerekli';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ayarlar
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: const Color(0xFFE53935), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Güncelleme Ayarları',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          value: _forceUpdate,
                          onChanged: (value) {
                            setState(() {
                              _forceUpdate = value ?? false;
                            });
                          },
                          title: const Text(
                            'Zorunlu Güncelleme',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Kullanıcılar uygulamaya devam edebilmek için güncellemeyi yapmak zorunda kalır',
                            style: TextStyle(fontSize: 12),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Yayınla Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _publishVersion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isPublishing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Yayınlanıyor...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Sürüm Yayınla',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Uyarı Notu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Önemli Uyarı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu işlem tüm kullanıcılara güncelleme bildirimi gönderir. '
                      'Lütfen APK dosyasının Google Drive\'a yüklendiğinden ve erişilebilir olduğundan emin olun. '
                      'Zorunlu güncelleme seçeneği kullanıcıları uygulamayı kullanmadan önce güncellemeye zorlar.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}