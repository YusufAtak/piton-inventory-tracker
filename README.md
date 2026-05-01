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

### 🧪 Test Accounts
To quickly explore the role-based features of the application, you can use the following pre-configured test accounts:

**Admin Account:**
> **Email:** `admin@piton.com`
> **Password:** `piton2026`

**Personnel Account:**
> **Email:** `personnel@test.com`
> **Password:** `123456`


## 📸 Screenshots

| Login | Personnel Dashboard | Admin Dashboard |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/d55e3c53-e510-489e-8dce-7ec0d8010d5a" width="250"/> | <img src="https://github.com/user-attachments/assets/20d667d6-4667-459a-8fad-628c82ea5420" width="250"/> | <img src="https://github.com/user-attachments/assets/d9400f9d-7e9c-4339-ab0e-9629f3f4c0cb" width="250"/> |
## 📖 Usage Guide

**1. Submitting a Maintenance Report (Personnel Role)**
Field personnel use this panel to report the condition of equipment.
- Enter the device name and select its current status (*Working, Broken, or Missing*).
- **Smart Validation:** If the status is marked as **"Broken"**, the application automatically prompts the user to take a photograph of the equipment. The report cannot be submitted without this visual evidence.
- Add additional notes and click submit.
<br>
<img width="1000" height="600" alt="personnel_dashboard_eng" src="https://github.com/user-attachments/assets/5b66c9f6-4205-4aac-b9bb-776e8b82808f" />

**2. Monitoring Reports (Admin Role)**
Administrators have access to a real-time feed of all submitted reports.
- **Live Sync:** Reports appear instantly on the dashboard without needing to refresh the page.
- **Details:** Each report card displays the device name, status, detailed notes, submission timestamp, and the email of the personnel who submitted it.
- **Image Viewing:** If a report includes a photograph (e.g., a broken device), an image icon appears on the right side of the card. Tapping it will open the image.
<br>
<img width="1000" height="691" alt="admin_dashboard_eng" src="https://github.com/user-attachments/assets/94005003-72d2-472b-bd06-d5410a6e2559" />


**3. User Management & Creation (Admin Role)**
Admins can scale the system by adding new team members directly from the app.
- Click the **Add User (+)** icon in the top right corner of the Admin Dashboard.
- Enter the new user's email address and a secure password.
- Assign a role: Select either **Admin** or **Personnel** from the dropdown menu.
- Click 'Save' to instantly register the user in Firebase Authentication and assign their role in Firestore.
<br>
<img width="500" height="426" alt="add_user_eng" src="https://github.com/user-attachments/assets/83533682-0d64-4d21-a55c-cfa449ef080c" />


**4. Real-time Language Switch**
You can instantly toggle the application language between English and Turkish by tapping the language button (**TR / EN**) located at the top right corner of any screen. The state is preserved during the transition.


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

### 🧪 Test İçin Hazır Hesaplar
Uygulamanın rol tabanlı erişim kontrolü (RBAC) özelliklerini, Admin panelini ve Personel raporlama akışını hızlıca test edebilmeniz için aşağıdaki hesaplar veritabanında önceden yapılandırılmıştır:

**Admin (Yönetici) Hesabı:**
> **E-posta:** `admin@piton.com`
> **Şifre:** `piton2026`

**Personel Hesabı:**
> **E-posta:** `personnel@test.com`
> **Şifre:** `123456`

### 🚀 Kurulum ve Çalıştırma

> **Firebase Kurulumu Hakkında Not:** Bu teknik değerlendirme sürecinin hızlıca ilerleyebilmesi adına Firebase yapılandırma dosyası (`google-services.json`) projeye bilerek dahil edilmiştir. Proje "tak-çalıştır" mantığındadır; uygulamayı yerelde (lokalde) ayağa kaldırmak için **ekstra hiçbir Firebase kurulumuna gerek yoktur.**

Projeyi bilgisayarınızda çalıştırmak için terminalinizde sırasıyla aşağıdaki komutları çalıştırmanız yeterlidir:

```bash
git clone https://github.com/YusufAtak/piton-inventory-tracker.git
cd piton-inventory-tracker
flutter pub get
flutter run
```
### 📖 Kullanım Kılavuzu (Usage)

**1. Bakım Raporu Oluşturma (Personel Rolü)**
Saha personelleri, cihazların son durumlarını bildirmek için bu ekranı kullanır.
- Cihaz adı girilir ve durumu (*Çalışıyor, Arızalı veya Eksik*) seçilir.
- **Akıllı Doğrulama (Smart Validation):** Eğer cihaz durumu **"Arızalı"** olarak seçilirse, sistem otomatik olarak kamerayı açar veya galeriye yönlendirir. Arızalı cihazlar için fotoğraf eklemek zorunludur.
- Varsa ekstra notlar eklenir ve rapor sisteme gönderilir.
<br>
<img width="1000" height="662" alt="personel_panel_tr" src="https://github.com/user-attachments/assets/068048ce-62fa-401e-aec0-b4fe7c87ab81" />


**2. Raporların İzlenmesi (Admin Rolü)**
Yöneticiler, sahadan gelen tüm bildirimleri tek bir ekrandan canlı olarak takip eder.
- **Canlı Akış:** Yeni gönderilen bir rapor, sayfayı yenilemeye gerek kalmadan anında listeye düşer.
- **Detaylar:** Rapor kartlarında; cihaz durumu, personelin notu, işlemi yapan personelin e-posta adresi ve tam tarih/saat bilgisi yer alır.
- **Görsel İnceleme:** Raporla birlikte gönderilen bir fotoğraf varsa, kartın sağındaki resim ikonuna tıklanarak arıza fotoğrafı görüntülenebilir.
<br>
<img width="1000" height="687" alt="admin_tr" src="https://github.com/user-attachments/assets/65965717-4b7b-4c26-849e-d0069558a780" />


**3. Yeni Kullanıcı Ekleme Süreci (Admin Rolü)**
Sisteme yeni personeller veya yöneticiler dahil etmek Admin yetkisindedir.
- Admin panelinin sağ üst köşesindeki **Kullanıcı Ekle (+)** ikonuna tıklanır.
- Açılan pencerede yeni kullanıcının e-posta adresi ve şifresi belirlenir.
- **Yetkilendirme:** Açılır menüden kullanıcının rolü (**Admin** veya **Personel**) seçilir ve kaydedilir. Bu işlem hem Firebase Auth üzerinde kullanıcıyı oluşturur hem de Firestore'a rolünü işler.
<br>
<img width="500" height="450" alt="kullanıcı_ekle_tr" src="https://github.com/user-attachments/assets/1ac13d84-3c66-4547-a860-cd378f061b44" />

**4. Anlık Dil Değişimi**
Uygulamanın dilini İngilizce ve Türkçe arasında anında değiştirmek için herhangi bir ekranın sağ üst köşesinde bulunan dil butonuna (**TR / EN**) tıklayabilirsiniz. Dil değişimi sırasında sayfadaki verileriniz (state) kaybolmaz.


***
*Developed by Yusuf Atak - 2026*
