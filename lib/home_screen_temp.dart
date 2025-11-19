import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hospitals_screen.dart';
import 'add_blood_request_screen.dart';
import 'blood_compatibility_screen.dart';
import 'blood_group_database_screen.dart';
import 'user_profile_screen.dart';
import 'user_role_service.dart';
import 'admin_setup_screen.dart';
import 'blood_donation_rules_screen.dart';
import 'screens/qr_code_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/blood_request_detail_screen.dart';
import 'screens/about_screen.dart' as about;
import 'screens/data_protection_law_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/admin_feedback_screen.dart';
import 'screens/version_publish_screen.dart';
import 'services/update_service.dart';
import 'services/statistics_service.dart';
import 'widgets/version_info_widget.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> bloodRequests = [];
  bool isLoggedIn = false; // Kullanıcı giriş durumu
  bool isLoading = true;
  String userDisplayName = 'Misafir'; // Kullanıcı adı
  String userEmail = ''; // Kullanıcı e-postası
  UserRole userRole = UserRole.guest; // Kullanıcı rolü

  @override
  void initState() {
    super.initState();
    _loadBloodRequests();
    _checkUserStatus();
    // Otomatik güncelleme kontrolü
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.autoCheckForUpdates(context);
    });
  }

  Future<void> _checkUserStatus() async {
    // Kullanıcı rolünü kontrol et
    UserRole currentRole = await UserRoleService.getCurrentUserRole();
    
    // Firebase Auth ile giriş durumunu kontrol et
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null && currentRole != UserRole.guest) {
      // Kullanıcı giriş yapmış ve geçerli rol var
      setState(() {
        isLoggedIn = true;
        userEmail = user.email ?? '';
        userRole = currentRole;
      });
      
      // Firestore'dan kullanıcı bilgilerini çek
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String roleString = userData['role'] ?? 'user';
          
          setState(() {
            userDisplayName = '${userData['name'] ?? ''} ${userData['surname'] ?? ''}'.trim();
            if (userDisplayName.isEmpty) {
              userDisplayName = userEmail.split('@')[0]; // E-posta'dan ad al
            }
            
            // Rol badge için displayName'e rol ekle
            String roleText = '';
            switch (roleString) {
              case 'admin':
                roleText = ' (Admin)';
                break;
              case 'user':
                roleText = ' (Kullanıcı)';
                break;
              default:
                roleText = '';
            }
            userDisplayName += roleText;
          });
        } else {
          // Firestore'da kullanıcı bulunamadı, e-posta'dan ad al
          setState(() {
            userDisplayName = userEmail.split('@')[0];
          });
        }
      } catch (e) {
        // Hata durumunda e-posta'dan ad al
        setState(() {
          userDisplayName = userEmail.split('@')[0];
        });
        debugPrint('❌ Kullanıcı bilgileri yüklenirken hata: $e');
      }
    } else {
      // Kullanıcı giriş yapmamış veya misafir
      setState(() {
        isLoggedIn = false;
        userDisplayName = 'Misafir';
        userEmail = '';
        userRole = UserRole.guest;
      });
    }
  }

  Future<void> _loadBloodRequests() async {
    try {
      // Firebase Firestore'dan kan taleplerini yükle
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('blood_requests')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      List<Map<String, dynamic>> requests = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        requests.add({
          'id': doc.id,
          'hospitalName': data['hospital'] ?? 'Bilinmeyen Hastane',
          'patientName': isLoggedIn ? data['patientName'] ?? 'Ad Soyad' : 'A. S.',
          'bloodType': data['bloodType'] ?? 'A+',
          'urgency': data['urgency'] ?? 'Normal',
          'contactPhone': isLoggedIn ? data['contactPhone'] ?? '055*******' : '055*******',
          'location': data['location'] ?? 'Konum belirtilmemiş',
          'description': data['description'] ?? 'Açıklama yok',
          'timestamp': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'contactPerson': isLoggedIn ? data['contactPerson'] ?? 'İletişim kişisi' : 'İ. K.',
        });
      }

      setState(() {
        bloodRequests = requests;
        isLoading = false;
      });

      debugPrint('✅ Firebase kan talepleri yüklendi: ${requests.length} adet');
    } catch (e) {
      debugPrint('❌ Firebase veri yükleme hatası: $e');
      _loadSampleData();
    }
  }

  void _loadSampleData() {
    setState(() {
      bloodRequests = [
        {
          'id': '1',
          'hospitalName': 'Ankara Şehir Hastanesi',
          'patientName': isLoggedIn ? 'Mehmet Yılmaz' : 'M. Y.',
          'bloodType': 'A+',
          'urgency': 'Acil',
          'contactPhone': isLoggedIn ? '05551234567' : '055*******',
          'location': 'Çankaya, Ankara',
          'description': 'Ameliyat için acil kan ihtiyacı',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'contactPerson': isLoggedIn ? 'Dr. Ayşe Demir' : 'Dr. A. D.',
        },
        {
          'id': '2',
          'hospitalName': 'Hacettepe Üniversitesi Hastanesi',
          'patientName': isLoggedIn ? 'Fatma Öztürk' : 'F. Ö.',
          'bloodType': '0-',
          'urgency': 'Orta',
          'contactPhone': isLoggedIn ? '05559876543' : '055*******',
          'location': 'Sıhhiye, Ankara',
          'description': 'Kanser tedavisi için kan ihtiyacı',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'contactPerson': isLoggedIn ? 'Hemşiye Zeynep Kaya' : 'Hemşire Z. K.',
        },
        {
          'id': '3',
          'hospitalName': 'Gazi Üniversitesi Hastanesi',
          'patientName': isLoggedIn ? 'Ali Demir' : 'A. D.',
          'bloodType': 'B+',
          'urgency': 'Normal',
          'contactPhone': isLoggedIn ? '05556547891' : '055*******',
          'location': 'Beşevler, Ankara',
          'description': 'Kronik hastalık tedavisi için kan ihtiyacı',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'contactPerson': isLoggedIn ? 'Dr. Murat Aslan' : 'Dr. M. A.',
        },
      ];
      isLoading = false;
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'acil':
        return Colors.red;
      case 'orta':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Çıkış yapma dialog'u
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog dışına tıklayarak kapatılamaz
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFE53935)),
              SizedBox(width: 12),
              Text('Çıkış Yap'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('$userDisplayName hesabından çıkış yapmak istediğinize emin misiniz?'),
                const SizedBox(height: 8),
                const Text(
                  'Çıkış yaptıktan sonra sadece genel bilgileri görüntüleyebileceksiniz.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                navigator.pop(); // Dialog'u kapat
                
                // Loading göster
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  // Firebase'den çıkış yap
                  await FirebaseAuth.instance.signOut();
                  
                  // Loading'i kapat
                  if (mounted) {
                    navigator.pop();
                  }
                  
                  // Kullanıcı durumunu güncelle
                  _checkUserStatus();
                  
                  // Kan taleplerini yeniden yükle (misafir görünümü için)
                  _loadBloodRequests();
                  
                  // Başarı mesajı
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Başarıyla çıkış yapıldı'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Loading'i kapat
                  if (mounted) {
                    navigator.pop();
                  }
                  
                  // Hata mesajı
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('❌ Çıkış yapılırken hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Misafir kullanıcı dialog'u
  Future<void> _showGuestDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog dışına tıklayarak kapatılamaz
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFFE53935)),
              SizedBox(width: 12),
              Text('Misafir Kullanıcı'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Şu anda misafir olarak geziniyorsunuz.'),
                SizedBox(height: 8),
                Text(
                  'Giriş yaparak tüm özelliklere erişebilir, kan talebi oluşturabilir ve kişisel bilgilerinizi yönetebilirsiniz.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Ana Sayfaya Dön',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                
                // Ana sayfaya (WelcomeScreen) yönlendir
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Giriş Yap'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                
                // Ana sayfaya (WelcomeScreen) yönlendir - giriş yapma seçenekleri için
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Admin Fonksiyonları
  void _showUserManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFFF5722)),
            SizedBox(width: 12),
            Text('Kullanıcı Yönetimi'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kullanıcı yönetimi paneli geliştiriliyor...'),
            SizedBox(height: 16),
            Text(
              'Bu bölümde kullanıcı rollerini güncelleyebilecek, kullanıcıları yönetebileceksiniz.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFFFF5722)),
              SizedBox(width: 12),
              Text('Sistem İstatistikleri'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gerçek zamanlı sistem verileri:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Firebase verilerini çek ve göster
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getSystemStatistics(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                              ),
                              SizedBox(height: 16),
                              Text('Veriler yükleniyor...'),
                            ],
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text('Hata: ${snapshot.error}'),
                          ],
                        );
                      }
                      
                      final stats = snapshot.data ?? {};
                      
                      return Column(
                        children: [
                          _buildStatCard(
                            icon: Icons.people,
                            title: 'Toplam Kullanıcı',
                            value: '${stats['total_users'] ?? 0}',
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.bloodtype,
                            title: 'Kan Talepleri',
                            value: '${stats['total_blood_requests'] ?? 0}',
                            color: const Color(0xFFE53935),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.local_hospital,
                            title: 'Hastaneler',
                            value: '${stats['total_hospitals'] ?? 0}',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.location_city,
                            title: 'Şehirler',
                            value: '${stats['total_cities'] ?? 0}',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.place,
                            title: 'İlçeler',
                            value: '${stats['total_districts'] ?? 0}',
                            color: Colors.purple,
                          ),
                          const SizedBox(height: 20),
                          
                          // Kan grubu dağılımı
                          if (stats['blood_type_distribution'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kan Grubu Dağılımı:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...((stats['blood_type_distribution'] as Map<String, dynamic>).entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${entry.key}:'),
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                        ],
                      );
                    },
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Verileri yenile
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yenile'),
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik kartı widget'ı
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Firebase'den sistem istatistiklerini çek
  Future<Map<String, dynamic>> _getSystemStatistics() async {
    try {
      // Yeni StatisticsService'i kullan
      return await StatisticsService.getCompleteSystemStatistics();
    } catch (e) {
      debugPrint('❌ İstatistik yükleme hatası: $e');
      return {
        'error': e.toString(),
        'totalUsers': 0,
        'bloodRequests': 0,
        'hospitals': 0,
        'cities': 0,
        'districts': 0,
      };
    }
  }

  void _showSystemSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_applications, color: Color(0xFFFF5722)),
            SizedBox(width: 12),
            Text('Sistem Ayarları'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sistem ayarları paneli geliştiriliyor...'),
            SizedBox(height: 16),
            Text(
              'Bu bölümde uygulama ayarlarını, bildirimleri ve genel sistem konfigürasyonunu yönetebileceksiniz.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showVersionPublishDialog() {
    final versionController = TextEditingController();
    final buildNumberController = TextEditingController();
    final downloadUrlController = TextEditingController();
    final updateNotesController = TextEditingController();
    bool forceUpdate = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.publish, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text('Yeni Sürüm Yayınla'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: versionController,
                    decoration: const InputDecoration(
                      labelText: 'Versiyon (örn: 1.0.2)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: buildNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Build Number (örn: 2)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: downloadUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Google Drive Link',
                      hintText: 'https://drive.google.com/file/d/...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.folder, color: Colors.blue, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'APK Klasörü:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          VersionManager.getGoogleDriveFolderUrl(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. APK\'yı klasöre yükleyin\n'
                          '2. Dosyaya sağ tıklayın → Paylaş\n'
                          '3. "Bağlantıya sahip herkes" seçin\n'
                          '4. Bağlantıyı kopyalayıp buraya yapıştırın',
                          style: TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: updateNotesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Güncelleme Notları',
                      hintText: 'Yeni özellikler ve düzeltmeler...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: forceUpdate,
                    onChanged: (value) {
                      setState(() {
                        forceUpdate = value ?? false;
                      });
                    },
                    title: const Text('Zorunlu Güncelleme'),
                    subtitle: const Text('Kullanıcılar zorla güncellemek zorunda kalır'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (versionController.text.trim().isEmpty ||
                    buildNumberController.text.trim().isEmpty ||
                    downloadUrlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Tüm alanları doldurun'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  await VersionManager.publishNewVersion(
                    version: versionController.text.trim(),
                    buildNumber: int.parse(buildNumberController.text.trim()),
                    downloadUrl: downloadUrlController.text.trim(),
                    updateNotes: updateNotesController.text.trim(),
                    forceUpdate: forceUpdate,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Yeni sürüm başarıyla yayınlandı!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Yayınlama hatası: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yayınla'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('Kan Talepleri'),
            const SizedBox(width: 8),
            const CompactVersionWidget(
              showLabel: true,
              textStyle: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            // Kullanıcı adı
            GestureDetector(
              onTap: () {
                if (isLoggedIn) {
                  _showLogoutDialog();
                } else {
                  _showGuestDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLoggedIn ? Icons.person : Icons.person_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      userDisplayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.logout,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ] else ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Çıkış yapıldı'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Ana sayfaya dön
                }
              },
              tooltip: 'Çıkış Yap',
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.bloodtype,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Bir Damla Kan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hayat Kurtaran Platform',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  // Kullanıcı bilgisi
                  GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        _showLogoutDialog();
                      } else {
                        _showGuestDialog();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLoggedIn ? Icons.person : Icons.person_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),


            ListTile(
              leading: const Icon(Icons.bloodtype, color: Color(0xFFE53935)),
              title: const Text('Kan Talepleri'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
 const Divider(),

            ListTile(
              leading: const Icon(Icons.local_hospital, color: Color(0xFFE53935)),
              title: const Text('Hastaneler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HospitalsScreen()),
                );
              },
            ),


            ListTile(
              leading: const Icon(Icons.compare_arrows, color: Color(0xFFE53935)),
              title: const Text('Kan Uyumluluğu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BloodCompatibilityScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.rule, color: Color(0xFFE53935)),
              title: const Text('Kan Bağışı Kuralları'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BloodDonationRulesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: Color(0xFFE53935)),
              title: const Text('Verilerin Korunması Yasası'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataProtectionLawScreen()),
                );
              },
            ),
            // Kan Grupları Veritabanı - Sadece Admin
            if (userRole == UserRole.admin)
              ListTile(
                leading: const Icon(Icons.storage, color: Color(0xFFE53935)),
                title: const Text('Kan Grupları Veritabanı'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BloodGroupDatabaseScreen()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Color(0xFFE53935)),
              title: const Text('QR Kod'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRCodeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.purple),
              title: const Text('Geri Bildirim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            const Divider(),
            // Kan Talebi Oluştur - Sadece Admin
            if (userRole == UserRole.admin)
              ListTile(
                leading: const Icon(Icons.add, color: Color(0xFFE53935)),
                title: const Text('Kan Talebi Oluştur'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddBloodRequestScreen()),
                  );
                  
                  // Eğer yeni kan talebi eklendiyse sayfayı yenile
                  if (result == true) {
                    _loadBloodRequests();
                  }
                },
              ),
            ListTile(
              leading: Icon(
                Icons.person, 
                color: isLoggedIn ? const Color(0xFFE53935) : Colors.grey
              ),
              title: Text(
                'Profil',
                style: TextStyle(
                  color: isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),
              enabled: isLoggedIn,
              onTap: isLoggedIn ? () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                );
              } : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Profil sayfasına erişmek için giriş yapmanız gerekiyor'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
            
            // Admin Menüleri
            if (userRole == UserRole.admin) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Admin Paneli',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Color(0xFFFF5722)),
                title: const Text('Kullanıcı Yönetimi'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserManagement();
                },
              ),
              ListTile(
                leading: const Icon(Icons.security, color: Color(0xFFFF5722)),
                title: const Text('Admin Yetkisi Ver'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminSetupScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined, color: Color(0xFFFF5722)),
                title: const Text('Geri Bildirim Yönetimi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminFeedbackScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics, color: Color(0xFFFF5722)),
                title: const Text('İstatistikler'),
                onTap: () {
                  Navigator.pop(context);
                  _showStatistics();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications, color: Color(0xFFFF5722)),
                title: const Text('Sistem Ayarları'),
                onTap: () {
                  Navigator.pop(context);
                  _showSystemSettings();
                },
              ),
              ListTile(
                leading: const Icon(Icons.publish, color: Color(0xFFFF5722)),
                title: const Text('Yeni Sürüm Yayınla'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VersionPublishScreen()),
                  );
                },
              ),
            ],
            
            // Geliştirici Araçları - Sadece Admin
            if (userRole == UserRole.admin) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Geliştirici Araçları',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.developer_mode, color: Colors.orange),
                title: const Text('Acil Admin Yetkisi'),
                subtitle: const Text('Development only'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeveloperDialog();
                },
              ),
            ],
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFFE53935)),
              title: const Text('Hakkında'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const about.AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header bilgi kartı
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLoggedIn
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isLoggedIn ? Icons.verified_user : Icons.person_outline,
                  color: isLoggedIn ? Colors.green.shade700 : Colors.orange.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn
                            ? 'Hoşgeldin, $userDisplayName!'
                            : 'Misafir Kullanıcı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLoggedIn
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoggedIn
                            ? 'Tüm bilgileri görebilir ve talep oluşturabilirsiniz'
                            : 'Kayıt olun, tam bilgileri görün ve talep oluşturun',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLoggedIn
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kan talepleri listesi
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bloodRequests.length,
                    itemBuilder: (context, index) {
                      final request = bloodRequests[index];
                      return GestureDetector(
                        onTap: () {
                          // Kan talebi detay sayfasına git
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BloodRequestDetailScreen(
                                bloodRequest: request,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          request['bloodType'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request['hospitalName'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            request['patientName'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(
                                          request['urgency'],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        request['urgency'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        request['location'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatTimeAgo(request['timestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Tıklama ipucu
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Detayları görmek için dokunun',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Sadece user ve admin rolü kan talebi oluşturabilir
          if (userRole == UserRole.guest) {
            _showGuestDialog();
            return;
          }
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBloodRequestScreen()),
          );
          
          // Eğer yeni kan talebi eklendiyse sayfayı yenile
          if (result == true) {
            _loadBloodRequests();
          }
        },
        backgroundColor: (userRole != UserRole.guest) ? const Color(0xFFE53935) : Colors.grey,
        foregroundColor: Colors.white,
        icon: Icon(
          Icons.add,
          color: (userRole != UserRole.guest) ? Colors.white : Colors.grey.shade400,
        ),
        label: Text(
          'Talep Oluştur',
          style: TextStyle(
            color: (userRole != UserRole.guest) ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // Kullanıcı rolünü yükle
  Future<void> _loadCurrentUserRole() async {
    try {
      UserRole role = await UserRoleService.getCurrentUserRole();
      setState(() {
        userRole = role;
      });
    } catch (e) {
      debugPrint('Kullanıcı rolü yüklenirken hata: $e');
    }
  }

  // Geliştirici modu dialog
  void _showDeveloperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.developer_mode, color: Colors.orange),
            SizedBox(width: 8),
            Text('🔧 Geliştirici Modu'),
          ],
        ),
        content: const Text(
          'Bu özellik sadece geliştirme aşamasında kullanılmalıdır.\n\n'
          'E-posta adresinizi girerek acil admin yetkisi alabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmergencyAdminDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  // Acil admin yetkisi dialog
  void _showEmergencyAdminDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Acil Admin Yetkisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('E-posta adresinizi girin:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                hintText: 'ornek@kanbagisc.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                navigator.pop();
                
                // Loading göster
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Admin yetkisi veriliyor...'),
                      ],
                    ),
                  ),
                );
                
                try {
                  await UserRoleService.emergencyCreateAdmin(emailController.text);
                  if (!mounted) return;
                  
                  if (mounted) {
                    navigator.pop(); // Loading kapat
                  }
                  
                  // Kullanıcı rolünü güncelle
                  _loadCurrentUserRole();
                  
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('✅ Admin yetkisi başarıyla verildi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  
                  if (mounted) {
                    navigator.pop(); // Loading kapat
                  }
                  
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('❌ Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Admin Yap'),
          ),
        ],
      ),
    );
  }
}
