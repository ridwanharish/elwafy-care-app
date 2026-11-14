import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/elwafy_models.dart';
import 'package:mobile_app/state/elwafy_store.dart';

void main() {
  testWidgets('Elwafy Care renders dedicated mobile Customer navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElwafyCareApp());

    // Pastikan nama aplikasi dan navigasi mobile Customer tampil bersih
    expect(find.text('Elwafy Care'), findsWidgets);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
  });

  test('Kriteria Penerimaan v1: Reservasi Tamu, Pesan WA, & Keamanan Token Mitra', () {
    final store = ElwafyStore();

    // 1. Pilih item ke keranjang dan buat reservasi tamu
    store.addToCart('cat-baby-1');
    expect(store.totalCartItems, 1);

    final res = store.createCustomerReservation(
      namaPemesan: 'Bunda Dinda',
      waPemesan: '081234567890',
      namaPenerima: 'Baby Kenzie',
      usiaPenerima: '4 Bulan',
      catatanKhusus: 'Pijat bayi sehat',
      mode: ServiceMode.homecare,
      alamatLengkap: 'Jl. Karya Wisata No. 10',
      patokan: 'Depan minimarket',
      wilayahHomecare: 'Medan Johor',
      tanggalDiminta: DateTime(2026, 11, 2),
      jamDiminta: '10.00 WIB',
    );

    expect(res.nomorReservasi.startsWith('ELW-'), isTrue);
    expect(res.statusReservasi, ReservationStatus.menungguKonfirmasiAdmin);

    // 2. Pastikan pesan WhatsApp memuat nomor reservasi, harga, dan rekening
    final waText = store.buildCustomerWhatsAppMessage(res);
    expect(waText.contains(res.nomorReservasi), isTrue);
    expect(waText.contains(store.settings.nomorRekening), isTrue);

    // 3. Admin menugaskan Mitra Bidan Nisa
    final bidanNisa = store.mitraList.firstWhere((m) => m.id == 'usr-mitra-1');
    final bidanPutri = store.mitraList.firstWhere((m) => m.id == 'usr-mitra-2');
    final asg = store.assignPetugas(reservationId: res.id, petugas: bidanNisa);

    // Jika login sebagai Bidan Putri (bukan pemilik tugas), akses harus ditolak
    store.switchActiveMitra(bidanPutri);
    final invalidCheck = store.validateMitraTaskToken(asg.tokenTugasHash);
    expect(invalidCheck.valid, isFalse);

    // Jika login sebagai Bidan Nisa (pemilik tugas), akses valid
    store.switchActiveMitra(bidanNisa);
    final validCheck = store.validateMitraTaskToken(asg.tokenTugasHash);
    expect(validCheck.valid, isTrue);

    // Mitra menolak tugas dengan alasan wajib -> status berubah jadi Ditolak mitra
    store.respondToMitraTask(
      reservationId: res.id,
      assignmentId: asg.id,
      terima: false,
      alasanPenolakan: 'Sedang ada jadwal pasien lain',
    );
    final updatedRes = store.reservations.firstWhere((r) => r.id == res.id);
    expect(updatedRes.statusReservasi, ReservationStatus.ditolakMitra);
  });
}
