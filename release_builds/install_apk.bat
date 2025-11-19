@echo off
echo ====================================
echo  🩸 Kan Başı Uygulaması Android APK
echo  📱 Kurulum Yardımcısı v1.0.0
echo ====================================
echo.

echo 📋 Kurulum öncesi kontroller...
echo.

REM Android cihaz bağlı mı kontrol et
adb devices > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ADB bulunamadı. Android Studio SDK Tools gerekli.
    echo 💡 Android Studio kurduktan sonra tekrar deneyin.
    pause
    exit /b 1
)

echo 🔍 Bağlı cihazları kontrol ediliyor...
adb devices
echo.

echo 📦 Kurulabilir APK dosyaları:
dir /b *.apk 2>nul
if %errorlevel% neq 0 (
    echo ❌ APK dosyası bulunamadı!
    echo 💡 APK dosyasının bu klasörde olduğundan emin olun.
    pause
    exit /b 1
)
echo.

set /p apk_file="📝 Kurmak istediğiniz APK dosya adını girin (örn: KanBasi_v1.0.0_20251105.apk): "

if not exist "%apk_file%" (
    echo ❌ APK dosyası bulunamadı: %apk_file%
    pause
    exit /b 1
)

echo.
echo 🚀 APK kurulumu başlatılıyor...
echo 📱 Cihazınızda kurulum onayını verin...
echo.

adb install -r "%apk_file%"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Kurulum başarılı!
    echo 🎉 Kan Başı uygulaması cihazınıza kuruldu.
    echo.
    echo 📋 Sonraki adımlar:
    echo 1. Uygulamayı açın
    echo 2. Gerekli izinleri verin (Konum, Kamera, Telefon)
    echo 3. Kayıt olun veya giriş yapın
    echo 4. Kan grubu bilginizi girin
    echo.
    echo 💡 Uygulama kullanım kılavuzu: KULLANIM_KILAVUZU.md
) else (
    echo.
    echo ❌ Kurulum başarısız!
    echo 🔧 Olası çözümler:
    echo 1. USB Debugging açık olduğundan emin olun
    echo 2. Bilinmeyen kaynaklardan kuruluma izin verin
    echo 3. Cihazda yeterli depolama alanı olduğundan emin olun
    echo 4. Eski sürümü varsa önce kaldırın
)

echo.
pause