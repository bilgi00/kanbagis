# 🌐 Bir Damla Kan Web Deployment Rehberi

Bu rehber, Bir Damla Kan Flutter web uygulamasının production ortamına deployment'ı için gerekli adımları içerir.

## 📁 Web Build Dosyaları

Web uygulaması `build/web/` klasöründe hazır durumda:

```
build/web/
├── .htaccess          # Apache sunucu konfigürasyonu
├── index.html         # Ana HTML dosyası (SEO optimized)
├── manifest.json      # PWA manifest dosyası
├── robots.txt         # SEO robots dosyası
├── sitemap.xml        # SEO sitemap dosyası
├── sw.js             # Service Worker (PWA özellikleri)
├── flutter.js        # Flutter runtime
├── flutter_bootstrap.js
├── canvaskit/        # Flutter rendering engine
└── assets/           # Uygulama varlıkları
```

## 🚀 Deployment Seçenekleri

### 1. Apache Web Sunucusu

1. **Dosyaları yükleyin:**
   ```bash
   # build/web/ klasörünün içeriğini web sunucunuzun root dizinine kopyalayın
   cp -r build/web/* /var/www/html/
   ```

2. **Apache modüllerini etkinleştirin:**
   ```bash
   sudo a2enmod rewrite
   sudo a2enmod deflate
   sudo a2enmod expires
   sudo a2enmod headers
   sudo systemctl restart apache2
   ```

3. **.htaccess dosyası** zaten konfigüre edilmiş durumda.

### 2. Nginx Web Sunucusu

1. **Dosyaları yükleyin:**
   ```bash
   # build/web/ klasörünün içeriğini nginx dizinine kopyalayın
   cp -r build/web/* /var/www/kanbagisc.com/
   ```

2. **Nginx konfigürasyonunu güncelleyin:**
   ```bash
   # web/nginx.conf dosyasını /etc/nginx/sites-available/kanbagisc.com olarak kopyalayın
   sudo cp web/nginx.conf /etc/nginx/sites-available/kanbagisc.com
   sudo ln -s /etc/nginx/sites-available/kanbagisc.com /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### 3. Netlify (Kolay Deployment)

1. **Netlify Dashboard'a gidin**
2. **"New site from Git"** seçin
3. **Repository'yi bağlayın**
4. **Build settings:**
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`
5. **Deploy site** butonuna tıklayın

### 4. Vercel (Kolay Deployment)

1. **Vercel CLI'yi kurun:**
   ```bash
   npm i -g vercel
   ```

2. **Deployment:**
   ```bash
   cd build/web
   vercel --prod
   ```

### 5. Firebase Hosting

1. **Firebase CLI'yi kurun:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Firebase'e login olun:**
   ```bash
   firebase login
   ```

3. **Proje initialize edin:**
   ```bash
   firebase init hosting
   ```

4. **Deploy edin:**
   ```bash
   firebase deploy
   ```

## 🔧 Gerekli SSL Sertifikası

PWA özellikleri için HTTPS gereklidir. Ücretsiz SSL için:

### Let's Encrypt (Certbot)

```bash
# Ubuntu/Debian için
sudo apt install certbot python3-certbot-nginx

# SSL sertifikası al
sudo certbot --nginx -d kanbagisc.com -d www.kanbagisc.com

# Otomatik yenileme
sudo crontab -e
# Şu satırı ekleyin:
0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 SEO ve Performance

### ✅ Dahil Edilen Optimizasyonlar:

- **Meta tags** (Open Graph, Twitter Cards)
- **Structured data** ready
- **Robots.txt** ve **Sitemap.xml**
- **Gzip compression**
- **Browser caching**
- **PWA manifest**
- **Service Worker**
- **Loading animation**
- **Security headers**

### 🎯 Google Search Console

1. [Google Search Console](https://search.google.com/search-console)'a gidin
2. Site'ınızı ekleyin
3. `sitemap.xml`'i submit edin
4. Performance'ı izleyin

## 🔒 Güvenlik

### Dahil Edilen Güvenlik Önlemleri:

- **Content Security Policy (CSP)**
- **X-Frame-Options**
- **X-Content-Type-Options**
- **X-XSS-Protection**
- **Referrer Policy**
- **HTTPS redirect**
- **Secure headers**

## 📱 PWA Özellikleri

### ✅ Desteklenen Özellikler:

- **Offline çalışma** (Service Worker)
- **Ana ekrana ekleme**
- **Push notifications** ready
- **Background sync** ready
- **App shortcuts**
- **Responsive design**

## 🧪 Test Etme

### Deployment sonrası test edilmesi gerekenler:

1. **PWA test:**
   - Chrome DevTools > Lighthouse > PWA audit
   - Ana ekrana ekleme testi

2. **Performance test:**
   - [PageSpeed Insights](https://pagespeed.web.dev/)
   - [GTmetrix](https://gtmetrix.com/)

3. **SEO test:**
   - [Google Search Console](https://search.google.com/search-console)
   - Meta tags kontrolü

4. **Security test:**
   - [Mozilla Observatory](https://observatory.mozilla.org/)
   - SSL Labs test

## 🆘 Sorun Giderme

### Yaygın sorunlar ve çözümleri:

1. **404 hatası (client-side routing):**
   - `.htaccess` veya nginx konfigürasyonunu kontrol edin
   - Fallback routes'ların doğru olduğundan emin olun

2. **PWA yüklenmiyor:**
   - HTTPS kullandığınızdan emin olun
   - Service Worker'ın doğru yüklendiğini kontrol edin

3. **Firebase bağlantı sorunu:**
   - Firebase konfigürasyonunu kontrol edin
   - CORS ayarlarını doğrulayın

## 📞 Destek

Deployment sırasında sorun yaşarsanız:

- GitHub Issues: [Repository Link]
- Email: support@kanbagisc.com
- Documentation: [Docs Link]

---

**🩸 Bir Damla Kan - Hayat Kurtaran Platform**

Deployment başarılı olduğunda, binlerce kullanıcının kan bağışı sürecinde yardımcı olacak bu platformu kullanıma sunmuş olacaksınız! 🎉