# Othix App

<img src="https://raw.githubusercontent.com/ikhsan3adi/backtix/main/assets/banner.png">

<a href="./mobile-app.md">
  <img alt="Translation" src="https://img.shields.io/badge/Bahasa_Indonesia-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.en.md">
  <img alt="Translation" src="https://img.shields.io/badge/English-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.zh-CN.md">
  <img alt="Translation" src="https://img.shields.io/badge/简体中文-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.ja.md">
  <img alt="Translation" src="https://img.shields.io/badge/日本語-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.ar.md">
  <img alt="Translation" src="https://img.shields.io/badge/Arabic_عربي-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.pt.md">
  <img alt="Translation" src="https://img.shields.io/badge/Português-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.es.md">
  <img alt="Translation" src="https://img.shields.io/badge/Español-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.fr.md">
  <img alt="Translation" src="https://img.shields.io/badge/Français-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.vi.md">
  <img alt="Translation" src="https://img.shields.io/badge/Tiếng_Việt-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>
<a href="./mobile-app.hi.md">
  <img alt="Translation" src="https://img.shields.io/badge/Hindi_हिंदी-blue?style=for-the-badge&logo=googletranslate&logoColor=blue&labelColor=white">
</a>

### Persyaratan Sistem

Pastikan sistem Anda memenuhi persyaratan berikut sebelum memulai instalasi:

- Flutter SDK v3.16 or higher

### Langkah-langkah Instalasi

1. Clone/extract Repository

2. Install dependencies:
```bash
flutter pub get
```
3. Jalankan `build_runner` untuk men-generate file `*.g.dart`

```bash
dart run build_runner build
```

#### Setup environment

1. Rename `.env.example` to `.env`

2. Sesuaikan `API_BASE_URL` di file `.env`

#### Midtrans client key

- Selesaikan langkah sebelumnya di [Back-end service - Setup midtrans server & client key](api-service.md#setup-midtrans-server--client-key)

- Salin **client key** ke file `.env`

```sh
# for debug / sandbox
MIDTRANS_CLIENT_KEY_SANDBOX=SB-Mid-client-xxxx
# for release / production
MIDTRANS_CLIENT_KEY=Mid-client-xxxx
```

#### Setup **Google sign in** client ID

- Selesaikan langkah sebelumnya di [Back-end service - Setup Google sign in server & client ID](api-service.md#setup-google-sign-in-server--client-id)

- Salin `Web Client ID` dan `Server Client ID` ke file `.env`

```sh
# frontend google signin / web client id
GOOGLE_CLIENT_ID=xxxx.apps.googleusercontent.com
# backend / server client id
GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com
```

- Salin `Web Client ID` ke `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <string name="default_web_client_id">YOUR_CLIENT_ID</string> 
</resources>
```

- **Android** client ID

    - Buka terminal, arahkan ke direktori project aplikasi
    - Lalu arahkan ke folder android

  ```bash
  cd <path-to-project>
  cd android
  ```

    - Jalankan perintah berikut

        - Untuk linux dan macos
      ```bash
      keytool -genkey -v -keystore <path-to-project>/android/app/androidkey.jks -keyalg RSA -keysize 2048 -validity 10000 -alias keyalias
  
      ```
        - Untuk windows
      ```powershell
      keytool -genkey -v -keystore <path-to-project>/android/app/androidkey.jks ^
      -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 ^
      -alias upload
      ```
        - :warning: Ganti `<path-to-project>` dengan path direktori projek aplikasi.
          Contoh:
      ```bash
      # linux
      ~/ngoding/PROJECTS/backtix/othtix_app/android/app/androidkey.jks
      # windows
      D:/ngoding/flutter/backtix-app/android/app/androidkey.jks
      ```
        - Anda akan diminta memasukkan password, contoh `backtix`

    - Buka file `android/app/build.gradle` lalu ubah bagian ini:
  ```gradle
  signingConfigs {
    debug {
        keyAlias 'keyalias'
        keyPassword <your-password> // sesuaikan dengan password dari langkah sebelumnya
        storeFile file('androidkey.jks')
        storePassword <your-password> // sesuaikan dengan password dari langkah sebelumnya
    }
  }
  ```

    - Buka terminal, arahkan ke folder `android`
      di project aplikasi, lalu jalankan perintah berikut:

  ```bash
  ./gradlew signingReport
  ```
    - Cari dan salin nilai `SHA1` dari `variant: debug` paling atas.

  ![Terminal](/assets/Screenshot_5.png)

    - Pergi ke [Google Cloud Console](https://console.cloud.google.com)

  ![Cloud Console](/assets/Screenshot_2.png)

    - Pilih `Credentials` di sidebar kiri, klik `CREATE CREDENTIALS`, pilih `OAuth client ID`
    - Pilih `Android` application type
    - Beri nama, dan `Package name`. package name dapat diketahui dari file `android/app/build.gradle`

  ```gradle
  android {
      namespace "com.example.othtix_app"
      compileSdkVersion 34
      ndkVersion flutter.ndkVersion
      ...
  }
  ```

  ![Cloud Console](/assets/Screenshot_6.png)


- Jika ingin mengubah package name bisa menggunakan [change_app_package_name](https://pub.dev/packages/change_app_package_name)

- Masukkan `SHA1` dari langkah sebelumnya, lalu save/create