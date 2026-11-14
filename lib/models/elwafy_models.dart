enum UserRole {
  customer('Customer'),
  admin('Admin'),
  mitra('Mitra Homecare'),
  karyawan('Karyawan Internal');

  final String label;
  const UserRole(this.label);
}

enum CatalogCategory {
  baby('Baby'),
  kids('Kids'),
  mom('Mom');

  final String label;
  const CatalogCategory(this.label);
}

enum CatalogType {
  layanan('Layanan'),
  paket('Paket'),
  produk('Produk Tambahan');

  final String label;
  const CatalogType(this.label);
}

enum ServiceMode {
  homecare('Homecare (Ke Rumah)'),
  outlet('Outlet (Datang ke Cabang)');

  final String label;
  const ServiceMode(this.label);
}

/// 8 Status Reservasi Awal sesuai Dokumen Elwafy Care v0.1 Halaman 15
enum ReservationStatus {
  menungguKonfirmasiAdmin('Menunggu konfirmasi admin'),
  perluPenyesuaianJadwal('Perlu penyesuaian jadwal'),
  terkonfirmasi('Terkonfirmasi'),
  menungguResponsMitra('Menunggu respons mitra'),
  petugasMenerimaTugas('Petugas menerima tugas'),
  ditolakMitra('Ditolak mitra'),
  selesai('Selesai'),
  dibatalkan('Dibatalkan');

  final String label;
  const ReservationStatus(this.label);
}

enum AssignmentResponseStatus {
  menunggu('Menunggu Respons'),
  diterima('Tugas Diterima'),
  ditolak('Tugas Ditolak');

  final String label;
  const AssignmentResponseStatus(this.label);
}

/// 1. Tabel USERS (ERD Halaman 13)
class AppUser {
  final String id;
  final String nama;
  final String emailOrUsername;
  final String passwordHash;
  final UserRole role;
  final String whatsapp;
  final String wilayah; // Memudahkan Admin memilih mitra terdekat
  final String spesialisasi;
  final bool statusAktif;

  const AppUser({
    required this.id,
    required this.nama,
    required this.emailOrUsername,
    required this.passwordHash,
    required this.role,
    required this.whatsapp,
    required this.wilayah,
    this.spesialisasi = 'Certified Mom & Baby Therapist',
    this.statusAktif = true,
  });
}

/// 2. Tabel CATALOG_ITEMS (ERD Halaman 13)
class CatalogItem {
  final String id;
  final String nama;
  final String deskripsi;
  final CatalogCategory kategori;
  final CatalogType tipe;
  final int harga;
  final int? durasiMenit;
  final bool bisaHomecare;
  final bool statusAktif;
  final List<String> manfaat;

  const CatalogItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.tipe,
    required this.harga,
    this.durasiMenit,
    this.bisaHomecare = true,
    this.statusAktif = true,
    this.manfaat = const [],
  });

  CatalogItem copyWith({
    String? nama,
    String? deskripsi,
    CatalogCategory? kategori,
    CatalogType? tipe,
    int? harga,
    int? durasiMenit,
    bool? bisaHomecare,
    bool? statusAktif,
    List<String>? manfaat,
  }) {
    return CatalogItem(
      id: id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      tipe: tipe ?? this.tipe,
      harga: harga ?? this.harga,
      durasiMenit: durasiMenit ?? this.durasiMenit,
      bisaHomecare: bisaHomecare ?? this.bisaHomecare,
      statusAktif: statusAktif ?? this.statusAktif,
      manfaat: manfaat ?? this.manfaat,
    );
  }
}

/// 3. Tabel OUTLETS (ERD Halaman 13)
class Outlet {
  final String id;
  final String nama;
  final String alamat;
  final String wilayah;
  final String jamOperasional;
  final String mapsUrl;
  final bool statusAktif;

  const Outlet({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.wilayah,
    required this.jamOperasional,
    required this.mapsUrl,
    this.statusAktif = true,
  });
}

/// 4. Tabel RESERVATION_ITEMS (ERD Halaman 13)
class ReservationItem {
  final String id;
  final String reservationId;
  final String catalogItemId;
  final String namaItemSnapshot;
  final CatalogCategory kategoriSnapshot;
  final CatalogType tipeSnapshot;
  final int? durasiSnapshot;
  final int qty;
  final int hargaSaatPesan;
  final int subtotal;

