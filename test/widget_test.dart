import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/elwafy_models.dart';
import 'package:mobile_app/state/elwafy_store.dart';

void main() {
  testWidgets(
    'Elwafy Care v2 renders Halodoc-style Beranda with Blue Theme & Dummy Images',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ElwafyCareApp(showSplash: false));

      // Pastikan header dan navigasi ala Halodoc tampil bersih
      expect(find.text('Masuk/Daftar'), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Layanan'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Pastikan seksi Promo Menarik tampil di layar atas
      expect(find.text('Promo Menarik'), findsOneWidget);
      expect(find.text('95 Poin'), findsOneWidget);

      // Tap kartu pill elwafypoin untuk memastikan halaman Elwafy Poin tampil tanpa overflow
      await tester.tap(find.text('elwafypoin'));
      await tester.pumpAndSettle();
      expect(find.text('Elwafy Poin & Hadiah Bunda'), findsOneWidget);
      expect(
        find.text('Tukar Poin dengan Hadiah Resmi Elwafy'),
        findsOneWidget,
      );

      // Kembali ke Beranda
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Scroll ke bawah untuk melihat Layanan Kesehatan di Rumah & Artikel Baru
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
      await tester.pump();

      expect(find.text('Layanan Kesehatan di Rumah'), findsOneWidget);
      expect(find.text('Baca 100+ Artikel Baru'), findsOneWidget);

      // Tap tombol bulat tengah "Bidan" untuk membuka halaman Tanya Bidan ala Halodoc
      await tester.tap(find.text('Bidan'));
      await tester.pump();

      expect(find.text('Pilih Bidan Siaga Elwafy Care'), findsOneWidget);
      expect(find.text('Bidan Elfi, S.Tr.Keb'), findsOneWidget);
      expect(find.text('Gratis'), findsWidgets);
    },
  );

  test('Kriteria Penerimaan v1 & v2: Reservasi Tamu, Token Mitra, & Tanya Bidan', () {
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

    // 4. Test fitur v2: Konsultasi Tanya Bidan & Rekomendasi Layanan Otomatis
    final threadBefore = store.getThreadForConsultant('cons-1');
    final initialMsgCount = threadBefore.messages.length;
    store.sendCustomerConsultMessage(
      'cons-1',
      'Halo Bidan, bayi saya sedang batuk pilek dan rewel',
    );
    final threadAfter = store.getThreadForConsultant('cons-1');
    expect(threadAfter.messages.length, initialMsgCount + 2);
    expect(
      threadAfter.messages.last.recommendedCatalogItemId,
      equals('cat-baby-3'),
    );

    // 5. Test fitur Elwafy Poin (non-Rupiah) & Validasi Penukaran Hadiah oleh Admin
    final initialPoints = store.customerPointsBalance;
    store.updateReservationStatusByAdmin(
      reservationId: res.id,
      newStatus: ReservationStatus.selesai,
      catatan: 'Layanan selesai dikerjakan.',
    );
    expect(store.customerPointsBalance, initialPoints + 20);

    final rdmResult = store.redeemElwafyReward('rwd-1'); // 40 Poin
    expect(rdmResult.success, isTrue);
    expect(rdmResult.redemption!.kode.startsWith('ELW-RDM-'), isTrue);
    expect(rdmResult.redemption!.status, equals(RedemptionStatus.menunggu));
    expect(store.customerPointsBalance, initialPoints + 20 - 40);

    // Jika Admin menolak penukaran, poin kembali utuh ke Bunda
    store.validateRewardRedemption(
      redemptionId: rdmResult.redemption!.id,
      approve: false,
    );
    expect(store.customerPointsBalance, initialPoints + 20);
  });
}
