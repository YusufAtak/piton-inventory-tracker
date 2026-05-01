# 🛠️ Piton Maintenance Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

A comprehensive, role-based maintenance and inventory tracking mobile application. Built as a technical assessment for **Piton Technology**. 

This application provides a seamless way for field personnel to report equipment statuses and for administrators to manage users and monitor reports in real-time.

## ✨ Key Features & Technical Highlights

- **Role-Based Access Control (RBAC):** Secure routing for `Admin` and `Personnel` with Firebase Authentication.
- **Real-Time Database:** Live synchronization of maintenance reports using **Cloud Firestore**.
- **Full i18n Localization:** Dynamic language switching (English/Turkish) without losing application state, powered by `easy_localization`.
- **Media Uploads:** Integrated camera features via `image_picker` and cloud storage via **Firebase Storage** (Mandatory photo rule for 'Broken' devices).
- **Advanced UX/UI Handling:** 
  - Custom form validation and focus nodes.
  - 100% physical and virtual keyboard support.
  - Proper navigation stack management to prevent unauthorized back-routing.

## 🔐 Evaluation Credentials

Reviewers can use the following pre-configured Admin account to evaluate the dashboard and user management features:

> **Email:** `admin@piton.com`
> **Password:** `piton2026`

## 📸 Screenshots

| Login | Personnel Dashboard | Admin Dashboard |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/d55e3c53-e510-489e-8dce-7ec0d8010d5a" width="250"/> | <img src="https://github.com/user-attachments/assets/20d667d6-4667-459a-8fad-628c82ea5420" width="250"/> | <img src="https://github.com/user-attachments/assets/d9400f9d-7e9c-4339-ab0e-9629f3f4c0cb" width="250"/> |

## 💻 Tech Stack
- **Framework:** Flutter
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State & Routing:** Standard Flutter SDK
- **Localization:** easy_localization

# 🚀 Installation & Setup
> **Note on Firebase Setup:** For the purpose of this technical evaluation, the Firebase configuration file (`google-services.json`) has been intentionally included in the repository. The project is plug-and-play; **no additional Firebase setup is required** to run the application locally.

```bash
git clone https://github.com/YusufAtak/piton-inventory-tracker.git
cd piton-inventory-tracker
flutter pub get
flutter run
```
---

<br>

<br>

<br>

# 🇹🇷 Türkçe Açıklama (TR)

**Piton Teknoloji** teknik değerlendirme süreci için özel olarak tasarlanmış ve geliştirilmiş, rol tabanlı bir bakım ve envanter takip mobil uygulamasıdır. 

Bu proje, saha personelinin cihaz durumlarını anlık olarak raporlamasını sağlarken, yöneticilerin (Admin) bu raporları canlı olarak takip etmesine ve yeni sistem kullanıcıları oluşturmasına olanak tanıyan uçtan uca bir mimari sunar.

### ✨ Öne Çıkan Özellikler ve Teknik Detaylar

- **Gelişmiş Rol Yönetimi (RBAC):** `Firebase Authentication` ve `Firestore` entegrasyonu ile kullanıcılar giriş yaptıkları anda yetkilerine (Admin veya Personel) göre güvenli bir şekilde ilgili panellere yönlendirilir.
- **Canlı Veri Senkronizasyonu (Real-time):** Raporlamalar **Cloud Firestore** üzerinden anlık dinlenir (`StreamBuilder` mimarisi). Sayfayı yenilemeye gerek kalmadan yeni raporlar anında Admin paneline yansır.
- **Tam Kapsamlı Çoklu Dil (i18n):** `easy_localization` paketi kullanılarak uygulamanın tamamına İngilizce ve Türkçe dil desteği eklenmiştir. Dil değişimi, uygulamanın durumunu (state) bozmadan anında gerçekleşir.
- **Dinamik Medya Yönetimi:** `image_picker` ile cihaz kamerası entegrasyonu sağlanmış, cihaz durumu "Arızalı" seçildiğinde **Firebase Storage**'a fotoğraf yükleme işlemi zorunlu tutularak iş mantığı (business logic) güçlendirilmiştir.
- **Kullanıcı Deneyimi (UX) ve Navigasyon Güvenliği:** 
  - Sayfalar arası geçişlerde `pushAndRemoveUntil` kullanılarak, kullanıcının cihazın geri tuşuna basıp yetkisiz olduğu veya çıkış yaptığı sayfalara geri dönmesi engellenmiştir.

### 🧪 Test İçin Yönetici Hesabı
Uygulamanın Admin (Yönetici) panelini, rapor akışını ve kullanıcı ekleme özelliklerini test edebilmeniz için aşağıdaki hesap veritabanında önceden yapılandırılmıştır:

> **E-posta:** `admin@piton.com`
> **Şifre:** `piton2026`

### 🚀 Kurulum ve Çalıştırma

> **Firebase Kurulumu Hakkında Not:** Bu teknik değerlendirme sürecinin hızlıca ilerleyebilmesi adına Firebase yapılandırma dosyası (`google-services.json`) projeye bilerek dahil edilmiştir. Proje "tak-çalıştır" mantığındadır; uygulamayı yerelde (lokalde) ayağa kaldırmak için **ekstra hiçbir Firebase kurulumuna gerek yoktur.**

Projeyi bilgisayarınızda çalıştırmak için terminalinizde sırasıyla aşağıdaki komutları çalıştırmanız yeterlidir:

```bash
git clone https://github.com/YusufAtak/piton-inventory-tracker.git
cd piton-inventory-tracker
flutter pub get
flutter run
```

***
*Developed by Yusuf Atak - 2026*
