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

```bash
git clone https://github.com/YusufAtak/piton-inventory-tracker.git
cd piton-inventory-tracker
flutter pub get
flutter run
```
---

<br>

# 🇹🇷 Türkçe Açıklama (TR)

Piton Teknoloji teknik değerlendirme süreci için geliştirilmiş, rol tabanlı bakım ve envanter takip uygulamasıdır.

### Öne Çıkan Geliştirmeler:
- **Rol Yönetimi:** Firebase Auth ile Admin ve Personel olarak iki farklı yetki seviyesi oluşturulmuştur.
- **Canlı Veritabanı:** Firestore kullanılarak raporların anlık olarak Admin paneline düşmesi sağlanmıştır.
- **Çoklu Dil (i18n):** `easy_localization` paketi ile anlık TR/EN dil değişimi entegre edilmiştir.
- **Dosya Yükleme:** Arızalı cihazlar için Firebase Storage destekli zorunlu fotoğraf çekme özelliği eklenmiştir.

### 🧪 Test Hesabı
Yönetici (Admin) özelliklerini test etmek için aşağıdaki bilgileri kullanabilirsiniz:
* **E-posta:** `admin@piton.com`
* **Şifre:** `piton2026`

***
*Developed by Yusuf Atak - 2026*
