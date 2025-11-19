// Flutter Performance Optimization Guide
// Uygulamanın çalışma hızını artırmak için öneriler

import 'package:flutter/material.dart';

/// PERFORMANS OPTİMİZASYON REHBERİ
class PerformanceOptimizations {
  
  // =============================================
  // 1. WIDGET OPTİMİZASYONLARI
  // =============================================
  
  /// const constructor kullanımı - GÇ yapı widgetları immutable yap
  static Widget goodExample() {
    return const Column(
      children: [
        Text('Sabit metin'), // const kullanımı
        Icon(Icons.star),    // const kullanımı  
      ],
    );
  }
  
  /// Builder pattern kullanımı - Sadece değişen kısımları rebuild et
  static Widget optimizedBuilder(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ValueNotifier(false),
      builder: (context, value, child) {
        return Column(
          children: [
            child!, // Değişmeyen kısım
            if (value) const Text('Dinamik içerik'),
          ],
        );
      },
      child: const Text('Sabit kısım'), // Sadece bir kez build edilir
    );
  }
  
  // =============================================
  // 2. LİSTE OPTİMİZASYONLARI
  // =============================================
  
  /// ListView.builder kullanımı - Sadece görünen itemları build et
  static Widget optimizedList(List<String> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          key: ValueKey(items[index]), // Key kullanımı
          title: Text(items[index]),
        );
      },
    );
  }
  
  /// Slivers kullanımı - Daha performanslı scroll
  static Widget optimizedSliverList(List<String> items) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              title: Text(items[index]),
            ),
            childCount: items.length,
          ),
        ),
      ],
    );
  }
  
  // =============================================
  // 3. ASYNC OPTİMİZASYONLARI
  // =============================================
  
  /// Future.wait kullanımı - Paralel işlemler
  static Future<Map<String, dynamic>> parallelDataLoading() async {
    final results = await Future.wait([
      loadUserData(),
      loadHospitalData(),
      loadBloodRequests(),
    ]);
    
    return {
      'users': results[0],
      'hospitals': results[1], 
      'requests': results[2],
    };
  }
  
  static Future<List<dynamic>> loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
  
  static Future<List<dynamic>> loadHospitalData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }
  
  static Future<List<dynamic>> loadBloodRequests() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }
  
  // =============================================
  // 4. MEMORY OPTİMİZASYONLARI
  // =============================================
  
  /// Dispose pattern örneği - Memory leaklerini önle
  static String getDisposePattern() {
    return '''
    class OptimizedScreen extends StatefulWidget {
      @override
      State<OptimizedScreen> createState() => _OptimizedScreenState();
    }
    
    class _OptimizedScreenState extends State<OptimizedScreen> {
      late final TextEditingController _controller;
      late final ScrollController _scrollController;
      
      @override
      void initState() {
        super.initState();
        _controller = TextEditingController();
        _scrollController = ScrollController();
      }
      
      @override
      void dispose() {
        _controller.dispose();     // Memory leak önle
        _scrollController.dispose(); // Memory leak önle
        super.dispose();
      }
      
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: ListView(
            controller: _scrollController,
            children: [
              TextField(controller: _controller),
            ],
          ),
        );
      }
    }
    ''';
  }
  
  // =============================================
  // 5. IMAGE OPTİMİZASYONLARI
  // =============================================
  
  /// Optimized image loading
  static Widget optimizedImage(String url) {
    return Image.network(
      url,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
      cacheWidth: 300, // Bellek kullanımını sınırla
      cacheHeight: 300,
    );
  }
  
  // =============================================
  // 5. STATE MANAGEMENT OPTİMİZASYONLARI
  // =============================================
  
  /// setState yerine ValueNotifier kullanım örneği
  static String getValueNotifierPattern() {
    return '''
    class OptimizedCounter extends StatelessWidget {
      final ValueNotifier<int> counter = ValueNotifier(0);
      
      @override
      Widget build(BuildContext context) {
        return ValueListenableBuilder<int>(
          valueListenable: counter,
          builder: (context, value, child) {
            return Text('\$value'); // Sadece bu widget rebuild olur
          },
        );
      }
    }
    ''';
  }
}

/// PERFORMANS METRIKLERI
class PerformanceMetrics {
  
  /// Build time ölçümü
  static void measureBuildTime(String widgetName, VoidCallback buildFunction) {
    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();
    debugPrint('🕐 $widgetName build time: ${stopwatch.elapsedMilliseconds}ms');
  }
  
  /// Memory usage tracking
  static void trackMemoryUsage() {
    // Development modunda memory kullanımını izle
    assert(() {
      debugPrint('🧠 Memory tracking aktif');
      return true;
    }());
  }
}

/// APP-SPESİFİK OPTİMİZASYONLAR
class BloodAppOptimizations {
  
  /// Kan talepleri için optimize loading
  static Future<List<Map<String, dynamic>>> optimizedBloodRequestLoading() async {
    // Sayfalama ile yükle
    const int pageSize = 20;
    const int limit = pageSize;
    
    // Sadece gerekli alanları al
    final data = await Future.delayed(
      const Duration(milliseconds: 300),
      () => List.generate(limit, (index) => {
        'id': 'req_$index',
        'bloodType': 'A+',
        'urgency': 'Normal',
        'timestamp': DateTime.now(),
      }),
    );
    
    return data;
  }
  
  /// Hastane listesi cache
  static final Map<String, List<Map<String, String>>> _hospitalCache = {};
  
  static Future<List<Map<String, String>>> getCachedHospitals(String city) async {
    if (_hospitalCache.containsKey(city)) {
      return _hospitalCache[city]!;
    }
    
    // Veriyi yükle ve cache'le
    final hospitals = await loadHospitalsFromServer(city);
    _hospitalCache[city] = hospitals;
    return hospitals;
  }
  
  static Future<List<Map<String, String>>> loadHospitalsFromServer(String city) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}