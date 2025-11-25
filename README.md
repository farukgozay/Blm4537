PROJE DURUM ÖZETİ: ShotForge (BLM4537 iOS Mobil)
PROJE ADI: ShotForge (Basketbol Şut Analitik Stüdyosu) DERS: BLM4537 iOS ile Mobil Uygulama Geliştirme I TARİH: 25.11.2025

Bu doküman, projenin İlk Gösterim (18 Kasım / 25 Kasım) tarihine kadar gelinen teknik aşamayı özetlemektedir. Projenin mimarisi, ve numaralı dokümanlarda belirtilen Clean Architecture (Temiz Mimari) yaklaşımına uygun olarak domain/, data/ ve  presentation/ katmanlarına ayrılmıştır.





1. Veritabanının Hazırlanması ve Bağlantı
Veritabanı gereksinimleri (No Firebase) karşılanmıştır.

Veritabanı Tipi: SQLite (Relational Database - İlişkisel Veritabanı).


Arka Plan Bağlantısı: Veritabanı yönetim katmanı  Entity Framework Core kullanılarak hazırlanmıştır. shotforge.db dosyası, API sunucusu tarafında yerel olarak tutulmaktadır.

Veri Doldurma (Seeding): Uygulama ilk çalıştığında, istatistiklerin null gelmesini engellemek için mevcut oyunculara (LeBron James, Stephen Curry vb.) otomatik olarak rastgele şut verisi atanması sağlayan kod (seed logic) entegre edilmiştir. Bu sayede istatistikler her zaman dolu gelmektedir.

2. API'nin Hazırlanması ve Veri Akışı
API katmanı (.NET Web API) tamamen hazırlanmış olup, hem veri gönderimini hem de alımını göstermektedir.

API Teknolojisi: C# ile geliştirilmiş ASP.NET Core Web API.

Temel Uç Noktalar:

GET /players: Mobil uygulamadaki oyuncu listesini doldurmak için tüm oyuncu kartlarını çeker.


GET /players/{id}/details: Bir oyuncunun temel bilgilerini, eFG%, TS%, ve şutların koordinatlarını  içeren istatistik motoru çıktısını tek bir çağrıda döndürür.



POST /players: Mobil uygulama üzerinden yeni oyuncu kaydını (isim, takım vb.) yapar.


POST /shots/upload/{id}: CSV formatındaki ham şut verisini  alır ve backend'de işleyip veritabanına kaydeder.

DELETE /players/{id}: Seçilen oyuncuyu ve tüm şut verilerini siler.

Güvenlik: JWT (JSON Web Token) tabanlı kimlik doğrulama yapısı entegre edilmiştir. Sadece kayıtlı ve giriş yapmış kullanıcılar  oyuncu ekleme gibi yönetimsel işlemleri yapabilir.

3. Tasarımın Tamamen/Kısmen Tamamlanması 
Uygulama arayüzü (UI), akıcı ve mobil odaklı bir deneyim için  Flutter kullanılarak geliştirilmiştir.



Mimari ve Tema: Koyu (Dark Mode) bir tema üzerine  Neon vurgular (Mavi, Yeşil, Kırmızı) kullanılmıştır.


Şut Haritası (Görselleştirme): Şablon bir basketbol sahası görseli üzerine  koordinatları birebir hesaplanmış, neon efektli noktalar (İsabet: Yeşil, Kaçan: Kırmızı) bindirilmiştir. Bu, haritanın anlamsız bir kutu değil, gerçek bir görsel analiz aracı gibi durmasını sağlamaktadır.



Kıyaslama Ekranı: Oyuncuların istatistikleri (eFG%, TS%) yan yana kıyaslandığı, kazananın yeşil, kaybedenin kırmızı yandığı  çubuk bazlı karşılaştırma ekranı mevcuttur.



Navigasyon: Ana sayfa, Detay, Ekle ve Kıyasla ekranlarına erişim sağlayan  akıllı (floating) bir alt menü (bottom bar) kullanılmıştır.

Kullanıcı Deneyimi (UX): Oyuncu kartlarında basma hissi veren animasyonlar (AnimatedScale) ve gerekli yerlerde veri validasyonu (CSV dosyası yoksa uyarı verme) mevcuttur.
