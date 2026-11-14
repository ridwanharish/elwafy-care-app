import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/elwafy_models.dart';
import '../theme/elwafy_theme.dart';

class ElwafyStore extends ChangeNotifier {
  // Mode tampilan aktif di layar utama (0 = Customer, 1 = Admin, 2 = Mitra)
  int _activePortalTab = 0;
  int get activePortalTab => _activePortalTab;

  // Simulasi sesi login Customer (null = Guest / Tamu)
  AppUser? _loggedInCustomer;
  AppUser? get loggedInCustomer => _loggedInCustomer;

  // Simulasi sesi login Admin
  AppUser? _loggedInAdmin;
  AppUser? get loggedInAdmin => _loggedInAdmin;

  // Simulasi sesi login Mitra / Karyawan
  AppUser? _loggedInMitra;
  AppUser? get loggedInMitra => _loggedInMitra;

  // Token tugas yang sedang dibuka di Portal Mitra (dari simulasi klik link WA)
  String? _openedTaskToken;
  String? get openedTaskToken => _openedTaskToken;

  // Keranjang Customer: Map<catalogItemId, qty>
  final Map<String, int> _cart = {};
  Map<String, int> get cart => Map.unmodifiable(_cart);

  // Pengaturan Aplikasi (Tabel APP_SETTINGS)
  AppSettingsData _settings = const AppSettingsData(
    nomorWaAdmin: '082289992812', // Sesuai bio IG @elwafy.care
    namaBank: 'BSI (Bank Syariah Indonesia)',
    nomorRekening: '7218899281',
    atasNamaRekening: 'Elwafy Care / Bidan Elfi',
    tautanQris: 'https://elwafycare.app/qris-elwafy-official',
    jamOperasionalDefault: '09.00 - 18.00 WIB',
    telegramBotChannel: '@ElwafyCareAdminBot (Group Internal Admin)',
    telegramNotifAktif: true,
  );
  AppSettingsData get settings => _settings;

  // Daftar Pengguna (Tabel USERS)
  final List<AppUser> _users = [
    const AppUser(
      id: 'usr-admin-1',
      nama: 'Bidan Elfi & Owner Wahyu',
      emailOrUsername: 'admin@elwafy.care',
      passwordHash: 'admin123',
      role: UserRole.admin,
      whatsapp: '082289992812',
      wilayah: 'Medan (Pusat)',
      spesialisasi: 'Founder & Certified Mom Baby Care',
    ),
    const AppUser(
      id: 'usr-mitra-1',
      nama: 'Bidan Nisa, Amd.Keb',
      emailOrUsername: 'nisa@mitra.elwafy',
      passwordHash: 'mitra123',
      role: UserRole.mitra,
      whatsapp: '081265001122',
      wilayah: 'Medan Johor, Polonia & Amplas',
      spesialisasi: 'Baby Massage, Pediatric Tuina & Postnatal Care',
    ),
    const AppUser(
      id: 'usr-mitra-2',
      nama: 'Bidan Putri, S.Tr.Keb',
      emailOrUsername: 'putri@mitra.elwafy',
      passwordHash: 'mitra123',
      role: UserRole.mitra,
      whatsapp: '081377889900',
      wilayah: 'Medan Sunggal, Helvetia & Setiabudi',
      spesialisasi: 'Baby Spa, Prenatal Massage & Laktasi',
    ),
    const AppUser(
      id: 'usr-mitra-3',
      nama: 'Bidan Dewi Sartika, Amd.Keb',
      emailOrUsername: 'dewi@mitra.elwafy',
      passwordHash: 'mitra123',
      role: UserRole.mitra,
      whatsapp: '085261112233',
      wilayah: 'Medan Tembung, Denai & Marelan',
      spesialisasi: 'Homecare Baby & Kids Immune Therapy',
    ),
    const AppUser(
      id: 'usr-karyawan-1',
      nama: 'Terapis Rina, Amd.Keb (Staf Outlet)',
      emailOrUsername: 'rina@elwafy.care',
      passwordHash: 'staf123',
      role: UserRole.karyawan,
      whatsapp: '082160004455',
      wilayah: 'Outlet Medan Johor & Sekitarnya',
      spesialisasi: 'Baby Hydrotherapy & Kids Spa',
    ),
    const AppUser(
      id: 'usr-cust-1',
      nama: 'Bunda Sarah Azzahra',
      emailOrUsername: 'sarah@gmail.com',
      passwordHash: 'bunda123',
      role: UserRole.customer,
      whatsapp: '081260998877',
      wilayah: 'Medan Johor',
      spesialisasi: 'Pelanggan Tetap Elwafy',
    ),
  ];
  List<AppUser> get users => List.unmodifiable(_users);

  List<AppUser> get mitraList =>
      _users.where((u) => u.role == UserRole.mitra && u.statusAktif).toList();

  List<AppUser> get karyawanList => _users
      .where((u) => u.role == UserRole.karyawan && u.statusAktif)
      .toList();

  // Daftar Cabang (Tabel OUTLETS)
  final List<Outlet> _outlets = [
    const Outlet(
      id: 'out-1',
      nama: 'Outlet Utama Elwafy Care — Medan Johor',
      alamat: 'Jl. Karya Wisata No. 48, Pangkalan Masyhur, Kec. Medan Johor, Kota Medan',
      wilayah: 'Medan Johor',
      jamOperasional: '09.00 - 18.00 WIB (Setiap Hari)',
      mapsUrl: 'https://maps.google.com/?q=Elwafy+Care+Medan+Johor',
    ),
    const Outlet(
      id: 'out-2',
      nama: 'Outlet Elwafy Care — Setiabudi Medan',
      alamat: 'Jl. Setiabudi No. 112, Tj. Rejo, Kec. Medan Sunggal, Kota Medan',
      wilayah: 'Medan Sunggal / Setiabudi',
      jamOperasional: '09.00 - 18.00 WIB (Setiap Hari)',
      mapsUrl: 'https://maps.google.com/?q=Elwafy+Care+Setiabudi+Medan',
    ),
  ];
  List<Outlet> get outlets => List.unmodifiable(_outlets);

