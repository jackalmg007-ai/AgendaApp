# AgendaApp V2 — Physical Agenda Engine

V2, fiziksel ajanda hissinin çekirdeğini geliştirir: çift sayfa (spread), sürükleyerek sayfa çevirme, 3D perspektif, sayfa arkası, gölge, deri kabuk, metal cilt ve yan sekmeler.

## Windows kullanıyorsanız nasıl göreceksiniz?

Windows'ta Xcode ve Apple'ın iOS Simulator uygulaması çalışmaz. Swift kodunu Windows'ta düzenleyebilirsiniz; iOS derlemesini GitHub Actions'ın macOS runner'ında yaptırabilirsiniz.

Bu repo `project.yml` içerir. GitHub Actions önce XcodeGen ile `.xcodeproj` üretir, sonra macOS üzerinde iOS Simulator build'i alır. GitHub'ın güncel macOS runner listesinde `macos-15` Apple Silicon olarak kullanılabilir; macOS-15 görüntülerinde Xcode 26.x sürümleri bulunuyor. Ayrıca Apple'ın güncel gereksinimlerine göre App Store Connect'e yükleme tarafında Xcode 26+ / iOS 26 SDK şartı vardır. Bu nedenle CI'yı Xcode 26 serisiyle doğrulamak hedeflenmelidir.

## GitHub'da çalıştırma

1. GitHub'da yeni bir repo oluşturun.
2. Bu klasörün içindeki dosyaları repoya gönderin.
3. `.github/workflows/ios-build.yml` workflow'u otomatik çalışır.
4. GitHub → Actions → `iOS Build` → başarılı run.
5. Run'ın `Artifacts` bölümünden `AgendaApp-iOS-Simulator` dosyasını indirin.

## Windows'ta gerçekten ekranda görmek

GitHub Actions size iOS Simulator build'i verir, fakat Windows üzerinde bu `.app` dosyasını doğrudan çalıştıramazsınız.

Tarayıcı üzerinden iOS simulator görüntülemek için Appetize gibi bir servis kullanılabilir. Appetize iOS için IPA değil, Simulator Build ister. Actions'ın ürettiği `AgendaApp-Simulator.zip` bu amaçla kullanılabilir.

## Gerçek iPhone üzerinde deneme

Bir iPhone'a yüklemek için Apple'ın imzalama/provisioning süreci gerekir. Geliştirme ve dağıtım aşamasında Apple Developer hesabı, sertifikalar ve cihaz/App Store Connect yapılandırması gerekir. Xcode Cloud da Git repository üzerinden build/test/distribution için kullanılabilir.

## V2 kapsamı

- Çift sayfalı agenda spread
- Interactive drag-to-flip
- 3D page rotation
- Page backside
- Perspective
- Page shadow
- Leather shell
- Binding/ring visual
- Side tabs
- Day / Week / Month / Notes / To-Do
- iPhone + iPad hedefi

## V3 için sıradaki işler

1. Fiziksel sayfa curl/deformasyonu (daha gerçekçi kıvrılma)
2. Haptic + sayfa/sekme sesleri
3. SwiftData modelleri
4. Yerel SQLite tabanlı veri katmanı
5. Gerçek Day/Week/Month olay verileri
6. Notes ve To-Do CRUD
7. Tema/kapak özelleştirme sistemi
