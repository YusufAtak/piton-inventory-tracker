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
- **Global State Management:** Dynamic Dark/Light theme toggling across all screens seamlessly managed using the **Provider** package.
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
- **Dynamic Selection:** Select the device from the real-time dropdown menu (populated directly from the Firestore Inventory collection).
- Select its current status (*Working, Broken, or Missing*).
- **Smart Validation:** If the status is marked as **"Broken"**, the application automatically prompts the user to take a photograph of the equipment. The report cannot be submitted without this visual evidence.
- Add additional notes and click submit.
<br>
<img width="1000" height="680" alt="image" src="https://github.com/user-attachments/assets/ac6436bd-ebee-4e58-884f-92e01dfdfa90" />
<img width="1000" height="613" alt="image" src="https://github.com/user-attachments/assets/2f0d1a5e-eabf-48c6-9b01-1b536b4cfc7f" />



**2. Monitoring Reports (Admin Role)**
Administrators have access to a real-time feed of all submitted reports.
- **Live Sync:** Reports appear instantly on the dashboard without needing to refresh the page.
- **Details:** Each report card displays the device name, status, detailed notes, submission timestamp, and the email of the personnel who submitted it.
- **Image Viewing:** If a report includes a photograph (e.g., a broken device), an image icon appears on the right side of the card. Tapping it will open the image.
<br>
<img width="1000" height="691" alt="admin_dashboard_eng" src="https://github.com/user-attachments/assets/94005003-72d2-472b-bd06-d5410a6e2559" />

**3. Dynamic Device Registration (Admin Role)**
Admins can directly expand the field inventory without altering the codebase.
- Click the **Add Device** icon in the top right corner of the Admin Dashboard.
- Enter the Device Name, Device Type (e.g., HMI Panel, Barcode Printer), and Serial Number.
- Click 'Save'. This instantly adds the hardware to Firestore, making it immediately available for field personnel to select and report on.
<br>
<img width="486" height="461" alt="add_device_eng" src="https://github.com/user-attachments/assets/36f1a1c5-5b82-40a2-8f47-d9d6447aae35" />


**4. User Management & Creation (Admin Role)**
Admins can scale the system by adding new team members directly from the app.
- Click the **Add User (+)** icon in the top right corner of the Admin Dashboard.
- Enter the new user's email address and a secure password.
- Assign a role: Select either **Admin** or **Personnel** from the dropdown menu.
- Click 'Save' to instantly register the user in Firebase Authentication and assign their role in Firestore.
<br>
<img width="500" height="426" alt="add_user_eng" src="https://github.com/user-attachments/assets/83533682-0d64-4d21-a55c-cfa449ef080c" />


**5. Real-time Language Switch**
You can instantly toggle the application language between English and Turkish by tapping the language button (**TR / EN**) located at the top right corner of any screen. The state is preserved during the transition.

**6. Dynamic Theming (Dark/Light Mode)**
You can instantly toggle between light and dark modes by clicking the **Moon/Sun** icon located in the app bar. Thanks to the **Provider** architecture, your theme preference is preserved and applied globally across all screens (Login, Admin, and Personnel).


## 💻 Tech Stack
- **Framework:** Flutter
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State & Routing:** Provider
- **Localization:** easy_localization

# 🚀 Installation & Setup
> **Note on Firebase Setup:**  In a real-world production environment, the `google-services.json` file is strictly excluded from public repositories via `.gitignore`. However, it has been temporarily included in this repository exclusively to facilitate a rapid, plug-and-play evaluation process for the technical team.

> *To review the Firestore architecture and App Distribution history as requested, a "Viewer" invitation has been sent to the assessment team's email address.*

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
- **Global State Management (Durum Yönetimi):** **Provider** paketi kullanılarak uygulamanın tamamına dinamik Karanlık/Aydınlık (Dark/Light) tema desteği entegre edilmiştir.
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

> **Firebase Kurulumu Hakkında Not:** Gerçek dünya (Production) senaryolarında `google-services.json` dosyası `.gitignore` kullanılarak public depolardan kesinlikle gizlenir. Ancak teknik ekibin test ve değerlendirme sürecini hızlandırmak (tak-çalıştır deneyimi sunmak) amacıyla bu dosya geçici olarak projede bırakılmıştır.

