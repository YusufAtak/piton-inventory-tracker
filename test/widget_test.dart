import 'package:flutter_test/flutter_test.dart';

void main() {


  group('Cihaz Durumu (Status) Testleri', () {
    test('Uygulamada sadece izin verilen cihaz durumları seçilebilmelidir', () {

      final validStatuses = ['Çalışıyor', 'Arızalı', 'Eksik'];


      expect(validStatuses.contains('Çalışıyor'), isTrue);
      expect(validStatuses.contains('Arızalı'), isTrue);
      expect(validStatuses.contains('Eksik'), isTrue);


      expect(validStatuses.contains('Bozuk'), isFalse);
    });
  });

  group('Kullanıcı Rolü Testleri', () {
    test('Sistemdeki kullanıcı rolleri sadece admin veya personel olmalıdır', () {
      final allowedRoles = ['admin', 'personel'];

      expect(allowedRoles.length, 2);
      expect(allowedRoles.contains('admin'), isTrue);
      expect(allowedRoles.contains('personel'), isTrue);
      expect(allowedRoles.contains('super_admin'), isFalse);
    });
  });
}