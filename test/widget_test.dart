// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kan_bagisi_uygulamasi/main.dart';

void main() {
  testWidgets('Kayıt ekranı yükleniyor testi', (WidgetTester tester) async {
    // Uygulamamızı oluştur ve bir frame tetikle
    await tester.pumpWidget(const KanBasiApp());

    // "KAN BAŞI" yazısının ekranda olduğunu doğrula
    expect(find.text('KAN BAŞI'), findsOneWidget);
    
    // "Kayıt Ol" yazısının ekranda olduğunu doğrula
    expect(find.text('Kayıt Ol'), findsOneWidget);
    
    // "KAYIT OL" butonunun ekranda olduğunu doğrula
    expect(find.text('KAYIT OL'), findsOneWidget);
  });
}