  // Daftar Katalog (Tabel CATALOG_ITEMS)
  final List<CatalogItem> _catalog = [
    // BABY
    const CatalogItem(
      id: 'cat-baby-1',
      nama: 'Baby Happy Massage (Pijat Bayi Sehat)',
      deskripsi:
          'Pijat lembut tersertifikasi untuk usia 0–12 bulan menggunakan minyak alami hangat guna merangsang motorik, kualitas tidur, dan nafsu makan bayi.',
      kategori: CatalogCategory.baby,
      tipe: CatalogType.layanan,
      harga: 95000,
      durasiMenit: 40,
      bisaHomecare: true,
      manfaat: [
        'Membuat tidur bayi lebih nyenyak & tidak mudah rewel',
        'Melancarkan pencernaan & mencegah kolik/kembung',
        'Stimulasi tumbuh kembang & ikatan batin (bonding)',
      ],
    ),
    const CatalogItem(
      id: 'cat-baby-2',
      nama: 'Paket Lengkap Baby Brain Gym, Swim & Massage',
      deskripsi:
          'Rangkaian komplit senam otak bayi (Brain Gym), berenang hidroterapi air hangat (Baby Swim), dilanjutkan pijat relaksasi.',
      kategori: CatalogCategory.baby,
      tipe: CatalogType.paket,
      harga: 165000,
      durasiMenit: 60,
      bisaHomecare: true,
      manfaat: [
        'Melatih kekuatan otot leher, tangan, dan kaki',
        'Termasuk kolam portable higienis untuk layanan Homecare',
        'Meningkatkan koordinasi saraf motorik si kecil',
      ],
    ),
    const CatalogItem(
      id: 'cat-baby-3',
      nama: 'Baby Cough & Cold Therapy (Pijat Tuina + Sinar + Nebu)',
      deskripsi:
          'Terapi khusus bayi batuk pilek tanpa obat dengan pijat akupresur Tuina, penyinaran infrared hangat, dan uap inhalasi nebulizer.',
      kategori: CatalogCategory.baby,
      tipe: CatalogType.layanan,
      harga: 135000,
      durasiMenit: 45,
      bisaHomecare: true,
      manfaat: [
        'Membantu mengencerkan dahak & melegakan hidung tersumbat',
        'Meningkatkan daya tahan tubuh alami anak',
        'Ditangani langsung oleh bidan/terapis tersertifikasi',
      ],
    ),
    const CatalogItem(
      id: 'cat-baby-4',
      nama: 'Tindik Steril Bayi (Metode dr. Evoo / One Push)',
      deskripsi:
          'Tindik telinga bayi minim rasa sakit, higienis, cepat, dan aman dari alergi oleh Bidan tersertifikasi.',
      kategori: CatalogCategory.baby,
      tipe: CatalogType.layanan,
      harga: 150000,
      durasiMenit: 30,
      bisaHomecare: true,
      manfaat: [
        'Alat steril sekali pakai & hipoalergenik',
        'Minim trauma & proses sangat cepat',
        'Pemeriksaan area telinga oleh tenaga bidan',
      ],
    ),

    // KIDS
    const CatalogItem(
      id: 'cat-kids-1',
      nama: 'Kids Immune & Appetite Booster Massage (1–7 Tahun)',
      deskripsi:
          'Pijat akupresur Tuina khusus anak usia aktif untuk meningkatkan nafsu makan (GTM) dan menjaga imunitas tubuh.',
      kategori: CatalogCategory.kids,
      tipe: CatalogType.layanan,
      harga: 115000,
      durasiMenit: 45,
      bisaHomecare: true,
      manfaat: [
        'Membantu mengatasi anak susah makan (Gerakan Tutup Mulut)',
        'Mengurangi pegal setelah anak aktif bermain',
        'Meningkatkan imunitas di musim pancaroba',
      ],
    ),
    const CatalogItem(
      id: 'cat-kids-2',
      nama: 'Paket Kids Ceria Spa (Massage + Bubble Bath + Masker Cokelat)',
      deskripsi:
          'Paket perawatan menyenangkan untuk anak meliputi pijat seluruh tubuh, lulur/masker cokelat organik, dan mandi busa hangat.',
      kategori: CatalogCategory.kids,
      tipe: CatalogType.paket,
      harga: 185000,
      durasiMenit: 65,
      bisaHomecare: false,
      manfaat: [
        'Menjaga kelembapan kulit anak dengan ekstrak cokelat',
        'Pengalaman spa seru di Outlet Elwafy Care',
        'Membuat anak rileks dan segar kembali',
      ],
    ),

    // MOM
    const CatalogItem(
      id: 'cat-mom-1',
      nama: 'Mom Postnatal Care (Pijat Nifas + Pijat Oksitosin/Laktasi)',
      deskripsi:
          'Perawatan khusus bunda pasca melahirkan untuk memulihkan stamina, meredakan pegal menyusui, dan melancarkan produksi ASI.',
      kategori: CatalogCategory.mom,
      tipe: CatalogType.paket,
      harga: 225000,
      durasiMenit: 75,
      bisaHomecare: true,
      manfaat: [
        'Pijat payudara/laktasi & pijat oksitosin agar ASI deras',
        'Relaksasi otot punggung, pinggang, dan bahu bunda',
        'Sangat cocok dipesan Homecare tanpa perlu keluar rumah',
      ],
    ),
    const CatalogItem(
      id: 'cat-mom-2',
      nama: 'Prenatal Gentle Massage (Pijat Ibu Hamil)',
      deskripsi:
          'Pijat lembut khusus ibu hamil trimester 2 & 3 untuk mengurangi nyeri punggung bawah, kram kaki, dan kecemasan menjelang persalinan.',
      kategori: CatalogCategory.mom,
      tipe: CatalogType.layanan,
      harga: 195000,
      durasiMenit: 60,
      bisaHomecare: true,
      manfaat: [
        'Posisi pijat aman untuk ibu hamil & janin',
        'Mengurangi bengkak pada kaki & nyeri pinggang',
        'Membantu bunda tidur lebih berkualitas',
      ],
    ),
    const CatalogItem(
      id: 'cat-mom-3',
      nama: 'Paket Bundling Harmoni (Mom Relax Massage + Baby Spa)',
      deskripsi:
          'Paket hemat perawatan bersamaan untuk Bunda dan Si Kecil dalam satu kunjungan Homecare maupun di Outlet.',
      kategori: CatalogCategory.mom,
      tipe: CatalogType.paket,
      harga: 280000,
      durasiMenit: 90,
      bisaHomecare: true,
      manfaat: [
        'Hemat biaya dibanding pesan terpisah',
        'Bunda rileks, bayi pun tenang dalam satu jadwal kunjungan',
        'Prioritas jadwal penugasan terapis',
      ],
    ),
    const CatalogItem(
      id: 'cat-prod-1',
      nama: 'Elwafy Natural Calming Roll-On Oil (Add-on dibawa Terapis)',
      deskripsi:
          'Minyak aromaterapi alami pendamping pijat bayi untuk menghangatkan perut dan melegakan pernapasan (dibawa langsung saat layanan).',
      kategori: CatalogCategory.baby,
      tipe: CatalogType.produk,
      harga: 45000,
      durasiMenit: null,
      bisaHomecare: true,
      manfaat: [
        '100% Essential Oil ramah kulit bayi baru lahir',
        'Langsung dibawa oleh terapis saat sesi perawatan',
      ],
    ),
  ];
  List<CatalogItem> get catalog => List.unmodifiable(_catalog);