> *İstenen Firestore veri mimarisi ve App Distribution sürüm geçmişinin incelenebilmesi adına, değerlendirme ekibinin e-posta adresine Firebase üzerinden "Görüntüleyici" (Viewer) daveti gönderilmiştir.*

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
- **Canlı Seçim:** İşlem yapılacak cihaz, doğrudan Firestore envanterinden beslenen dinamik açılır menüden (Dropdown) seçilir.
- Cihazın durumu (*Çalışıyor, Arızalı veya Eksik*) seçilir.
- **Akıllı Doğrulama (Smart Validation):** Eğer cihaz durumu **"Arızalı"** olarak seçilirse, sistem otomatik olarak kamerayı açar veya galeriye yönlendirir. Arızalı cihazlar için fotoğraf eklemek zorunludur.
- Varsa ekstra notlar eklenir ve rapor sisteme gönderilir.
<br>
<img width="1000" height="600" alt="personel_tr" src="https://github.com/user-attachments/assets/e18abe46-fe4f-4973-a71b-1765e0a30f37" />
<img width="1000" height="657" alt="personel2_tr" src="https://github.com/user-attachments/assets/587367a9-7099-4ac1-8212-f4bef68df6d8" />

**2. Raporların İzlenmesi (Admin Rolü)**
Yöneticiler, sahadan gelen tüm bildirimleri tek bir ekrandan canlı olarak takip eder.
- **Canlı Akış:** Yeni gönderilen bir rapor, sayfayı yenilemeye gerek kalmadan anında listeye düşer.
- **Detaylar:** Rapor kartlarında; cihaz durumu, personelin notu, işlemi yapan personelin e-posta adresi ve tam tarih/saat bilgisi yer alır.
- **Görsel İnceleme:** Raporla birlikte gönderilen bir fotoğraf varsa, kartın sağındaki resim ikonuna tıklanarak arıza fotoğrafı görüntülenebilir.
<br>
<img width="1000" height="687" alt="admin_tr" src="https://github.com/user-attachments/assets/65965717-4b7b-4c26-849e-d0069558a780" />

**3. Yeni Cihaz Envanteri Ekleme (Admin Rolü)**
Yöneticiler, sahadaki cihaz envanterini koda müdahale etmeden dinamik olarak genişletebilir.
- Admin panelinin sağ üst köşesindeki **Cihaz Ekle** ikonuna tıklanır.
- Cihaz Adı, Cihaz Tipi (Örn: HMI Panel) ve Seri Numarası girilerek 'Kaydet' butonuna basılır.
- Yeni cihaz anında Firestore veritabanına eklenir ve saha personelinin seçimi için açılır menüde anında görünür hale gelir.
<br>
<img width="435" height="432" alt="cihaz_ekle_tr" src="https://github.com/user-attachments/assets/b7c0de91-85db-43a5-b1a2-c3ae280b1052" />

**4. Yeni Kullanıcı Ekleme Süreci (Admin Rolü)**
Sisteme yeni personeller veya yöneticiler dahil etmek Admin yetkisindedir.
- Admin panelinin sağ üst köşesindeki **Kullanıcı Ekle (+)** ikonuna tıklanır.
- Açılan pencerede yeni kullanıcının e-posta adresi ve şifresi belirlenir.
- **Yetkilendirme:** Açılır menüden kullanıcının rolü (**Admin** veya **Personel**) seçilir ve kaydedilir. Bu işlem hem Firebase Auth üzerinde kullanıcıyı oluşturur hem de Firestore'a rolünü işler.
<br>
<img width="500" height="450" alt="kullanıcı_ekle_tr" src="https://github.com/user-attachments/assets/1ac13d84-3c66-4547-a860-cd378f061b44" />

**5. Anlık Dil Değişimi**
Uygulamanın dilini İngilizce ve Türkçe arasında anında değiştirmek için herhangi bir ekranın sağ üst köşesinde bulunan dil butonuna (**TR / EN**) tıklayabilirsiniz. Dil değişimi sırasında sayfadaki verileriniz (state) kaybolmaz.

**6. Dinamik Tema Yönetimi (Karanlık/Aydınlık Mod)**
Ekranların sağ üst köşesinde yer alan **Güneş/Ay** ikonuna tıklayarak uygulamanın temasını anında değiştirebilirsiniz. **Provider** mimarisi sayesinde, seçtiğiniz tema durumu (state) hafızada tutulur ve Login, Admin, Personel panellerinin tamamına eşzamanlı olarak yansır.


***
*Developed by Yusuf Atak - 2026*
