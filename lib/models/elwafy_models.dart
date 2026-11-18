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
  final String wilayah;
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

/// Log Notifikasi Telegram Bot Internal
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
  final String? customerUserId;
  final String namaPemesanSnapshot;
  final String waPemesanSnapshot;
  final String namaPenerimaLayanan;
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
  final String catatanPembayaranInternal;
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

/// 9. Model Berita & Edukasi Kesehatan (Beranda v2)
class HealthArticle {
  final String id;
  final String judul;
  final String
  kategori; // misal: 'Tumbuh Kembang Bayi', 'Imun & Kesehatan Anak', 'Laktasi & Bunda'
  final String ringkasan;
  final List<String> isiParagraf;
  final List<String> poinPenting;
  final String penulis;
  final int waktuBacaMenit;
  final DateTime tanggalPublikasi;
  final String? relatedCatalogItemId;
  final String imageUrl;

  const HealthArticle({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.ringkasan,
    required this.isiParagraf,
    this.poinPenting = const [],
    required this.penulis,
    this.waktuBacaMenit = 3,
    required this.tanggalPublikasi,
    this.relatedCatalogItemId,
    this.imageUrl =
        'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=700&q=80',
  });
}

/// 10. Model Konsultan Bidan & Tanya Jawab (Fitur Tanya Bidan ala Halodoc)
class MidwifeConsultant {
  final String id;
  final String nama;
  final String spesialis;
  final String kategoriSpesialis;
  final String pengalaman;
  final String rating;
  final String kepuasanPersen;
  final String nomorStr;
  final String sertifikasi;
  final String lokasiPraktik;
  final String imageUrl;
  final bool isOnline;
  final String whatsapp;
  final List<String> topikKeahlian;

  const MidwifeConsultant({
    required this.id,
    required this.nama,
    required this.spesialis,
    this.kategoriSpesialis = 'Laktasi & Nifas',
    required this.pengalaman,
    this.rating = '4.9',
    this.kepuasanPersen = '99%',
    this.nomorStr = 'STR. 120252219-8841',
    this.sertifikasi = 'Certified Mom & Baby Care, CIMI, Pediatric Tuina',
    this.lokasiPraktik = 'Elwafy Care, Jl. Sei Mencirim, Sunggal',
    this.imageUrl =
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=400&q=80',
    this.isOnline = true,
    required this.whatsapp,
    this.topikKeahlian = const [],
  });
}

class ConsultMessage {
  final String id;
  final String senderName;
  final bool isFromCustomer;
  final String text;
  final DateTime timestamp;
  final String? recommendedCatalogItemId;

  const ConsultMessage({
    required this.id,
    required this.senderName,
    required this.isFromCustomer,
    required this.text,
    required this.timestamp,
    this.recommendedCatalogItemId,
  });
}

class ConsultThread {
  final String id;
  final String consultantId;
  final String consultantName;
  final String customerName;
  final List<ConsultMessage> messages;
  final DateTime updatedAt;

  const ConsultThread({
    required this.id,
    required this.consultantId,
    required this.consultantName,
    required this.customerName,
    required this.messages,
    required this.updatedAt,
  });

  ConsultThread copyWith({
    List<ConsultMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ConsultThread(
      id: id,
      consultantId: consultantId,
      consultantName: consultantName,
      customerName: customerName,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 11. Sistem Elwafy Poin (poin TIDAK bernilai rupiah, hanya ditukar hadiah Elwafy)
class RewardItem {
  final String id;
  final String nama;
  final String deskripsi;
  final String emoji;
  final int poin;
  final int stok;

  const RewardItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.emoji,
    required this.poin,
    required this.stok,
  });

  RewardItem copyWith({int? stok}) {
    return RewardItem(
      id: id,
      nama: nama,
      deskripsi: deskripsi,
      emoji: emoji,
      poin: poin,
      stok: stok ?? this.stok,
    );
  }
}

enum RedemptionStatus {
  menunggu('Menunggu validasi'),
  diambil('Sudah diambil'),
  ditolak('Ditolak / poin kembali');

  final String label;
  const RedemptionStatus(this.label);
}

class RewardRedemption {
  final String id;
  final String kode;
  final String waKey;
  final String namaPemilik;
  final String rewardId;
  final String rewardNama;
  final int poin;
  final RedemptionStatus status;
  final DateTime createdAt;
  final DateTime expiry;
  final DateTime? validatedAt;
  final String? catatan;

  const RewardRedemption({
    required this.id,
    required this.kode,
    required this.waKey,
    required this.namaPemilik,
    required this.rewardId,
    required this.rewardNama,
    required this.poin,
    required this.status,
    required this.createdAt,
    required this.expiry,
    this.validatedAt,
    this.catatan,
  });

  bool get isExpired =>
      status == RedemptionStatus.menunggu && DateTime.now().isAfter(expiry);

  RewardRedemption copyWith({
    RedemptionStatus? status,
    DateTime? validatedAt,
    String? catatan,
  }) {
    return RewardRedemption(
      id: id,
      kode: kode,
      waKey: waKey,
      namaPemilik: namaPemilik,
      rewardId: rewardId,
      rewardNama: rewardNama,
      poin: poin,
      status: status ?? this.status,
      createdAt: createdAt,
      expiry: expiry,
      validatedAt: validatedAt ?? this.validatedAt,
      catatan: catatan ?? this.catatan,
    );
  }
}

class PointEntry {
  final String id;
  final String waKey;
  final String deskripsi;
  final int poin; // positif = masuk, negatif = dipakai
  final DateTime createdAt;

  const PointEntry({
    required this.id,
    required this.waKey,
    required this.deskripsi,
    required this.poin,
    required this.createdAt,
  });
}