  // Daftar Reservasi (Tabel RESERVATIONS)
  final List<Reservation> _reservations = [];
  List<Reservation> get reservations => List.unmodifiable(_reservations);

  // Log Notifikasi Telegram (Tabel Log Internal)
  final List<TelegramNotifLog> _telegramLogs = [];
  List<TelegramNotifLog> get telegramLogs => List.unmodifiable(_telegramLogs);

  ElwafyStore() {
    _loggedInAdmin = _users.firstWhere((u) => u.role == UserRole.admin);
    _loggedInMitra = _users.firstWhere((u) => u.id == 'usr-mitra-1');
    _seedInitialReservations();
  }

  void _seedInitialReservations() {
    final now = DateTime.now();

    // Reservasi 1: Baru masuk dari Customer Tamu (Menunggu Konfirmasi Admin)
    final res1 = Reservation(
      id: 'res-101',
      nomorReservasi: 'ELW-261030-8421',
      customerUserId: null,
      namaPemesanSnapshot: 'Bunda Nadira Putri',
      waPemesanSnapshot: '081362445566',
      namaPenerimaLayanan: 'Baby Arkan',
      usiaPenerima: '5 Bulan',
      catatanKhusus: 'Bayi agak batuk ringan sejak kemarin sore, mohon bawa alat uap.',
      mode: ServiceMode.homecare,
      alamatLengkap: 'Komp. Johor Indah Permai Blok C No. 14, Jl. Karya Wisata',
      patokan: 'Rumah pagar putih depan taman komplek',
      wilayahHomecare: 'Medan Johor',
      koordinatGps: '3.5321, 98.6745',
      tautanPeta: 'https://maps.google.com/?q=3.5321,98.6745',
      tanggalDiminta: now.add(const Duration(days: 1)),
      jamDiminta: '10.00 WIB',
      totalSnapshot: 180000,
      statusReservasi: ReservationStatus.menungguKonfirmasiAdmin,
      catatanPembayaranInternal: 'Menunggu konfirmasi jadwal sebelum customer transfer',
      createdAt: now.subtract(const Duration(minutes: 25)),
      items: const [
        ReservationItem(
          id: 'ri-1',
          reservationId: 'res-101',
          catalogItemId: 'cat-baby-3',
          namaItemSnapshot: 'Baby Cough & Cold Therapy (Pijat Tuina + Sinar + Nebu)',
          kategoriSnapshot: CatalogCategory.baby,
          tipeSnapshot: CatalogType.layanan,
          durasiSnapshot: 45,
          qty: 1,
          hargaSaatPesan: 135000,
          subtotal: 135000,
        ),
        ReservationItem(
          id: 'ri-2',
          reservationId: 'res-101',
          catalogItemId: 'cat-prod-1',
          namaItemSnapshot: 'Elwafy Natural Calming Roll-On Oil (Add-on dibawa Terapis)',
          kategoriSnapshot: CatalogCategory.baby,
          tipeSnapshot: CatalogType.produk,
          durasiSnapshot: null,
          qty: 1,
          hargaSaatPesan: 45000,
          subtotal: 45000,
        ),
      ],
      statusHistory: [
        ReservationStatusHistory(
          id: 'hist-1',
          reservationId: 'res-101',
          statusSebelum: null,
          statusSesudah: ReservationStatus.menungguKonfirmasiAdmin,
          actorName: 'Bunda Nadira Putri (Customer Tamu)',
          catatan: 'Reservasi baru disimpan ke database sebelum lanjut ke WhatsApp.',
          createdAt: now.subtract(const Duration(minutes: 25)),
        ),
      ],
    );

    // Reservasi 2: Sudah ditugaskan ke Mitra Bidan Nisa (Menunggu Respons Mitra)
    final assignment2 = TaskAssignment(
      id: 'asg-201',
      reservationId: 'res-102',
      assignedUserId: 'usr-mitra-1',
      assignedUserName: 'Bidan Nisa, Amd.Keb',
      assignedUserRole: UserRole.mitra,
      assignedUserWilayah: 'Medan Johor, Polonia & Amplas',
      assignedByUserId: 'usr-admin-1',
      statusRespons: AssignmentResponseStatus.menunggu,
      tokenTugasHash: 'TKN-ELW-9942A7B1',
      expiry: now.add(const Duration(hours: 6)),
      createdAt: now.subtract(const Duration(minutes: 40)),
    );

    final res2 = Reservation(
      id: 'res-102',
      nomorReservasi: 'ELW-261030-5190',
      customerUserId: 'usr-cust-1',
      namaPemesanSnapshot: 'Bunda Sarah Azzahra',
      waPemesanSnapshot: '081260998877',
      namaPenerimaLayanan: 'Bunda Sarah & Baby Zayn',
      usiaPenerima: 'Bunda (Nifas H+14) & Bayi (14 Hari)',
      catatanKhusus: 'ASI agak seret sebelah kanan, mohon sekalian pijat laktasi ya Bidan.',
      mode: ServiceMode.homecare,
      alamatLengkap: 'Jl. Eka Rasmi Gg. Melati No. 8, Gedung Johor',
      patokan: 'Dekat Masjid Al-Ikhlas, rumah cat krem tingkat 2',
      wilayahHomecare: 'Medan Johor',
      koordinatGps: '3.5289, 98.6691',
      tautanPeta: 'https://maps.google.com/?q=3.5289,98.6691',
      tanggalDiminta: now.add(const Duration(days: 1)),
      jamDiminta: '13.30 WIB',
      totalSnapshot: 280000,
      statusReservasi: ReservationStatus.menungguResponsMitra,
      catatanPembayaranInternal: 'Bukti transfer BSI Rp 280.000 sudah diterima di WA',
      createdAt: now.subtract(const Duration(hours: 2)),
      items: const [
        ReservationItem(
          id: 'ri-3',
          reservationId: 'res-102',
          catalogItemId: 'cat-mom-3',
          namaItemSnapshot: 'Paket Bundling Harmoni (Mom Relax Massage + Baby Spa)',
          kategoriSnapshot: CatalogCategory.mom,
          tipeSnapshot: CatalogType.paket,
          durasiSnapshot: 90,
          qty: 1,
          hargaSaatPesan: 280000,
          subtotal: 280000,
        ),
      ],
      assignments: [assignment2],
      statusHistory: [
        ReservationStatusHistory(
          id: 'hist-2a',
          reservationId: 'res-102',
          statusSebelum: null,
          statusSesudah: ReservationStatus.menungguKonfirmasiAdmin,
          actorUserId: 'usr-cust-1',
          actorName: 'Bunda Sarah Azzahra',
          catatan: 'Reservasi dibuat oleh akun customer.',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ReservationStatusHistory(
          id: 'hist-2b',
          reservationId: 'res-102',
          statusSebelum: ReservationStatus.menungguKonfirmasiAdmin,
          statusSesudah: ReservationStatus.terkonfirmasi,
          actorUserId: 'usr-admin-1',
          actorName: 'Bidan Elfi & Owner Wahyu',
          catatan: 'Jadwal pukul 13.30 WIB disetujui setelah konfirmasi WA.',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        ReservationStatusHistory(
          id: 'hist-2c',
          reservationId: 'res-102',
          statusSebelum: ReservationStatus.terkonfirmasi,
          statusSesudah: ReservationStatus.menungguResponsMitra,
          actorUserId: 'usr-admin-1',
          actorName: 'Bidan Elfi & Owner Wahyu',
          catatan: 'Menugaskan Mitra terdekat: Bidan Nisa, Amd.Keb (Token: TKN-ELW-9942A7B1).',
          createdAt: now.subtract(const Duration(minutes: 40)),
        ),
      ],
    );

    // Reservasi 3: Contoh yang ditolak mitra sebelumnya sehingga Admin bisa assign ulang
    final assignment3Rejected = TaskAssignment(
      id: 'asg-301',
      reservationId: 'res-103',
      assignedUserId: 'usr-mitra-2',
      assignedUserName: 'Bidan Putri, S.Tr.Keb',
      assignedUserRole: UserRole.mitra,
      assignedUserWilayah: 'Medan Sunggal, Helvetia & Setiabudi',
      assignedByUserId: 'usr-admin-1',
      statusRespons: AssignmentResponseStatus.ditolak,
      alasanPenolakan: 'Sedang menangani pasien persalinan mendadak di klinik pada jam tersebut.',
      tokenTugasHash: 'TKN-ELW-3310C4D9',
      expiry: now.add(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(hours: 4)),
      respondedAt: now.subtract(const Duration(hours: 3)),
    );

    final res3 = Reservation(
      id: 'res-103',
      nomorReservasi: 'ELW-261029-2044',
      customerUserId: null,
      namaPemesanSnapshot: 'Bunda Citra Lestari',
      waPemesanSnapshot: '082166778899',
      namaPenerimaLayanan: 'Ananda Keenan',
      usiaPenerima: '2,5 Tahun',
      catatanKhusus: 'Anak agak susah makan seminggu terakhir.',
      mode: ServiceMode.homecare,
      alamatLengkap: 'Jl. Gaperta Ujung Komp. Bumi Asri Blok D No. 5',
      patokan: 'Masuk dari gerbang pos satpam utama belok kiri',
      wilayahHomecare: 'Medan Helvetia',
      koordinatGps: '3.6012, 98.6311',
      tautanPeta: 'https://maps.google.com/?q=3.6012,98.6311',
      tanggalDiminta: now.add(const Duration(days: 2)),
      jamDiminta: '15.00 WIB',
      totalSnapshot: 115000,
      statusReservasi: ReservationStatus.ditolakMitra,
      catatanPembayaranInternal: 'Pembayaran QRIS lunas di WA',
      createdAt: now.subtract(const Duration(hours: 5)),
      items: const [
        ReservationItem(
          id: 'ri-4',
          reservationId: 'res-103',
          catalogItemId: 'cat-kids-1',
          namaItemSnapshot: 'Kids Immune & Appetite Booster Massage (1–7 Tahun)',
          kategoriSnapshot: CatalogCategory.kids,
          tipeSnapshot: CatalogType.layanan,
          durasiSnapshot: 45,
          qty: 1,
          hargaSaatPesan: 115000,
          subtotal: 115000,
        ),
      ],
      assignments: [assignment3Rejected],
      statusHistory: [
        ReservationStatusHistory(
          id: 'hist-3a',
          reservationId: 'res-103',
          statusSebelum: null,
          statusSesudah: ReservationStatus.menungguKonfirmasiAdmin,
          actorName: 'Bunda Citra Lestari (Customer Tamu)',
          catatan: 'Reservasi baru dibuat.',
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
        ReservationStatusHistory(
          id: 'hist-3b',
          reservationId: 'res-103',
          statusSebelum: ReservationStatus.menungguKonfirmasiAdmin,
          statusSesudah: ReservationStatus.menungguResponsMitra,
          actorUserId: 'usr-admin-1',
          actorName: 'Bidan Elfi & Owner Wahyu',
          catatan: 'Ditugaskan ke Mitra Bidan Putri, S.Tr.Keb.',
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
        ReservationStatusHistory(
          id: 'hist-3c',
          reservationId: 'res-103',
          statusSebelum: ReservationStatus.menungguResponsMitra,
          statusSesudah: ReservationStatus.ditolakMitra,
          actorUserId: 'usr-mitra-2',
          actorName: 'Bidan Putri, S.Tr.Keb',
          catatan:
              'Menolak tugas. Alasan: Sedang menangani pasien persalinan mendadak di klinik pada jam tersebut.',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
    );

    // Reservasi 4: Kunjungan ke Outlet yang sudah diterima karyawan internal
    final assignment4 = TaskAssignment(
      id: 'asg-401',
      reservationId: 'res-104',
      assignedUserId: 'usr-karyawan-1',
      assignedUserName: 'Terapis Rina, Amd.Keb (Staf Outlet)',
      assignedUserRole: UserRole.karyawan,
      assignedUserWilayah: 'Outlet Medan Johor & Sekitarnya',
      assignedByUserId: 'usr-admin-1',
      statusRespons: AssignmentResponseStatus.diterima,
      tokenTugasHash: 'INTERNAL-STAFF',
      expiry: now.add(const Duration(days: 1)),
      createdAt: now.subtract(const Duration(hours: 6)),
      respondedAt: now.subtract(const Duration(hours: 6)),
    );

    final res4 = Reservation(
      id: 'res-104',
      nomorReservasi: 'ELW-261029-1108',
      customerUserId: null,
      namaPemesanSnapshot: 'Bunda Tari Harahap',
      waPemesanSnapshot: '085270112233',
      namaPenerimaLayanan: 'Baby Humaira',
      usiaPenerima: '3 Bulan',
      catatanKhusus: 'Ingin tindik steril sekalian pijat bayi.',
      mode: ServiceMode.outlet,
      outletId: 'out-1',
      outletNamaSnapshot: 'Outlet Utama Elwafy Care — Medan Johor',
      tanggalDiminta: now,
      jamDiminta: '11.00 WIB',
      totalSnapshot: 245000,
      statusReservasi: ReservationStatus.petugasMenerimaTugas,
      catatanPembayaranInternal: 'DP Rp 100.000 via Transfer BSI, pelunasan di Outlet',
      createdAt: now.subtract(const Duration(hours: 8)),
      items: const [
        ReservationItem(
          id: 'ri-5',
          reservationId: 'res-104',
          catalogItemId: 'cat-baby-4',
          namaItemSnapshot: 'Tindik Steril Bayi (Metode dr. Evoo / One Push)',
          kategoriSnapshot: CatalogCategory.baby,
          tipeSnapshot: CatalogType.layanan,
          durasiSnapshot: 30,
          qty: 1,
          hargaSaatPesan: 150000,
          subtotal: 150000,
        ),
        ReservationItem(
          id: 'ri-6',
          reservationId: 'res-104',
          catalogItemId: 'cat-baby-1',
          namaItemSnapshot: 'Baby Happy Massage (Pijat Bayi Sehat)',
          kategoriSnapshot: CatalogCategory.baby,
          tipeSnapshot: CatalogType.layanan,
          durasiSnapshot: 40,
          qty: 1,
          hargaSaatPesan: 95000,
          subtotal: 95000,
        ),
      ],
      assignments: [assignment4],
      statusHistory: [
        ReservationStatusHistory(
          id: 'hist-4a',
          reservationId: 'res-104',
          statusSebelum: null,
          statusSesudah: ReservationStatus.menungguKonfirmasiAdmin,
          actorName: 'Bunda Tari Harahap',
          catatan: 'Reservasi kunjungan Outlet Medan Johor dibuat.',
          createdAt: now.subtract(const Duration(hours: 8)),
        ),
        ReservationStatusHistory(
          id: 'hist-4b',
          reservationId: 'res-104',
          statusSebelum: ReservationStatus.menungguKonfirmasiAdmin,
          statusSesudah: ReservationStatus.petugasMenerimaTugas,
          actorUserId: 'usr-admin-1',
          actorName: 'Bidan Elfi & Owner Wahyu',
          catatan: 'Jadwal dikonfirmasi & ditugaskan ke Staf Internal: Terapis Rina, Amd.Keb.',
          createdAt: now.subtract(const Duration(hours: 6)),
        ),
      ],
    );

    _reservations.addAll([res1, res2, res3, res4]);
    _openedTaskToken = assignment2.tokenTugasHash;

    _telegramLogs.addAll([
      TelegramNotifLog(
        id: 'tg-1',
        reservationNomor: res1.nomorReservasi,
        judul: '🔔 Reservasi Baru Masuk',
        isiPesan:
            'Nomor: ${res1.nomorReservasi}\nPemesan: ${res1.namaPemesanSnapshot}\nMode: ${res1.mode.label} (${res1.wilayahHomecare})\nJadwal: ${FormatHelper.tanggalIndo(res1.tanggalDiminta)} ${res1.jamDiminta}\nTotal: ${FormatHelper.rupiah(res1.totalSnapshot)}',
        berhasilTerkirim: true,
        createdAt: res1.createdAt,
      ),
      TelegramNotifLog(
        id: 'tg-2',
        reservationNomor: res3.nomorReservasi,
        judul: '⚠️ Mitra Menolak Tugas',
        isiPesan:
            'Nomor: ${res3.nomorReservasi}\nMitra: Bidan Putri, S.Tr.Keb\nAlasan: Sedang menangani pasien persalinan mendadak di klinik pada jam tersebut.\nTindakan: Silakan assign ulang di Dashboard Admin.',
        berhasilTerkirim: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  // Navigasi Portal (Customer / Admin / Mitra)
  void setPortalTab(int index, {String? taskToken}) {
    _activePortalTab = index;
    if (taskToken != null) {
      _openedTaskToken = taskToken;
    }
    notifyListeners();
  }

  // Simulasi Login / Logout Customer (untuk menguji Guest vs Logged-in Autofill)
  void toggleCustomerLogin() {
    if (_loggedInCustomer == null) {
      _loggedInCustomer =
          _users.firstWhere((u) => u.role == UserRole.customer);
    } else {
      _loggedInCustomer = null;
    }
    notifyListeners();
  }

  // Pilih akun Mitra yang sedang aktif di Portal Mitra
  void switchActiveMitra(AppUser? mitra) {
    _loggedInMitra = mitra;
    notifyListeners();
  }

  void setOpenedTaskToken(String? token) {
    _openedTaskToken = token;
    notifyListeners();
  }

  // Manajemen Keranjang Customer
  int get totalCartItems =>
      _cart.values.fold(0, (prev, element) => prev + element);

  int get totalCartPrice {
    int total = 0;
    _cart.forEach((itemId, qty) {
      final item = _catalog.where((c) => c.id == itemId).firstOrNull;
      if (item != null) {
        total += item.harga * qty;
      }
    });
    return total;
  }

  List<MapEntry<CatalogItem, int>> get cartEntries {
    final entries = <MapEntry<CatalogItem, int>>[];
    _cart.forEach((itemId, qty) {
      final item = _catalog.where((c) => c.id == itemId).firstOrNull;
      if (item != null && qty > 0) {
        entries.add(MapEntry(item, qty));
      }
    });
    return entries;
  }

  void addToCart(String catalogItemId) {
    _cart[catalogItemId] = (_cart[catalogItemId] ?? 0) + 1;
    notifyListeners();
  }

  void decrementFromCart(String catalogItemId) {
    final current = _cart[catalogItemId] ?? 0;
    if (current <= 1) {
      _cart.remove(catalogItemId);
    } else {
      _cart[catalogItemId] = current - 1;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ALUR 1: CUSTOMER MEMBUAT RESERVASI (Sesuai Flowchart Halaman 5 & 6)
  Reservation createCustomerReservation({
    required String namaPemesan,
    required String waPemesan,
    required String namaPenerima,
    required String usiaPenerima,
    required String catatanKhusus,
    required ServiceMode mode,
    String? outletId,
    String? alamatLengkap,
    String? patokan,
    String? wilayahHomecare,
    String? koordinatGps,
    String? tautanPeta,
    required DateTime tanggalDiminta,
    required String jamDiminta,
  }) {
    final now = DateTime.now();
    final rand = (1000 + Random().nextInt(9000)).toString();
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final nomorReservasi = 'ELW-$yy$mm$dd-$rand';
    final resId = 'res-${now.millisecondsSinceEpoch}';

    final items = <ReservationItem>[];
    int total = 0;
    int idx = 1;
    for (final entry in cartEntries) {
      final subtotal = entry.key.harga * entry.value;
      total += subtotal;
      items.add(
        ReservationItem(
          id: '$resId-item-$idx',
          reservationId: resId,
          catalogItemId: entry.key.id,
          namaItemSnapshot: entry.key.nama,
          kategoriSnapshot: entry.key.kategori,
          tipeSnapshot: entry.key.tipe,
          durasiSnapshot: entry.key.durasiMenit,
          qty: entry.value,
          hargaSaatPesan: entry.key.harga,
          subtotal: subtotal,
        ),
      );
      idx++;
    }

    Outlet? selectedOutlet;
    if (mode == ServiceMode.outlet && outletId != null) {
      selectedOutlet = _outlets.where((o) => o.id == outletId).firstOrNull;
    }

    final initialHistory = ReservationStatusHistory(
      id: 'hist-${now.millisecondsSinceEpoch}',
      reservationId: resId,
      statusSebelum: null,
      statusSesudah: ReservationStatus.menungguKonfirmasiAdmin,
      actorUserId: _loggedInCustomer?.id,
      actorName: _loggedInCustomer != null
          ? '${_loggedInCustomer!.nama} (Akun Customer)'
          : '$namaPemesan (Customer Tamu)',
      catatan:
          'Reservasi disimpan ke database sebelum diarahkan ke WhatsApp.',
      createdAt: now,
    );

    final newRes = Reservation(
      id: resId,
      nomorReservasi: nomorReservasi,
      customerUserId: _loggedInCustomer?.id,
      namaPemesanSnapshot: namaPemesan,
      waPemesanSnapshot: waPemesan,
      namaPenerimaLayanan: namaPenerima,
      usiaPenerima: usiaPenerima,
      catatanKhusus: catatanKhusus,
      mode: mode,
      outletId: outletId,
      outletNamaSnapshot: selectedOutlet?.nama,
      alamatLengkap: mode == ServiceMode.homecare ? alamatLengkap : null,
      patokan: mode == ServiceMode.homecare ? patokan : null,
      wilayahHomecare: mode == ServiceMode.homecare ? wilayahHomecare : null,
      koordinatGps: mode == ServiceMode.homecare ? koordinatGps : null,
      tautanPeta: mode == ServiceMode.homecare ? tautanPeta : null,
      tanggalDiminta: tanggalDiminta,
      jamDiminta: jamDiminta,
      totalSnapshot: total,
      statusReservasi: ReservationStatus.menungguKonfirmasiAdmin,
      catatanPembayaranInternal: 'Menunggu konfirmasi & bukti transfer di WA',
      createdAt: now,
      items: items,
      assignments: const [],
      statusHistory: [initialHistory],
    );

    // Simpan ke database (urutan teratas)
    _reservations.insert(0, newRes);

    // Kirim notifikasi ringkas ke Telegram Admin (Tetap tersimpan walau notif dimatikan)
    _sendTelegramNotification(
      reservationNomor: nomorReservasi,
      judul: '🆕 Reservasi Baru Masuk ($nomorReservasi)',
      isiPesan:
          'Pemesan: $namaPemesan ($waPemesan)\nPenerima: $namaPenerima ($usiaPenerima)\nMode: ${mode.label}\nLokasi: ${mode == ServiceMode.homecare ? "$wilayahHomecare - $alamatLengkap" : selectedOutlet?.nama}\nJadwal Diminta: ${FormatHelper.tanggalIndo(tanggalDiminta)} $jamDiminta\nTotal: ${FormatHelper.rupiah(total)}',
    );

    // Kosongkan keranjang setelah tersimpan
    _cart.clear();
    notifyListeners();
    return newRes;
  }

  // Generator teks pesan WhatsApp Customer -> Admin (Sesuai Halaman 2, 6, 14, 17)
  String buildCustomerWhatsAppMessage(Reservation res) {
    final sb = StringBuffer();
    sb.writeln('Halo Admin *Elwafy Care (Mom, Kids & Baby Spa)* 👋');
    sb.writeln('Saya ingin mengonfirmasi reservasi layanan berikut:');
    sb.writeln('');
    sb.writeln('📌 *NOMOR RESERVASI: ${res.nomorReservasi}*');
    sb.writeln('Status Awal: _${res.statusReservasi.label}_');
    sb.writeln('');
    sb.writeln('👤 *DATA PEMESAN & PASIEN*');
    sb.writeln('• Nama Pemesan: ${res.namaPemesanSnapshot}');
    sb.writeln('• No. WhatsApp: ${res.waPemesanSnapshot}');
    sb.writeln('• Nama Pasien/Penerima: ${res.namaPenerimaLayanan} (${res.usiaPenerima})');
    if (res.catatanKhusus.trim().isNotEmpty) {
      sb.writeln('• Catatan Keluhan/Kondisi: ${res.catatanKhusus}');
    }
    sb.writeln('');
    sb.writeln('🗓️ *JADWAL & LOKASI YANG DIMINTA*');
    sb.writeln('• Tanggal: ${FormatHelper.tanggalIndo(res.tanggalDiminta)}');
    sb.writeln('• Jam: ${res.jamDiminta} _(Menunggu konfirmasi Admin)_');
    sb.writeln('• Mode Layanan: *${res.mode.label}*');
    if (res.mode == ServiceMode.homecare) {
      sb.writeln('• Wilayah: ${res.wilayahHomecare ?? "-"}');
      sb.writeln('• Alamat Lengkap: ${res.alamatLengkap ?? "-"}');
      if ((res.patokan ?? '').isNotEmpty) {
        sb.writeln('• Patokan Rumah: ${res.patokan}');
      }
      if ((res.tautanPeta ?? '').isNotEmpty) {
        sb.writeln('• Titik Maps: ${res.tautanPeta}');
      }
    } else {
      sb.writeln('• Cabang Outlet: ${res.outletNamaSnapshot ?? "-"}');
    }
    sb.writeln('');
    sb.writeln('🛍️ *RINCIAN LAYANAN / ITEM*');
    for (final item in res.items) {
      sb.writeln(
          '• ${item.namaItemSnapshot} (${item.qty}x @ ${FormatHelper.rupiah(item.hargaSaatPesan)}) = *${FormatHelper.rupiah(item.subtotal)}*');
    }
    sb.writeln('----------------------------------------');
    sb.writeln('💰 *TOTAL ESTIMASI: ${FormatHelper.rupiah(res.totalSnapshot)}*');
    sb.writeln('----------------------------------------');
    sb.writeln('');
    sb.writeln('💳 *INSTRUKSI PEMBAYARAN RESMI ELWAFY CARE*');
    sb.writeln('• Bank: ${_settings.namaBank}');
    sb.writeln('• No. Rekening: *${_settings.nomorRekening}*');
    sb.writeln('• A.n: ${_settings.atasNamaRekening}');
    sb.writeln('• Tautan QRIS: ${_settings.tautanQris}');
    sb.writeln('');
    sb.writeln(
        'Mohon konfirmasi apakah jadwal tersebut tersedia ya Kak. Setelah dikonfirmasi saya akan mengirimkan bukti transfer di chat ini. Terima kasih! 🙏');
    return sb.toString();
  }

  // ALUR 2: ADMIN MEMPROSES RESERVASI, UBAH STATUS / JADWAL, & ASSIGN PETUGAS (Halaman 9 & 10)
  void updateReservationStatusByAdmin({
    required String reservationId,
    required ReservationStatus newStatus,
    required String catatan,
    DateTime? updatedTanggal,
    String? updatedJam,
    String? updatedPaymentNote,
  }) {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index == -1) return;

    final oldRes = _reservations[index];
    final historyItem = ReservationStatusHistory(
      id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
      reservationId: reservationId,
      statusSebelum: oldRes.statusReservasi,
      statusSesudah: newStatus,
      actorUserId: _loggedInAdmin?.id ?? 'usr-admin-1',
      actorName: _loggedInAdmin?.nama ?? 'Admin Elwafy Care',
      catatan: catatan,
      createdAt: DateTime.now(),
    );

    _reservations[index] = oldRes.copyWith(
      statusReservasi: newStatus,
      tanggalDiminta: updatedTanggal ?? oldRes.tanggalDiminta,
      jamDiminta: updatedJam ?? oldRes.jamDiminta,
      catatanPembayaranInternal:
          updatedPaymentNote ?? oldRes.catatanPembayaranInternal,
      statusHistory: [...oldRes.statusHistory, historyItem],
    );
    notifyListeners();
  }

  void updateInternalPaymentNote(String reservationId, String note) {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index == -1) return;
    _reservations[index] = _reservations[index].copyWith(
      catatanPembayaranInternal: note,
    );
    notifyListeners();
  }

  TaskAssignment assignPetugas({
    required String reservationId,
    required AppUser petugas,
    int expiryHours = 12,
  }) {
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index == -1) {
      throw StateError('Reservasi tidak ditemukan');
    }

    final oldRes = _reservations[index];
    final now = DateTime.now();
    final isKaryawan = petugas.role == UserRole.karyawan;

    // Buat token tugas acak & terbatas untuk Mitra (Halaman 9 & 17)
    final randomHex = List.generate(
      8,
      (_) => Random().nextInt(16).toRadixString(16).toUpperCase(),
    ).join();
    final token = isKaryawan ? 'INTERNAL-$randomHex' : 'TKN-ELW-$randomHex';

    final newAssignment = TaskAssignment(
      id: 'asg-${now.millisecondsSinceEpoch}',
      reservationId: reservationId,
      assignedUserId: petugas.id,
      assignedUserName: petugas.nama,
      assignedUserRole: petugas.role,
      assignedUserWilayah: petugas.wilayah,
      assignedByUserId: _loggedInAdmin?.id ?? 'usr-admin-1',
      statusRespons: isKaryawan
          ? AssignmentResponseStatus.diterima
          : AssignmentResponseStatus.menunggu,
      tokenTugasHash: token,
      expiry: now.add(Duration(hours: expiryHours)),
      createdAt: now,
      respondedAt: isKaryawan ? now : null,
    );

    final targetStatus = isKaryawan
        ? ReservationStatus.petugasMenerimaTugas
        : ReservationStatus.menungguResponsMitra;

    final historyItem = ReservationStatusHistory(
      id: 'hist-${now.millisecondsSinceEpoch}',
      reservationId: reservationId,
      statusSebelum: oldRes.statusReservasi,
      statusSesudah: targetStatus,
      actorUserId: _loggedInAdmin?.id ?? 'usr-admin-1',
      actorName: _loggedInAdmin?.nama ?? 'Admin Elwafy Care',
      catatan: isKaryawan
          ? 'Ditugaskan langsung ke Karyawan Internal: ${petugas.nama}.'
          : 'Ditugaskan ke Mitra: ${petugas.nama} (${petugas.wilayah}). Tautan tugas dibuat (Token: $token, berlaku $expiryHours jam).',
      createdAt: now,
    );

    _reservations[index] = oldRes.copyWith(
      statusReservasi: targetStatus,
      assignments: [...oldRes.assignments, newAssignment],
      statusHistory: [...oldRes.statusHistory, historyItem],
    );

    if (!isKaryawan) {
      _openedTaskToken = token;
    }

    notifyListeners();
    return newAssignment;
  }

  String buildMitraWhatsAppInviteMessage(
      Reservation res, TaskAssignment assignment) {
    final sb = StringBuffer();
    sb.writeln('Halo *${assignment.assignedUserName}* 👋');
    sb.writeln('Ada penugasan layanan *Elwafy Care* di dekat wilayah Anda:');
    sb.writeln('');
    sb.writeln('📌 *No. Reservasi*: ${res.nomorReservasi}');
    sb.writeln('👶 *Pasien*: ${res.namaPenerimaLayanan} (${res.usiaPenerima})');
    sb.writeln('🗓️ *Jadwal*: ${FormatHelper.tanggalIndo(res.tanggalDiminta)} - ${res.jamDiminta}');
    sb.writeln('📍 *Wilayah*: ${res.wilayahHomecare ?? res.outletNamaSnapshot ?? "-"}');
    sb.writeln('');
    sb.writeln('🔐 *TAUTAN TUGAS PORTAL MITRA (Berlaku Terbatas)*:');
    sb.writeln(assignment.tautanTugasLengkap);
    sb.writeln('Kode Token: *${assignment.tokenTugasHash}*');
    sb.writeln('');
    sb.writeln(
        'Silakan buka tautan di atas (login ke Portal Mitra Elwafy) untuk melihat alamat rinci serta menekan tombol *TERIMA TUGAS* atau *TOLAK TUGAS*. Terima kasih! 🙏');
    return sb.toString();
  }

  // ALUR 3: MITRA VALIDASI TAUTAN & TERIMA / TOLAK TUGAS (Halaman 12 & 17)
  ({
    bool valid,
    String message,
    Reservation? reservation,
    TaskAssignment? assignment,
  }) validateMitraTaskToken(String tokenInput) {
    final cleanToken = tokenInput.trim();
    if (_loggedInMitra == null) {
      return (
        valid: false,
        message:
            'Anda belum login ke Portal Mitra. Tautan dari WhatsApp hanya pintu masuk; silakan login terlebih dahulu.',
        reservation: null,
        assignment: null,
      );
    }

    for (final res in _reservations) {
      for (final asg in res.assignments.reversed) {
        if (asg.tokenTugasHash.toUpperCase() == cleanToken.toUpperCase()) {
          if (asg.assignedUserId != _loggedInMitra!.id) {
            return (
              valid: false,
              message:
                  'AKSES DITOLAK: Tautan tugas ini ditujukan untuk "${asg.assignedUserName}", bukan akun Anda (${_loggedInMitra!.nama}). Mitra tidak dapat mengakses reservasi milik petugas lain.',
              reservation: null,
              assignment: null,
            );
          }
          if (asg.isExpired) {
            return (
              valid: false,
              message:
                  'TAUTAN KEDALUWARSA: Masa berlaku token tugas ini sudah habis. Silakan minta Admin mengirim tautan tugas baru.',
              reservation: null,
              assignment: null,
            );
          }
          return (
            valid: true,
            message:
                'Tautan valid & terverifikasi milik ${_loggedInMitra!.nama}.',
            reservation: res,
            assignment: asg,
          );
        }
      }
    }

    return (
      valid: false,
      message:
          'TOKEN TIDAK VALID: Kode tautan "$cleanToken" tidak ditemukan di sistem. Pastikan tautan sesuai atau minta Admin mengirim tautan baru.',
      reservation: null,
      assignment: null,
    );
  }

  void respondToMitraTask({
    required String reservationId,
    required String assignmentId,
    required bool terima,
    String? alasanPenolakan,
  }) {
    final resIndex = _reservations.indexWhere((r) => r.id == reservationId);
    if (resIndex == -1) return;

    final oldRes = _reservations[resIndex];
    final asgIndex =
        oldRes.assignments.indexWhere((a) => a.id == assignmentId);
    if (asgIndex == -1) return;

    final oldAsg = oldRes.assignments[asgIndex];
    final now = DateTime.now();

    final updatedAsg = oldAsg.copyWith(
      statusRespons: terima
          ? AssignmentResponseStatus.diterima
          : AssignmentResponseStatus.ditolak,
      alasanPenolakan: terima ? null : alasanPenolakan,
      respondedAt: now,
    );

    final updatedAssignments = List<TaskAssignment>.from(oldRes.assignments);
    updatedAssignments[asgIndex] = updatedAsg;

    final newStatus = terima
        ? ReservationStatus.petugasMenerimaTugas
        : ReservationStatus.ditolakMitra;

    final historyItem = ReservationStatusHistory(
      id: 'hist-${now.millisecondsSinceEpoch}',
      reservationId: reservationId,
      statusSebelum: oldRes.statusReservasi,
      statusSesudah: newStatus,
      actorUserId: oldAsg.assignedUserId,
      actorName: oldAsg.assignedUserName,
      catatan: terima
          ? 'Mitra menekan TERIMA TUGAS di Portal Mitra.'
          : 'Mitra menekan TOLAK TUGAS. Alasan: ${alasanPenolakan ?? "-"}',
      createdAt: now,
    );

    _reservations[resIndex] = oldRes.copyWith(
      statusReservasi: newStatus,
      assignments: updatedAssignments,
      statusHistory: [...oldRes.statusHistory, historyItem],
    );

    // Kirim notifikasi ke Telegram Admin (Halaman 12 & 14)
    _sendTelegramNotification(
      reservationNomor: oldRes.nomorReservasi,
      judul: terima
          ? '✅ Mitra Menerima Tugas (${oldRes.nomorReservasi})'
          : '❌ Mitra Menolak Tugas (${oldRes.nomorReservasi})',
      isiPesan: terima
          ? 'Mitra: ${oldAsg.assignedUserName}\nPasien: ${oldRes.namaPenerimaLayanan}\nJadwal: ${FormatHelper.tanggalIndo(oldRes.tanggalDiminta)} ${oldRes.jamDiminta}\nStatus diperbarui menjadi: Petugas menerima tugas.'
          : 'Mitra: ${oldAsg.assignedUserName}\nAlasan Penolakan: ${alasanPenolakan ?? "-"}\nStatus: Ditolak mitra. Silakan assign ulang di Dashboard Admin.',
    );

    notifyListeners();
  }

  // Kelola Katalog & Pengaturan oleh Admin
  void toggleCatalogItemStatus(String itemId) {
    final idx = _catalog.indexWhere((c) => c.id == itemId);
    if (idx == -1) return;
    _catalog[idx] = _catalog[idx].copyWith(
      statusAktif: !_catalog[idx].statusAktif,
    );
    notifyListeners();
  }

  void addCatalogItem(CatalogItem item) {
    _catalog.insert(0, item);
    notifyListeners();
  }

  void updateAppSettings(AppSettingsData newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void _sendTelegramNotification({
    required String reservationNomor,
    required String judul,
    required String isiPesan,
  }) {
    _telegramLogs.insert(
      0,
      TelegramNotifLog(
        id: 'tg-${DateTime.now().millisecondsSinceEpoch}',
        reservationNomor: reservationNomor,
        judul: judul,
        isiPesan: isiPesan,
        berhasilTerkirim: _settings.telegramNotifAktif,
        createdAt: DateTime.now(),
      ),
    );
  }
}

