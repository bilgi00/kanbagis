import 'package:flutter/material.dart';

// Bu dosya logo oluşturmak için kullanılır
// flutter run generator/create_logo.dart komutu ile çalıştırın

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Logo widget'ını oluştur
  createLogoWidget();
  
  debugPrint('Logo widget oluşturuldu. Bu bir örnek dosyadır.');
  debugPrint('Gerçek PNG oluşturmak için web/mobile framework gereklidir.');
}

Widget createLogoWidget() {
  return RepaintBoundary(
    child: Container(
      width: 512,
      height: 512,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFF6B6B), // Açık kırmızı
            Color(0xFFDC143C), // Koyu kırmızı
          ],
        ),
        borderRadius: BorderRadius.circular(120),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kalp şekli
          const Icon(
            Icons.favorite,
            size: 240,
            color: Colors.white,
          ),
          // Damla efekti
          Positioned(
            top: 120,
            child: Container(
              width: 60,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          // Artı işareti
          Positioned(
            bottom: 80,
            right: 80,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: const Color(0xFFDC143C),
                  width: 8,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 80,
                color: Color(0xFFDC143C),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}