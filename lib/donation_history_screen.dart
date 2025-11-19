import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  User? currentUser;
  List<Map<String, dynamic>> donationHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.isAnonymous == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bağış geçmişi için giriş yapmanız gerekiyor'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
      return;
    }
    _loadDonationHistory();
  }

  Future<void> _loadDonationHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (currentUser != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('donation_history')
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('donationDate', descending: true)
            .get();

        List<Map<String, dynamic>> history = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          history.add(data);
        }

        setState(() {
          donationHistory = history;
        });

        debugPrint('✅ ${history.length} kan bağışı kaydı yüklendi');
      }
    } catch (e) {
      debugPrint('❌ Kan bağışı geçmişi yükleme hatası: $e');
      // Hata durumunda örnek veri göster
      _loadSampleData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadSampleData() {
    setState(() {
      donationHistory = [
        {
          'id': 'sample1',
          'hospitalName': 'Ankara Şehir Hastanesi',
          'donationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
          'bloodType': 'A+',
          'amount': '450 ml',
          'location': 'Çankaya, Ankara',
          'nextDonationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 0))),
          'status': 'Tamamlandı',
          'isSample': true,
        },
        {
          'id': 'sample2',
          'hospitalName': 'Hacettepe Üniversitesi Hastanesi',
          'donationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 180))),
          'bloodType': 'A+',
          'amount': '450 ml',
          'location': 'Sıhhiye, Ankara',
          'nextDonationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 90))),
          'status': 'Tamamlandı',
          'isSample': true,
        },
        {
          'id': 'sample3',
          'hospitalName': 'Gazi Üniversitesi Hastanesi',
          'donationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 365))),
          'bloodType': 'A+',
          'amount': '450 ml',
          'location': 'Beşevler, Ankara',
          'nextDonationDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 275))),
          'status': 'Tamamlandı',
          'isSample': true,
        },
      ];
    });
  }

  Future<void> _addNewDonation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDonationScreen()),
    );

    if (result == true) {
      _loadDonationHistory();
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Tarih belirtilmemiş';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Geçersiz tarih';
    }

    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getTimeSinceLastDonation() {
    if (donationHistory.isEmpty) return 'Henüz bağış kaydı yok';
    
    var lastDonation = donationHistory.first;
    dynamic timestamp = lastDonation['donationDate'];
    
    if (timestamp == null) return 'Tarih belirtilmemiş';
    
    DateTime lastDate;
    if (timestamp is Timestamp) {
      lastDate = timestamp.toDate();
    } else if (timestamp is DateTime) {
      lastDate = timestamp;
    } else {
      return 'Geçersiz tarih';
    }

    final now = DateTime.now();
    final difference = now.difference(lastDate);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else {
      return 'Bugün';
    }
  }

  bool _canDonateAgain() {
    if (donationHistory.isEmpty) return true;
    
    var lastDonation = donationHistory.first;
    dynamic timestamp = lastDonation['donationDate'];
    
    if (timestamp == null) return true;
    
    DateTime lastDate;
    if (timestamp is Timestamp) {
      lastDate = timestamp.toDate();
    } else if (timestamp is DateTime) {
      lastDate = timestamp;
    } else {
      return true;
    }

    final now = DateTime.now();
    final difference = now.difference(lastDate);
    
    // Erkekler için 90 gün (3 ay), kadınlar için 120 gün (4 ay) bekleme süresi
    return difference.inDays >= 90;
  }

  int _getDaysUntilNextDonation() {
    if (donationHistory.isEmpty) return 0;
    
    var lastDonation = donationHistory.first;
    dynamic timestamp = lastDonation['donationDate'];
    
    if (timestamp == null) return 0;
    
    DateTime lastDate;
    if (timestamp is Timestamp) {
      lastDate = timestamp.toDate();
    } else if (timestamp is DateTime) {
      lastDate = timestamp;
    } else {
      return 0;
    }

    final now = DateTime.now();
    final nextDonationDate = lastDate.add(const Duration(days: 90));
    final difference = nextDonationDate.difference(now);
    
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  @override
  Widget build(BuildContext context) {
    bool canDonate = _canDonateAgain();
    int daysUntilNext = _getDaysUntilNextDonation();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kan Bağışı Geçmişi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDonationHistory,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Özet kartı
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Kan Bağışı Özeti',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${donationHistory.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Toplam Bağış',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTimeSinceLastDonation(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Son Bağış',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  canDonate ? Icons.check_circle : Icons.schedule,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  canDonate
                                      ? 'Yeni bağış yapabilirsiniz!'
                                      : 'Sonraki bağış: $daysUntilNext gün sonra',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Liste başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bağış Geçmişi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (donationHistory.any((d) => d['isSample'] == true))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: const Text(
                              'Örnek Veri',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bağış listesi
                    if (donationHistory.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.bloodtype_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kan bağışı kaydınız yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'İlk kan bağışınızı kaydetmek için\naşağıdaki butonu kullanın',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...donationHistory.map((donation) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hastane ve tarih
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade500,
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
                                          donation['hospitalName'] ?? 'Hastane adı belirtilmemiş',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          donation['location'] ?? 'Konum belirtilmemiş',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatDate(donation['donationDate']),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          donation['status'] ?? 'Durum belirtilmemiş',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Kan grubu ve miktar
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bloodtype, color: Colors.red.shade600, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          donation['bloodType'] ?? 'Bilinmiyor',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.water_drop, color: Colors.blue.shade600, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          donation['amount'] ?? '450 ml',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
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

                    const SizedBox(height: 24),

                    // Bilgilendirme
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Kan Bağışı Bilgileri',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '• Erkekler 3 ayda bir, kadınlar 4 ayda bir kan bağışı yapabilir\n'
                            '• Her kan bağışında yaklaşık 450 ml kan alınır\n'
                            '• Bir ünite kan 3 kişinin hayatını kurtarabilir\n'
                            '• Kan bağışı sonrası 24 saat dinlenme önerilir\n'
                            '• Bağış öncesi mutlaka doktor kontrolünden geçiniz',
                            style: TextStyle(
                              fontSize: 14,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewDonation,
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Bağış Ekle'),
      ),
    );
  }
}

// Yeni bağış ekleme sayfası
class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedBloodType;
  bool _isLoading = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _hospitalController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveDonation() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('donation_history').add({
            'userId': currentUser.uid,
            'userEmail': currentUser.email,
            'hospitalName': _hospitalController.text.trim(),
            'location': _locationController.text.trim(),
            'donationDate': Timestamp.fromDate(_selectedDate!),
            'bloodType': _selectedBloodType!,
            'amount': '450 ml',
            'status': 'Tamamlandı',
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Kan bağışı kaydınız başarıyla eklendi!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Kayıt ekleme hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
        title: const Text('Yeni Bağış Ekle'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bilgilendirme
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Geçmiş kan bağışı kaydınızı ekleyin',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hastane adı
                TextFormField(
                  controller: _hospitalController,
                  decoration: InputDecoration(
                    labelText: 'Hastane Adı *',
                    hintText: 'Ankara Şehir Hastanesi',
                    prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hastane adı gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Konum
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Konum *',
                    hintText: 'Çankaya, Ankara',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Konum gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Kan grubu
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Kan Grubu *',
                    hintText: 'Kan grubu seçiniz',
                    prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _bloodTypes.map((String bloodType) {
                    return DropdownMenuItem<String>(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kan grubu seçimi gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tarih seçimi
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFE53935)),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Bağış Tarihi Seçiniz *'
                              : 'Bağış Tarihi: ${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null ? Colors.grey.shade600 : Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Kaydet butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Bağış Kaydını Ekle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // İptal butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53935), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}