  const ReservationItem({
    required this.id,
    required this.reservationId,
    required this.catalogItemId,
    required this.namaItemSnapshot,
    required this.kategoriSnapshot,
    required this.tipeSnapshot,
    this.durasiSnapshot,
    required this.qty,
    required this.hargaSaatPesan,
    required this.subtotal,
  });
}

/// 5. Tabel ASSIGNMENTS (ERD Halaman 13)
class TaskAssignment {
  final String id;
  final String reservationId;
  final String assignedUserId;
  final String assignedUserName;
  final UserRole assignedUserRole;
  final String assignedUserWilayah;
  final String assignedByUserId;
  final AssignmentResponseStatus statusRespons;
  final String? alasanPenolakan;
  final String tokenTugasHash;
  final DateTime expiry;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const TaskAssignment({
    required this.id,
    required this.reservationId,
    required this.assignedUserId,
    required this.assignedUserName,
    required this.assignedUserRole,
    required this.assignedUserWilayah,
    required this.assignedByUserId,
    required this.statusRespons,
    this.alasanPenolakan,
    required this.tokenTugasHash,
    required this.expiry,
    required this.createdAt,
    this.respondedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  String get tautanTugasLengkap =>
      'https://elwafycare.app/mitra/tugas?res=$reservationId&token=$tokenTugasHash';

  TaskAssignment copyWith({
    AssignmentResponseStatus? statusRespons,
    String? alasanPenolakan,
    DateTime? respondedAt,
    DateTime? expiry,
  }) {
    return TaskAssignment(
      id: id,
      reservationId: reservationId,
      assignedUserId: assignedUserId,
      assignedUserName: assignedUserName,
      assignedUserRole: assignedUserRole,
      assignedUserWilayah: assignedUserWilayah,
      assignedByUserId: assignedByUserId,
      statusRespons: statusRespons ?? this.statusRespons,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
      tokenTugasHash: tokenTugasHash,
      expiry: expiry ?? this.expiry,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

/// 6. Tabel RESERVATION_STATUS_HISTORY (ERD Halaman 13)
class ReservationStatusHistory {
  final String id;
  final String reservationId;
  final ReservationStatus? statusSebelum;
  final ReservationStatus statusSesudah;
  final String? actorUserId;
  final String actorName;
  final String catatan;
  final DateTime createdAt;

  const ReservationStatusHistory({
    required this.id,
    required this.reservationId,
    this.statusSebelum,
    required this.statusSesudah,
    this.actorUserId,
    required this.actorName,
    required this.catatan,
    required this.createdAt,
  });
}

/// Log Notifikasi Telegram Bot Internal (Sesuai DFD & Hal 14)
class TelegramNotifLog {
  final String id;
  final String reservationNomor;
  final String judul;
  final String isiPesan;
  final bool berhasilTerkirim;
  final DateTime createdAt;

  const TelegramNotifLog({
    required this.id,
    required this.reservationNomor,
    required this.judul,
    required this.isiPesan,
    required this.berhasilTerkirim,
    required this.createdAt,
  });
}

/// 7. Tabel RESERVATIONS (ERD Halaman 13)
class Reservation {
  final String id;
  final String nomorReservasi;
  final String? customerUserId; // Opsional (Guest Checkout didukung)
  final String namaPemesanSnapshot;
  final String waPemesanSnapshot;
  final String namaPenerimaLayanan; // Nama Bayi / Anak / Bunda
  final String usiaPenerima;
  final String catatanKhusus;
  final ServiceMode mode;
  final String? outletId;
  final String? outletNamaSnapshot;
  final String? alamatLengkap;
  final String? patokan;
  final String? wilayahHomecare;
  final String? koordinatGps;
  final String? tautanPeta;
  final DateTime tanggalDiminta;
  final String jamDiminta;
  final int totalSnapshot;
  final ReservationStatus statusReservasi;
  final String catatanPembayaranInternal; // Catatan manual admin (bukan payment gateway)
  final DateTime createdAt;
  final List<ReservationItem> items;
  final List<TaskAssignment> assignments;
  final List<ReservationStatusHistory> statusHistory;

  const Reservation({
    required this.id,
    required this.nomorReservasi,
    this.customerUserId,
    required this.namaPemesanSnapshot,
    required this.waPemesanSnapshot,
    required this.namaPenerimaLayanan,
    required this.usiaPenerima,
    required this.catatanKhusus,
    required this.mode,
    this.outletId,
    this.outletNamaSnapshot,
    this.alamatLengkap,
    this.patokan,
    this.wilayahHomecare,
    this.koordinatGps,
    this.tautanPeta,
    required this.tanggalDiminta,
    required this.jamDiminta,
    required this.totalSnapshot,
    required this.statusReservasi,
    this.catatanPembayaranInternal = 'Belum dicek di WhatsApp',
    required this.createdAt,
    required this.items,
    this.assignments = const [],
    this.statusHistory = const [],
  });

  TaskAssignment? get activeAssignment =>
      assignments.isEmpty ? null : assignments.last;

  Reservation copyWith({
    DateTime? tanggalDiminta,
    String? jamDiminta,
    ReservationStatus? statusReservasi,
    String? catatanPembayaranInternal,
    List<TaskAssignment>? assignments,
    List<ReservationStatusHistory>? statusHistory,
  }) {
    return Reservation(
      id: id,
      nomorReservasi: nomorReservasi,
      customerUserId: customerUserId,
      namaPemesanSnapshot: namaPemesanSnapshot,
      waPemesanSnapshot: waPemesanSnapshot,
      namaPenerimaLayanan: namaPenerimaLayanan,
      usiaPenerima: usiaPenerima,
      catatanKhusus: catatanKhusus,
      mode: mode,
      outletId: outletId,
      outletNamaSnapshot: outletNamaSnapshot,
      alamatLengkap: alamatLengkap,
      patokan: patokan,
      wilayahHomecare: wilayahHomecare,
      koordinatGps: koordinatGps,
      tautanPeta: tautanPeta,
      tanggalDiminta: tanggalDiminta ?? this.tanggalDiminta,
      jamDiminta: jamDiminta ?? this.jamDiminta,
      totalSnapshot: totalSnapshot,
      statusReservasi: statusReservasi ?? this.statusReservasi,
      catatanPembayaranInternal:
          catatanPembayaranInternal ?? this.catatanPembayaranInternal,
      createdAt: createdAt,
      items: items,
      assignments: assignments ?? this.assignments,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

/// 8. Tabel APP_SETTINGS (ERD Halaman 13)
class AppSettingsData {
  final String nomorWaAdmin;
  final String namaBank;
  final String nomorRekening;
  final String atasNamaRekening;
  final String tautanQris;
  final String jamOperasionalDefault;
  final String telegramBotChannel;
  final bool telegramNotifAktif;

  const AppSettingsData({
    required this.nomorWaAdmin,
    required this.namaBank,
    required this.nomorRekening,
    required this.atasNamaRekening,
    required this.tautanQris,
    required this.jamOperasionalDefault,
    required this.telegramBotChannel,
    this.telegramNotifAktif = true,
  });

  AppSettingsData copyWith({
    String? nomorWaAdmin,
    String? namaBank,
    String? nomorRekening,
    String? atasNamaRekening,
    String? tautanQris,
    String? jamOperasionalDefault,
    String? telegramBotChannel,
    bool? telegramNotifAktif,
  }) {
    return AppSettingsData(
      nomorWaAdmin: nomorWaAdmin ?? this.nomorWaAdmin,
      namaBank: namaBank ?? this.namaBank,
      nomorRekening: nomorRekening ?? this.nomorRekening,
      atasNamaRekening: atasNamaRekening ?? this.atasNamaRekening,
      tautanQris: tautanQris ?? this.tautanQris,
      jamOperasionalDefault:
          jamOperasionalDefault ?? this.jamOperasionalDefault,
      telegramBotChannel: telegramBotChannel ?? this.telegramBotChannel,
      telegramNotifAktif: telegramNotifAktif ?? this.telegramNotifAktif,
    );
  }
}

