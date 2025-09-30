# 🎵 Strplay

YouTube videolarını reklamsız oynatmak ve indirmek için geliştirilmiş Flutter mobil uygulaması. SkipVids köprüsü kullanarak YouTube içeriklerine erişim sağlar.

## ✨ Özellikler

- 🔍 **YouTube Arama**: youtube_explode_dart ile gelişmiş arama
- 🎵 **Reklamsız Oynatma**: SkipVids köprüsü ile reklamsız müzik dinleme
- 📱 **Video İzleme**: WebView ile reklamsız video oynatma
- 💾 **MP3 İndirme**: Yerel depolamaya MP3 formatında indirme
- 🎨 **Modern UI**: Material Design 3 ile modern arayüz
- 📱 **Cross-Platform**: Android ve iOS desteği
- 🔄 **Arka Plan Oynatma**: Uygulama arka plandayken müzik çalma
- 📹 **Video Çekme**: Müzik çalarken video kaydetme
- 🌍 **4 Dil Desteği**: Türkçe, İngilizce, İspanyolca, Rusça

## 🛠️ Teknolojiler

- **Flutter**: 3.0+ (Cross-platform framework)
- **youtube_explode_dart**: YouTube API entegrasyonu
- **just_audio**: Ses oynatma
- **webview_flutter**: Video oynatma
- **dio**: Dosya indirme
- **permission_handler**: İzin yönetimi
- **html**: HTML parsing (SkipVids scraping)
- **camera**: Video kayıt
- **audio_service**: Arka plan ses yönetimi
- **flutter_localizations**: Çoklu dil desteği

## 📦 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Android Studio / Xcode
- Android SDK 21+ / iOS 12+

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/bersa2009/strplay.git
cd strplay
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

## 🎯 Kullanım

### Arama
- Ana ekrandaki arama çubuğuna şarkı, sanatçı veya albüm adı yazın
- Enter tuşuna basın veya arama butonuna tıklayın
- Sonuçlar kart formatında listelenecek

### Oynatma
- **Dinle**: Sadece ses oynatır (just_audio)
- **Video İzle**: WebView popup'ında reklamsız video oynatır
- **İndir**: MP3 formatında telefona indirir
- **Video Kaydet**: Müzik çalarken video kaydeder

### Kontroller
- Oynat/Duraklat butonları
- İlerleme çubuğu
- Süre gösterimi
- Durdur butonu

## 🔧 SkipVids Köprü Mekanizması

Uygulama, YouTube videolarını reklamsız oynatmak için SkipVids.com'u arka planda kullanır:

- **Arama**: YouTube'dan yapılır (youtube_explode_dart)
- **Audio Stream**: YouTube'dan alınır
- **Video Oynatma**: SkipVids proxy'si kullanılır
- **HTML Kazıma**: SkipVids'ten iframe URL'si alınır

### SkipVids Entegrasyonu
```dart
// SkipVids URL'si
https://skipvids.com/?v=VIDEO_ID

// HTML scraping ile iframe URL'si alınır
<iframe src="https://www.youtube.com/embed/VIDEO_ID?params"></iframe>
```

## 📱 Platform Desteği

### Android
- Minimum SDK: 21 (Android 5.0)
- İzinler: INTERNET, WRITE_EXTERNAL_STORAGE, READ_MEDIA_AUDIO, CAMERA
- Hedef SDK: 34

### iOS
- Minimum iOS: 12.0
- İzinler: NSAppTransportSecurity, UIBackgroundModes, NSCameraUsageDescription
- WebView desteği

## 🔒 İzinler

### Android
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.AUDIO_FOCUS" />
```

### iOS
```xml
<key>NSAppTransportSecurity</key>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
<key>NSCameraUsageDescription</key>
```

## 🌍 Çoklu Dil Desteği

- 🇹🇷 **Türkçe** (Varsayılan)
- 🇺🇸 **İngilizce**
- 🇪🇸 **İspanyolca**
- 🇷🇺 **Rusça**

Dil değiştirmek için sağ üstteki 🌐 ikonuna tıklayın.

## 🐛 Hata Ayıklama

### Yaygın Sorunlar

1. **Arama sonuçları gelmiyor**
   - İnternet bağlantısını kontrol edin
   - YouTube API hız sınırı kontrolü

2. **Ses oynatılmıyor**
   - Ses akışı formatını kontrol edin
   - just_audio konfigürasyonu

3. **Video açılmıyor**
   - SkipVids erişilebilirliğini kontrol edin
   - WebView konfigürasyonu

4. **İndirme çalışmıyor**
   - Depolama izinlerini kontrol edin
   - Dosya yolu erişimini kontrol edin

5. **Kamera çalışmıyor**
   - Kamera izinlerini kontrol edin
   - Kamera erişimini kontrol edin

### Hata Ayıklama Modu
```bash
flutter run --debug
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## ⚠️ Yasal Uyarı

- YouTube Hizmet Şartları'nı dikkate alın
- SkipVids proxy'si gri alan olabilir
- Telif hakkı ihlali yapmayın
- Sadece kişisel kullanım için tasarlanmıştır

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📞 İletişim

Sorularınız için issue açabilir veya iletişime geçebilirsiniz.

---

**Not**: Bu uygulama eğitim amaçlı geliştirilmiştir. Ticari kullanım için gerekli izinleri alın.