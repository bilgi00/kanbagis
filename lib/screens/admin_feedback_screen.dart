import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'Tümü',
    'Sorun Bildirimi',
    'Hata Raporu',
    'Güncelleme Talebi',
    'Özellik İsteği',
    'Genel Geri Bildirim',
    'Diğer',
  ];

  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Yeni':
        return Colors.blue;
      case 'İnceleniyor':
        return Colors.orange;
      case 'Çözüldü':
        return Colors.green;
      case 'Reddedildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Yüksek':
        return Colors.red;
      case 'Orta':
        return Colors.orange;
      case 'Düşük':
        return Colors.green;
      case 'Normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hata Raporu':
        return Icons.bug_report;
      case 'Sorun Bildirimi':
        return Icons.warning;
      case 'Güncelleme Talebi':
        return Icons.system_update;
      case 'Özellik İsteği':
        return Icons.lightbulb;
      case 'Genel Geri Bildirim':
        return Icons.comment;
      default:
        return Icons.help;
    }
  }

  Future<void> _updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'isResolved': newStatus == 'Çözüldü',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Durum $newStatus olarak güncellendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFeedbackDetails(Map<String, dynamic> feedback, String feedbackId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(feedback['category'] ?? ''),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feedback['title'] ?? 'Başlık Yok',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // İçerik
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kullanıcı Bilgileri
                        _buildDetailRow(
                          'Kullanıcı',
                          feedback['userDisplayName'] ?? 'Bilinmiyor',
                          Icons.person,
                        ),
                        _buildDetailRow(
                          'E-posta',
                          feedback['userEmail'] ?? 'Bilinmiyor',
                          Icons.email,
                        ),
                        _buildDetailRow(
                          'Kategori',
                          feedback['category'] ?? 'Bilinmiyor',
                          _getCategoryIcon(feedback['category'] ?? ''),
                        ),
                        _buildDetailRow(
                          'Öncelik',
                          feedback['priority'] ?? 'Normal',
                          Icons.priority_high,
                        ),
                        _buildDetailRow(
                          'Durum',
                          feedback['status'] ?? 'Yeni',
                          Icons.info,
                        ),
                        _buildDetailRow(
                          'Oluşturma Tarihi',
                          feedback['createdAt'] != null
                              ? DateFormat('dd.MM.yyyy HH:mm')
                                  .format(feedback['createdAt'].toDate())
                              : 'Bilinmiyor',
                          Icons.calendar_today,
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Açıklama
                        const Text(
                          'Açıklama:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            feedback['description'] ?? 'Açıklama yok',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Durum Değiştirme Butonları
                        const Text(
                          'Durum Güncelle:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Yeni', 'İnceleniyor', 'Çözüldü', 'Reddedildi']
                              .map((status) => ElevatedButton(
                                    onPressed: () {
                                      _updateFeedbackStatus(feedbackId, status);
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatusColor(status),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(status),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE53935)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
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
        title: const Text('Geri Bildirim Yönetimi'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Yeni'),
            Tab(text: 'İnceleniyor'),
            Tab(text: 'Çözüldü'),
            Tab(text: 'Reddedildi'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtreler
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                // Kategori Filtresi
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category, color: Color(0xFFE53935)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackList('Tümü'),
                _buildFeedbackList('Yeni'),
                _buildFeedbackList('İnceleniyor'),
                _buildFeedbackList('Çözüldü'),
                _buildFeedbackList('Reddedildi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery(statusFilter),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE53935),
            ),
          );
        }

        final feedbacks = snapshot.data?.docs ?? [];

        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  statusFilter == 'Tümü' 
                      ? 'Henüz geri bildirim yok'
                      : '$statusFilter durumunda geri bildirim yok',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final doc = feedbacks[index];
            final feedback = doc.data() as Map<String, dynamic>;
            final feedbackId = doc.id;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showFeedbackDetails(feedback, feedbackId),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık ve Durum
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(feedback['category'] ?? ''),
                            color: const Color(0xFFE53935),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feedback['title'] ?? 'Başlık Yok',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(feedback['status'] ?? 'Yeni'),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              feedback['status'] ?? 'Yeni',
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

                      // Açıklama
                      Text(
                        feedback['description'] ?? 'Açıklama yok',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Alt bilgiler
                      Row(
                        children: [
                          // Kullanıcı
                          Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            feedback['userDisplayName'] ?? 'Bilinmiyor',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Kategori
                          Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            feedback['category'] ?? 'Bilinmiyor',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Tarih
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            feedback['createdAt'] != null
                                ? DateFormat('dd.MM.yyyy HH:mm')
                                    .format(feedback['createdAt'].toDate())
                                : 'Bilinmiyor',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Öncelik
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(feedback['priority'] ?? 'Normal')
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getPriorityColor(feedback['priority'] ?? 'Normal'),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${feedback['priority'] ?? 'Normal'} Öncelik',
                              style: TextStyle(
                                color: _getPriorityColor(feedback['priority'] ?? 'Normal'),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildQuery(String statusFilter) {
    Query query = FirebaseFirestore.instance
        .collection('feedback')
        .orderBy('createdAt', descending: true);

    // Durum filtresi
    if (statusFilter != 'Tümü') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query.snapshots();
  }
}