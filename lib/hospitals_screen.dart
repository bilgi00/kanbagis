import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hospital_service.dart';
import 'add_hospital_screen.dart';
import 'blood_group_service.dart';
import 'district_service.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  List<Map<String, dynamic>> hospitals = [];
  List<String> regions = [];
  String? selectedRegion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
    _loadRegions();
  }

  Future<void> _loadHospitals() async {
    debugPrint('🔄 Hastane verileri yükleniyor... Seçili bölge: $selectedRegion');
    
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> loadedHospitals = await HospitalService.getHospitals(
        region: selectedRegion,
      );
      
      debugPrint('✅ ${loadedHospitals.length} hastane yüklendi');
      
      setState(() {
        hospitals = loadedHospitals;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Hastane yükleme hatası: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hastane verileri yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRegions() async {
    try {
      List<String> loadedRegions = await HospitalService.getRegions();
      setState(() {
        regions = loadedRegions;
      });
    } catch (e) {
      debugPrint('❌ Bölge listesi yüklenemedi: $e');
    }
  }

  Future<void> _openMaps(Map<String, dynamic> hospital) async {
    String? address = hospital['address'];
    String? hospitalName = hospital['hospitalName'];
    String? region = hospital['region'];
    
    // Arama sorgusu oluştur
    String searchQuery = '';
    if (hospitalName != null && hospitalName.isNotEmpty) {
      searchQuery = hospitalName;
      if (address != null && address.isNotEmpty) {
        searchQuery += ', $address';
      } else if (region != null && region.isNotEmpty) {
        searchQuery += ', $region';
      }
    } else if (address != null && address.isNotEmpty) {
      searchQuery = address;
    } else if (region != null && region.isNotEmpty) {
      searchQuery = region;
    }
    
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Bu hastane için adres bilgisi bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}');
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Haritalar açılamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Haritalar açılamadı: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Haritalar açılırken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ignore: unused_element
  Future<void> _addCyprusHospitals() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Kuzey Kıbrıs hastaneleri ekleniyor...')),
          ],
        ),
      ),
    );

    try {
      // Artık bu fonksiyon HospitalService'de yok
      debugPrint('❌ Bu özellik kaldırıldı');
      
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kuzey Kıbrıs hastaneleri başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Verileri yeniden yükle
        _loadHospitals();
        _loadRegions();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Kıbrıs hastaneleri ekleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addSampleData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Örnek hastane verileri ekleniyor...'),
          ],
        ),
      ),
    );

    try {
      // Artık bu fonksiyon HospitalService'de yok
      debugPrint('❌ Bu özellik kaldırıldı');
      
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Örnek hastane verileri başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Verileri yeniden yükle
        _loadHospitals();
        _loadRegions();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Örnek veri ekleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createBloodGroupsTable() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Kan grupları tablosu oluşturuluyor...')),
          ],
        ),
      ),
    );

    try {
      await BloodGroupService.createBloodGroupsCollection();
      
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kan grupları tablosu başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Kan grupları tablosu oluşturma hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _listBloodGroups() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Kan grupları verisi getiriliyor...'),
          ],
        ),
      ),
    );

    try {
      List<Map<String, dynamic>> bloodGroups = await BloodGroupService.getAllBloodGroups();
      
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        
        if (bloodGroups.isNotEmpty) {
          // Başarılı mesaj
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${bloodGroups.length} kan grubu verisi konsola yazdırıldı'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Detayları Gör',
                textColor: Colors.white,
                onPressed: () {
                  _showBloodGroupsDialog(bloodGroups);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Henüz kan grupları tablosu oluşturulmamış'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Kan grupları listesi getirme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBloodGroupsDialog(List<Map<String, dynamic>> bloodGroups) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kan Grupları Tablosu'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam ${bloodGroups.length} kan grubu kaydı bulundu:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...bloodGroups.map((group) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getBloodTypeColor(group['kan_grubu']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  group['kan_grubu'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${group['id']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '✅ Verebilir: ${group['kime_verebilir']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '🩸 Alabilir: ${group['kimden_alabilir']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
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

  Color _getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
      case 'A-':
        return Colors.red;
      case 'B+':
      case 'B-':
        return Colors.blue;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      case 'O+':
      case 'O-':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _listDistricts() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('İlçeler verisi getiriliyor...'),
          ],
        ),
      ),
    );

    try {
      List<Map<String, dynamic>> districts = await DistrictService.getAllDistricts();
      
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        
        if (districts.isNotEmpty) {
          // Başarılı mesaj
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${districts.length} ilçe verisi konsola yazdırıldı'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Detayları Gör',
                textColor: Colors.white,
                onPressed: () {
                  _showDistrictsDialog(districts);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Henüz ilçeler tablosu oluşturulmamış'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ İlçeler listesi getirme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDistrictsDialog(List<Map<String, dynamic>> districts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlçeler Tablosu'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam ${districts.length} ilçe kaydı bulundu:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...districts.map((district) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.location_city,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    district['ilce'] ?? 'İlçe Adı',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (district['notlar'] != null) ...[
                                    Text(
                                      district['notlar'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bölgeler:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (district['bolgeler'] as List<dynamic>? ?? [])
                              .map((region) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      region.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                )),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Hastaneler'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'create_blood_groups',
                child: const Row(
                  children: [
                    Icon(Icons.bloodtype, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('Kan Grupları Tablosu Oluştur'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'list_blood_groups',
                child: const Row(
                  children: [
                    Icon(Icons.list, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('Kan Grupları Listele'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'create_districts',
                child: const Row(
                  children: [
                    Icon(Icons.location_city, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('İlçeler Tablosu Oluştur'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'list_districts',
                child: const Row(
                  children: [
                    Icon(Icons.map, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('İlçeler Listele'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'debug_sample',
                child: const Row(
                  children: [
                    Icon(Icons.bug_report, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('Debug: Test Verisi'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Text('Yenile'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'create_blood_groups':
                  _createBloodGroupsTable();
                  break;
                case 'list_blood_groups':
                  _listBloodGroups();
                  break;
                case 'list_districts':
                  _listDistricts();
                  break;
                case 'debug_sample':
                  _addSampleData();
                  break;
                case 'refresh':
                  _loadHospitals();
                  _loadRegions();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bölge filtresi
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRegion,
                hint: const Text('Tüm Bölgeler'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tüm Bölgeler'),
                  ),
                  ...regions.map((region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  )),
                ],
                onChanged: (String? newValue) {
                  debugPrint('🔍 Bölge seçimi değişti: $selectedRegion -> $newValue');
                  setState(() {
                    selectedRegion = newValue;
                  });
                  _loadHospitals();
                },
              ),
            ),
          ),

          // Hastane sayısı bilgisi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  selectedRegion == null 
                    ? '${hospitals.length} hastane bulundu (Tüm bölgeler)'
                    : '${hospitals.length} hastane bulundu ($selectedRegion)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Hastane listesi
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hospitals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_hospital_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedRegion == null 
                                ? 'Henüz hastane kaydı yok'
                                : '$selectedRegion bölgesinde hastane bulunamadı',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedRegion == null
                                ? 'Sağ üstteki + butonuna basarak\nörnek hastane verilerini ekleyebilirsiniz'
                                : 'Bu bölgede henüz kayıtlı hastane yok.\nFarklı bir bölge seçin veya yeni hastane ekleyin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = hospitals[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hastane adı ve bölge
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: const Icon(
                                          Icons.local_hospital,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hospital['hospitalName'] ?? 'Hastane Adı',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  hospital['region'] ?? 'Bölge',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // İletişim bilgileri
                                  if (hospital['contactPerson'] != null && hospital['contactPerson'].isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          hospital['contactPerson'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 4),

                                  if (hospital['phoneNumber'] != null && hospital['phoneNumber'].isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          hospital['phoneNumber'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 4),

                                  if (hospital['email'] != null && hospital['email'].isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hospital['email'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  if (hospital['address'] != null && hospital['address'].isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_city,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hospital['address'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 12),

                                  // Harita açma butonu
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _openMaps(hospital),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
                                        foregroundColor: const Color(0xFFE53935),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.map, size: 18),
                                      label: const Text(
                                        'Haritada Göster',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
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
          User? user = FirebaseAuth.instance.currentUser;
          if (user?.isAnonymous == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hastane eklemek için giriş yapmanız gerekiyor'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHospitalScreen()),
          );
          
          // Eğer yeni hastane eklendiyse sayfayı yenile
          if (result == true) {
            _loadHospitals();
            _loadRegions();
          }
        },
        backgroundColor: () {
          User? user = FirebaseAuth.instance.currentUser;
          return (user?.isAnonymous == true) ? Colors.grey : const Color(0xFFE53935);
        }(),
        foregroundColor: Colors.white,
        icon: Icon(
          Icons.add,
          color: () {
            User? user = FirebaseAuth.instance.currentUser;
            return (user?.isAnonymous == true) ? Colors.grey.shade400 : Colors.white;
          }(),
        ),
        label: Text(
          'Yeni Hastane',
          style: TextStyle(
            color: () {
              User? user = FirebaseAuth.instance.currentUser;
              return (user?.isAnonymous == true) ? Colors.grey.shade400 : Colors.white;
            }(),
          ),
        ),
      ),
    );
  }
}