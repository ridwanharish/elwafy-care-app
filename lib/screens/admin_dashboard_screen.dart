import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ElwafyStore store;

  const AdminDashboardScreen({
    super.key,
    required this.store,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _adminNavIndex = 0; // 0 = Antrean, 1 = Riwayat, 2 = Katalog & Mitra, 3 = Pengaturan

  // Filter untuk Tab Riwayat
  ReservationStatus? _filterStatus;
  ServiceMode? _filterMode;
  String _searchQuery = '';
  DateTimeRange? _filterDateRange;

  List<Reservation> get _actionRequiredReservations {
    return widget.store.reservations.where((r) {
      return r.statusReservasi == ReservationStatus.menungguKonfirmasiAdmin ||
          r.statusReservasi == ReservationStatus.ditolakMitra ||
          r.statusReservasi == ReservationStatus.perluPenyesuaianJadwal ||
          r.statusReservasi == ReservationStatus.terkonfirmasi ||
          r.statusReservasi == ReservationStatus.menungguResponsMitra;
    }).toList();
  }

  List<Reservation> get _filteredHistoryReservations {
    return widget.store.reservations.where((res) {
      if (_filterStatus != null && res.statusReservasi != _filterStatus) {
        return false;
      }
      if (_filterMode != null && res.mode != _filterMode) {
        return false;
      }
      if (_filterDateRange != null) {
        final d = DateTime(
          res.tanggalDiminta.year,
          res.tanggalDiminta.month,
          res.tanggalDiminta.day,
        );
        final start = DateTime(
          _filterDateRange!.start.year,
          _filterDateRange!.start.month,
          _filterDateRange!.start.day,
        );
        final end = DateTime(
          _filterDateRange!.end.year,
          _filterDateRange!.end.month,
          _filterDateRange!.end.day,
        );
        if (d.isBefore(start) || d.isAfter(end)) {
          return false;
        }
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return res.nomorReservasi.toLowerCase().contains(q) ||
            res.namaPemesanSnapshot.toLowerCase().contains(q) ||
            res.namaPenerimaLayanan.toLowerCase().contains(q) ||
            (res.wilayahHomecare ?? '').toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now.add(const Duration(days: 90)),
      initialDateRange: _filterDateRange,
    );
    if (picked != null) {
      setState(() => _filterDateRange = picked);
    }
  }

  void _openReservationDetailPage(Reservation res) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AdminReservationDetailScreen(
          store: widget.store,
          reservationId: res.id,
        ),
      ),
    );
  }

  void _openAddCatalogDialog() {
    final namaCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    final hargaCtrl = TextEditingController(text: '120000');
    final durasiCtrl = TextEditingController(text: '45');
    CatalogCategory selectedCat = CatalogCategory.baby;
    CatalogType selectedType = CatalogType.layanan;
    bool bisaHomecare = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text(
                'Tambah Layanan Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Layanan / Paket',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<CatalogCategory>(
                      initialValue: selectedCat,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: CatalogCategory.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedCat = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hargaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rupiah)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durasiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durasi (Menit)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: deskripsiCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Singkat',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: bisaHomecare,
                      onChanged: (v) => setModalState(() => bisaHomecare = v),
                      title: const Text(
                        'Bisa Homecare ke Rumah',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.trim().isEmpty) return;
                    final harga = int.tryParse(hargaCtrl.text.trim()) ?? 100000;
                    final durasi = int.tryParse(durasiCtrl.text.trim());
                    widget.store.addCatalogItem(
                      CatalogItem(
                        id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                        nama: namaCtrl.text.trim(),
                        deskripsi: deskripsiCtrl.text.trim().isEmpty
                            ? 'Layanan tersertifikasi Elwafy Care Medan.'
                            : deskripsiCtrl.text.trim(),
                        kategori: selectedCat,
                        tipe: selectedType,
                        harga: harga,
                        durasiMenit: durasi,
                        bisaHomecare: bisaHomecare,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final needActionCount = widget.store.reservations
        .where(
          (r) =>
              r.statusReservasi == ReservationStatus.menungguKonfirmasiAdmin ||
              r.statusReservasi == ReservationStatus.ditolakMitra,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ElwafyColors.navyDark,
        titleSpacing: 16,
        title: const Row(
          children: [
            ElwafyLogo(size: 32),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Elwafy Care',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Dashboard Pengelola & Penugasan Mitra',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => widget.store.setPortalTab(0),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.exit_to_app_rounded, size: 18),
            label: const Text(
              'Customer',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _adminNavIndex,
        children: [
          _buildAntreanTab(),
          _buildRiwayatTab(),
          _buildKatalogDanMitraTab(),
          _buildPengaturanTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _adminNavIndex,
        onDestinationSelected: (idx) => setState(() => _adminNavIndex = idx),
        backgroundColor: Colors.white,
        indicatorColor: ElwafyColors.softBlueCard,
        height: 66,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: needActionCount > 0,
              label: Text('$needActionCount'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: needActionCount > 0,
              label: Text('$needActionCount'),
              child: const Icon(
                Icons.inbox_rounded,
                color: ElwafyColors.primaryBlue,
              ),
            ),
            label: 'Antrean',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(
              Icons.history_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Riwayat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(
              Icons.medical_services_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Mitra & Katalog',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(
              Icons.settings_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }

  // TAB 0: ANTREAN AKTIF (BUTUH KONFIRMASI / DITOLAK MITRA / TUNGGU MITRA)
  Widget _buildAntreanTab() {
    final all = widget.store.reservations;
    final baruCount = all
        .where(
          (r) =>
              r.statusReservasi == ReservationStatus.menungguKonfirmasiAdmin ||
              r.statusReservasi == ReservationStatus.ditolakMitra,
        )
        .length;
    final tungguMitraCount = all
        .where((r) => r.statusReservasi == ReservationStatus.menungguResponsMitra)
        .length;
    final jalanCount = all
        .where(
          (r) =>
              r.statusReservasi == ReservationStatus.petugasMenerimaTugas ||
              r.statusReservasi == ReservationStatus.selesai,
        )
        .length;

    final list = _actionRequiredReservations;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ringkasan KPI Ringkas
        Row(
          children: [
            Expanded(
              child: _CompactMetricCard(
                label: 'Perlu Tindakan',
                value: '$baruCount',
                color: ElwafyColors.warningAmber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CompactMetricCard(
                label: 'Tunggu Mitra',
                value: '$tungguMitraCount',
                color: ElwafyColors.purpleAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CompactMetricCard(
                label: 'Aktif / Selesai',
                value: '$jalanCount',
                color: ElwafyColors.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Daftar Reservasi Perlu Diproses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: ElwafyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final res in list) ...[
          _CompactReservationCard(
            reservation: res,
            onTap: () => _openReservationDetailPage(res),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // TAB 1: SEMUA RESERVASI & FILTER RIWAYAT
  Widget _buildRiwayatTab() {
    final filtered = _filteredHistoryReservations;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Cari No. Reservasi, nama pasien, wilayah...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range_rounded, size: 16),
                        label: Text(
                          _filterDateRange == null
                              ? 'Filter Periode Tanggal'
                              : '${FormatHelper.tanggalIndo(_filterDateRange!.start)} - ${FormatHelper.tanggalIndo(_filterDateRange!.end)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    if (_filterDateRange != null)
                      IconButton(
                        onPressed: () =>
                            setState(() => _filterDateRange = null),
                        icon: const Icon(Icons.clear_rounded, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text(
                          'Semua Jenis',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        selected: _filterMode == null,
                        onSelected: (_) => setState(() => _filterMode = null),
                      ),
                      const SizedBox(width: 6),
                      for (final mode in ServiceMode.values) ...[
                        ChoiceChip(
                          label: Text(
                            mode.label,
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          selected: _filterMode == mode,
                          onSelected: (_) => setState(
                            () => _filterMode =
                                _filterMode == mode ? null : mode,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text(
                          'Semua Status',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        selected: _filterStatus == null,
                        onSelected: (_) =>
                            setState(() => _filterStatus = null),
                      ),
                      const SizedBox(width: 6),
                      for (final st in ReservationStatus.values) ...[
                        ChoiceChip(
                          label: Text(
                            st.label,
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          selected: _filterStatus == st,
                          onSelected: (_) => setState(
                            () =>
                                _filterStatus = _filterStatus == st ? null : st,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final res in filtered) ...[
          _CompactReservationCard(
            reservation: res,
            onTap: () => _openReservationDetailPage(res),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  // TAB 2: DAFTAR MITRA HOMECARE & KATALOG
  Widget _buildKatalogDanMitraTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mitra Homecare & Staf Terapis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cakupan wilayah mitra untuk memudahkan penugasan terdekat:',
                  style: TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
                const Divider(height: 18),
                for (final u in widget.store.users.where(
                  (u) =>
                      u.role == UserRole.mitra || u.role == UserRole.karyawan,
                ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: ElwafyColors.softBlueCard,
                          child: Icon(
                            u.role == UserRole.mitra
                                ? Icons.directions_car_rounded
                                : Icons.badge_rounded,
                            size: 18,
                            color: ElwafyColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                '📍 ${u.wilayah}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ElwafyColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${u.role.label} • WA: ${u.whatsapp}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: ElwafyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Katalog Layanan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _openAddCatalogDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
                const Divider(height: 18),
                for (final item in widget.store.catalog)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: item.statusAktif,
                    onChanged: (_) =>
                        widget.store.toggleCatalogItemStatus(item.id),
                    title: Text(
                      item.nama,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: item.statusAktif
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      '${item.kategori.label} • ${FormatHelper.rupiah(item.harga)}',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: PENGATURAN REKENING/WA & LOG TELEGRAM BOT
  Widget _buildPengaturanTab() {
    final s = widget.store.settings;
    final waCtrl = TextEditingController(text: s.nomorWaAdmin);
    final bankCtrl = TextEditingController(text: s.namaBank);
    final rekCtrl = TextEditingController(text: s.nomorRekening);
    final anCtrl = TextEditingController(text: s.atasNamaRekening);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengaturan WhatsApp & Rekening',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: waCtrl,
                  decoration: const InputDecoration(
                    labelText: 'No. WhatsApp Admin',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bankCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Bank'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: rekCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Rekening',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: anCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Atas Nama Rekening',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.store.updateAppSettings(
                        s.copyWith(
                          nomorWaAdmin: waCtrl.text.trim(),
                          namaBank: bankCtrl.text.trim(),
                          nomorRekening: rekCtrl.text.trim(),
                          atasNamaRekening: anCtrl.text.trim(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaturan berhasil disimpan!'),
                        ),
                      );
                    },
                    child: const Text('Simpan Pengaturan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.telegram_rounded,
                      color: ElwafyColors.telegramBlue,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Log Notifikasi Bot Telegram Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                for (final log in widget.store.telegramLogs)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ElwafyColors.babyBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: ElwafyColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.isiPesan,
                          style: const TextStyle(fontSize: 11.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactMetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ElwafyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _CompactReservationCard({
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = ElwafyTheme.statusColor(reservation.statusReservasi);
    final activeAsg = reservation.activeAssignment;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    reservation.nomorReservasi,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reservation.statusReservasi.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '👶 ${reservation.namaPenerimaLayanan} • Pemesan: ${reservation.namaPemesanSnapshot}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '🗓️ ${FormatHelper.tanggalIndo(reservation.tanggalDiminta)} (${reservation.jamDiminta}) • ${reservation.mode == ServiceMode.homecare ? "🏠 ${reservation.wilayahHomecare}" : "🏥 Outlet"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              if (activeAsg != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeAsg.statusRespons ==
                            AssignmentResponseStatus.ditolak
                        ? ElwafyColors.dangerRed.withValues(alpha: 0.08)
                        : ElwafyColors.babyBlueBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activeAsg.statusRespons == AssignmentResponseStatus.ditolak
                        ? '⚠️ Ditolak ${activeAsg.assignedUserName}: "${activeAsg.alasanPenolakan}"'
                        : '👩‍⚕️ Petugas: ${activeAsg.assignedUserName} (${activeAsg.statusRespons.label})',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: activeAsg.statusRespons ==
                              AssignmentResponseStatus.ditolak
                          ? ElwafyColors.dangerRed
                          : ElwafyColors.primaryBlue,
                    ),
                  ),
                ),
              ],
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FormatHelper.rupiah(reservation.totalSnapshot),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Kelola & Tugaskan',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HALAMAN PENUH DETAIL RESERVASI & PENUGASAN PETUGAS (LEGA & RESPONSIF DI MOBILE)
class _AdminReservationDetailScreen extends StatefulWidget {
  final ElwafyStore store;
  final String reservationId;

  const _AdminReservationDetailScreen({
    required this.store,
    required this.reservationId,
  });

  @override
  State<_AdminReservationDetailScreen> createState() =>
      _AdminReservationDetailScreenState();
}

class _AdminReservationDetailScreenState
    extends State<_AdminReservationDetailScreen> {
  late AppUser _selectedPetugas;
  late TextEditingController _paymentNoteCtrl;
  late TextEditingController _jamCtrl;

  Reservation get _res => widget.store.reservations
      .firstWhere((r) => r.id == widget.reservationId);

  @override
  void initState() {
    super.initState();
    final staff = [
      ...widget.store.mitraList,
      ...widget.store.karyawanList,
    ];
    _selectedPetugas = staff.first;
    _paymentNoteCtrl =
        TextEditingController(text: _res.catatanPembayaranInternal);
    _jamCtrl = TextEditingController(text: _res.jamDiminta);
  }

  @override
  void dispose() {
    _paymentNoteCtrl.dispose();
    _jamCtrl.dispose();
    super.dispose();
  }

  Future<void> _hubungiCustomerViaWa(Reservation res) async {
    String cleanPhone = res.waPemesanSnapshot.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final text =
        'Halo Bunda *${res.namaPemesanSnapshot}*, kami dari Admin *Elwafy Care* mengonfirmasi reservasi *${res.nomorReservasi}* (${res.namaPenerimaLayanan}) pada ${FormatHelper.tanggalIndo(res.tanggalDiminta)} pukul ${res.jamDiminta}.';
    final url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _kirimTautanKeWaMitra(
    Reservation res,
    TaskAssignment asg,
  ) async {
    final mitra = widget.store.users
        .where((u) => u.id == asg.assignedUserId)
        .firstOrNull;
    String cleanPhone =
        (mitra?.whatsapp ?? '081265001122').replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final msg = widget.store.buildMitraWhatsAppInviteMessage(res, asg);
    final url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(msg)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final res = _res;
        final statusColor = ElwafyTheme.statusColor(res.statusReservasi);
        final allPetugas = [
          ...widget.store.mitraList,
          ...widget.store.karyawanList,
        ];
        final activeAsg = res.activeAssignment;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: ElwafyColors.navyDark,
            title: Text(
              res.nomorReservasi,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Kartu Status & Data Customer
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          res.statusReservasi.label,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pemesan: ${res.namaPemesanSnapshot}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      Text('No. WA: ${res.waPemesanSnapshot}'),
                      Text(
                        'Pasien: ${res.namaPenerimaLayanan} (${res.usiaPenerima})',
                      ),
                      if (res.catatanKhusus.isNotEmpty)
                        Text('Catatan: ${res.catatanKhusus}'),
                      const Divider(height: 20),
                      Text(
                        'Mode: ${res.mode.label}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (res.mode == ServiceMode.homecare) ...[
                        Text('Wilayah: ${res.wilayahHomecare ?? "-"}'),
                        Text('Alamat: ${res.alamatLengkap ?? "-"}'),
                        if ((res.patokan ?? '').isNotEmpty)
                          Text('Patokan: ${res.patokan}'),
                      ] else
                        Text('Outlet: ${res.outletNamaSnapshot ?? "-"}'),
                      const Divider(height: 20),
                      const Text(
                        'Item Layanan & Harga:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      for (final item in res.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '• ${item.qty}x ${item.namaItemSnapshot}',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                              Text(
                                FormatHelper.rupiah(item.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Harga: ${FormatHelper.rupiah(res.totalSnapshot)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _hubungiCustomerViaWa(res),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ElwafyColors.whatsappGreen,
                            ),
                            icon: const Icon(Icons.chat_rounded, size: 16),
                            label: const Text('Chat WA Customer'),
                          ),
                          if ((res.tautanPeta ?? '').isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse(res.tautanPeta!),
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(Icons.map_rounded, size: 16),
                              label: const Text('Buka Maps'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Konfirmasi / Penyesuaian Jadwal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konfirmasi Jadwal Kunjungan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tanggal: ${FormatHelper.tanggalIndo(res.tanggalDiminta)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _jamCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Jam Layanan',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                widget.store.updateReservationStatusByAdmin(
                                  reservationId: res.id,
                                  newStatus:
                                      ReservationStatus.perluPenyesuaianJadwal,
                                  updatedJam: _jamCtrl.text.trim(),
                                  catatan:
                                      'Menawarkan penyesuaian jam (${_jamCtrl.text.trim()}) via WhatsApp.',
                                );
                              },
                              child: const Text('Ubah Jadwal'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                widget.store.updateReservationStatusByAdmin(
                                  reservationId: res.id,
                                  newStatus: ReservationStatus.terkonfirmasi,
                                  updatedJam: _jamCtrl.text.trim(),
                                  catatan:
                                      'Jadwal dikonfirmasi pukul ${_jamCtrl.text.trim()}.',
                                );
                              },
                              child: const Text('Setujui Jadwal'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Penugasan Mitra / Karyawan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tugaskan Mitra Terdekat / Karyawan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<AppUser>(
                        initialValue: _selectedPetugas,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Petugas',
                        ),
                        items: allPetugas.map((u) {
                          return DropdownMenuItem(
                            value: u,
                            child: Text(
                              '${u.nama} (${u.wilayah})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedPetugas = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final asg = widget.store.assignPetugas(
                              reservationId: res.id,
                              petugas: _selectedPetugas,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _selectedPetugas.role == UserRole.karyawan
                                      ? 'Ditugaskan ke ${_selectedPetugas.nama}!'
                                      : 'Token tugas dibuat: ${asg.tokenTugasHash}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment_ind_rounded),
                          label: Text(
                            _selectedPetugas.role == UserRole.karyawan
                                ? 'Assign Karyawan Internal'
                                : 'Assign Mitra & Buat Link Tugas',
                          ),
                        ),
                      ),
                      if (activeAsg != null &&
                          activeAsg.assignedUserRole == UserRole.mitra) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ElwafyColors.softBlueCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Token Mitra: ${activeAsg.tokenTugasHash}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ElwafyColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Untuk: ${activeAsg.assignedUserName}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _kirimTautanKeWaMitra(res, activeAsg),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ElwafyColors.whatsappGreen,
                                  ),
                                  icon: const Icon(
                                    Icons.share_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Bagikan Link ke WA Mitra'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final mitra = widget.store.users
                                        .where(
                                          (u) =>
                                              u.id == activeAsg.assignedUserId,
                                        )
                                        .firstOrNull;
                                    if (mitra != null) {
                                      widget.store.switchActiveMitra(mitra);
                                    }
                                    Navigator.pop(context);
                                    widget.store.setPortalTab(
                                      2,
                                      taskToken: activeAsg.tokenTugasHash,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Buka di Portal Mitra (Simulasi)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Catatan Pembayaran & Selesai
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Pembayaran & Status Akhir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _paymentNoteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Bukti Transfer (WA)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            widget.store.updateInternalPaymentNote(
                              res.id,
                              _paymentNoteCtrl.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Catatan pembayaran disimpan.'),
                              ),
                            );
                          },
                          child: const Text('Simpan Catatan'),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                widget.store.updateReservationStatusByAdmin(
                                  reservationId: res.id,
                                  newStatus: ReservationStatus.selesai,
                                  catatan: 'Layanan selesai dikerjakan.',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ElwafyColors.successGreen,
                              ),
                              child: const Text('Tandai Selesai'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                widget.store.updateReservationStatusByAdmin(
                                  reservationId: res.id,
                                  newStatus: ReservationStatus.dibatalkan,
                                  catatan: 'Reservasi dibatalkan.',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ElwafyColors.dangerRed,
                                side: const BorderSide(
                                  color: ElwafyColors.dangerRed,
                                ),
                              ),
                              child: const Text('Batalkan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Riwayat Perubahan Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Status Reservasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      const Divider(height: 18),
                      for (final h in res.statusHistory.reversed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${h.statusSebelum?.label ?? "Baru"} ➔ ${h.statusSesudah.label}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: ElwafyColors.primaryBlue,
                                ),
                              ),
                              Text(
                                h.catatan,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${h.actorName} • ${FormatHelper.tanggalWaktuIndo(h.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ElwafyColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
