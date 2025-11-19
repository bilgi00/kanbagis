import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withText;
  
  const AppLogo({
    super.key,
    this.size = 120,
    this.withText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [
                Color(0xFFFF6B6B), // Açık kırmızı
                Color(0xFFDC143C), // Koyu kırmızı
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Kalp şekli
              Icon(
                Icons.favorite,
                size: size * 0.5,
                color: Colors.white,
              ),
              // Damla efekti
              Positioned(
                top: size * 0.25,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size * 0.1),
                      topRight: Radius.circular(size * 0.1),
                      bottomLeft: Radius.circular(size * 0.1),
                      bottomRight: Radius.circular(size * 0.1),
                    ),
                  ),
                ),
              ),
              // Artı işareti
              Positioned(
                bottom: size * 0.15,
                right: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.125),
                    border: Border.all(
                      color: const Color(0xFFDC143C),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: size * 0.15,
                    color: const Color(0xFFDC143C),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (withText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'Bir Damla Kan',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFDC143C),
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'Hayat Kurtarır',
            style: TextStyle(
              fontSize: size * 0.1,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}