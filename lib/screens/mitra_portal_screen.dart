import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';

class MitraPortalScreen extends StatefulWidget {
  final ElwafyStore store;

  const MitraPortalScreen({
    super.key,
    required this.store,
  });

  @override
  State<MitraPortalScreen> createState() => _MitraPortalScreenState();
}

class _MitraPortalScreenState extends State<MitraPortalScreen> {
  int _mitraNavIndex = 0; // 0 = Tugas Saya, 1 = Tautan WA, 2 = Profil Mitra
  late final TextEditingController _tokenCtrl;

  @override
  void initState() {
    super.initState();
    _tokenCtrl = TextEditingController(
      text: widget.store.openedTaskToken ?? 'TKN-ELW-9942A7B1',
    );
  }

  @override
  void didUpdateWidget(covariant MitraPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.store.openedTaskToken != null &&
        widget.store.openedTaskToken != _tokenCtrl.text) {
      _tokenCtrl.text = widget.store.openedTaskToken!;
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  void _showRejectReasonDialog(Reservation res, TaskAssignment asg) {
    final reasons = [
      'Sedang menangani pasien lain pada jam yang sama',
      'Jarak lokasi terlalu jauh dari posisi saat ini',
      'Kondisi kesehatan kurang fit / sedang berhalangan',
      'Alat terapi khusus sedang dipakai',
    ];
    String selectedReason = reasons.first;
    final customReasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text(
                'Tolak Tugas (Wajib Alasan)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih alasan penolakan agar Admin dapat menugaskan mitra lain:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: ElwafyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final r in reasons)
                      InkWell(
                        onTap: () => setModalState(() => selectedReason = r),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selectedReason == r
                                ? ElwafyColors.softBlueCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedReason == r
                                  ? ElwafyColors.primaryBlue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selectedReason == r
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                size: 18,
                                color: ElwafyColors.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: customReasonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan (Opsional)',
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
                    final extra = customReasonCtrl.text.trim();
                    final finalReason = extra.isEmpty
                        ? selectedReason
                        : '$selectedReason ($extra)';
                    widget.store.respondToMitraTask(
                      reservationId: res.id,
                      assignmentId: asg.id,
                      terima: false,
                      alasanPenolakan: finalReason,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Penolakan tercatat & Admin menerima notifikasi Telegram.',
                        ),
                        backgroundColor: ElwafyColors.dangerRed,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElwafyColors.dangerRed,
                  ),
                  child: const Text('Kirim Penolakan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _acceptTask(Reservation res, TaskAssignment asg) {
    widget.store.respondToMitraTask(
      reservationId: res.id,
      assignmentId: asg.id,
      terima: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tugas diterima! Status diperbarui & Admin diberitahu via Telegram.',
        ),
        backgroundColor: ElwafyColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMitra = widget.store.loggedInMitra;
    final myTasks = <({Reservation res, TaskAssignment asg})>[];
    if (activeMitra != null) {
      for (final r in widget.store.reservations) {
        for (final a in r.assignments.reversed) {
          if (a.assignedUserId == activeMitra.id) {
            myTasks.add((res: r, asg: a));
            break;
          }
        }
      }
    }

    final waitingCount = myTasks
        .where(
          (t) => t.asg.statusRespons == AssignmentResponseStatus.menunggu,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ElwafyColors.primaryBlue,
        titleSpacing: 16,
        title: Row(
          children: [
            const ElwafyLogo(size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Portal Mitra Elwafy',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    activeMitra != null
                        ? activeMitra.nama
                        : 'Sesi Belum Login',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
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
        index: _mitraNavIndex,
        children: [
          _buildTugasSayaTab(activeMitra, myTasks),
          _buildTautanWaTab(),
          _buildProfilMitraTab(activeMitra),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mitraNavIndex,
        onDestinationSelected: (idx) => setState(() => _mitraNavIndex = idx),
        backgroundColor: Colors.white,
        indicatorColor: ElwafyColors.softBlueCard,
        height: 66,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: waitingCount > 0,
              label: Text('$waitingCount'),
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: waitingCount > 0,
              label: Text('$waitingCount'),
              child: const Icon(
                Icons.assignment_rounded,
                color: ElwafyColors.primaryBlue,
              ),
            ),
            label: 'Tugas Saya',
          ),
          const NavigationDestination(
            icon: Icon(Icons.link_rounded),
            selectedIcon: Icon(
              Icons.link_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Tautan WA',
          ),
          const NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(
              Icons.badge_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Akun Mitra',
          ),
        ],
      ),
    );
  }

  // TAB 0: DAFTAR TUGAS SAYA
  Widget _buildTugasSayaTab(
    AppUser? activeMitra,
    List<({Reservation res, TaskAssignment asg})> myTasks,
  ) {
    if (activeMitra == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: ElwafyColors.primaryBlue,
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda Belum Login ke Portal Mitra',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan masuk ke akun Mitra terlebih dahulu di menu Akun Mitra untuk melihat daftar penugasan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _mitraNavIndex = 2),
                child: const Text('Pilih Akun Mitra'),
              ),
            ],
          ),
        ),
      );
    }

    if (myTasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada penugasan untuk akun Anda saat ini.',
            style: TextStyle(color: ElwafyColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: myTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final t = myTasks[i];
        return _CleanMitraTaskCard(
          reservation: t.res,
          assignment: t.asg,
          onAccept: () => _acceptTask(t.res, t.asg),
          onReject: () => _showRejectReasonDialog(t.res, t.asg),
        );
      },
    );
  }

  // TAB 1: PINTU MASUK TAUTAN TUGAS DARI WHATSAPP (VALIDASI TOKEN)
  Widget _buildTautanWaTab() {
    final validation = widget.store.validateMitraTaskToken(_tokenCtrl.text);

    final allTokens = <({String token, String ownerName})>[];
    for (final r in widget.store.reservations) {
      for (final a in r.assignments) {
        if (a.assignedUserRole == UserRole.mitra) {
          allTokens.add(
            (token: a.tokenTugasHash, ownerName: a.assignedUserName),
          );
        }
      }
    }

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
                  'Verifikasi Tautan Tugas WhatsApp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sistem memeriksa login, masa berlaku token, dan memastikan tugas memang milik mitra yang sedang aktif.',
                  style: TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenCtrl,
                  onChanged: (v) {
                    widget.store.setOpenedTaskToken(v);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kode Token dari Link WhatsApp',
                    prefixIcon: Icon(Icons.key_rounded),
                  ),
                ),
                if (allTokens.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: allTokens.map((t) {
                      return ActionChip(
                        label: Text(
                          '${t.token} (${t.ownerName.split(",").first})',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () {
                          _tokenCtrl.text = t.token;
                          widget.store.setOpenedTaskToken(t.token);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: validation.valid
                        ? ElwafyColors.successGreen.withValues(alpha: 0.1)
                        : ElwafyColors.dangerRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: validation.valid
                          ? ElwafyColors.successGreen
                          : ElwafyColors.dangerRed,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        validation.valid
                            ? Icons.verified_rounded
                            : Icons.gpp_bad_rounded,
                        color: validation.valid
                            ? ElwafyColors.successGreen
                            : ElwafyColors.dangerRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          validation.message,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: validation.valid
                                ? const Color(0xFF065F46)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (validation.valid &&
            validation.reservation != null &&
            validation.assignment != null) ...[
          const SizedBox(height: 12),
          _CleanMitraTaskCard(
            reservation: validation.reservation!,
            assignment: validation.assignment!,
            onAccept: () => _acceptTask(
              validation.reservation!,
              validation.assignment!,
            ),
            onReject: () => _showRejectReasonDialog(
              validation.reservation!,
              validation.assignment!,
            ),
          ),
        ],
      ],
    );
  }

  // TAB 2: PROFIL & GANTI AKUN MITRA
  Widget _buildProfilMitraTab(AppUser? activeMitra) {
    final mitraAccounts = widget.store.mitraList;

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
                  'Pilih Sesi Login Mitra Homecare',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gunakan pilihan di bawah ini untuk berpindah akun Mitra saat mendemokan validasi hak akses:',
                  style: TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final m in mitraAccounts)
                  InkWell(
                    onTap: () => widget.store.switchActiveMitra(m),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: activeMitra?.id == m.id
                            ? ElwafyColors.softBlueCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeMitra?.id == m.id
                              ? ElwafyColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            activeMitra?.id == m.id
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: ElwafyColors.primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  'Wilayah: ${m.wilayah}',
                                  style: const TextStyle(
                                    fontSize: 12,
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
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => widget.store.switchActiveMitra(null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ElwafyColors.dangerRed,
                      side: const BorderSide(color: ElwafyColors.dangerRed),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Keluar Sesi (Simulasi Belum Login)'),
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

class _CleanMitraTaskCard extends StatelessWidget {
  final Reservation reservation;
  final TaskAssignment assignment;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _CleanMitraTaskCard({
    required this.reservation,
    required this.assignment,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting =
        assignment.statusRespons == AssignmentResponseStatus.menunggu;
    final isAccepted =
        assignment.statusRespons == AssignmentResponseStatus.diterima;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    fontSize: 15,
                    color: ElwafyColors.primaryBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isWaiting
                        ? ElwafyColors.warningAmber.withValues(alpha: 0.16)
                        : isAccepted
                            ? ElwafyColors.successGreen.withValues(alpha: 0.16)
                            : ElwafyColors.dangerRed.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assignment.statusRespons.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isWaiting
                          ? const Color(0xFFB45309)
                          : isAccepted
                              ? ElwafyColors.successGreen
                              : ElwafyColors.dangerRed,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Text(
              '👶 Pasien: ${reservation.namaPenerimaLayanan} (${reservation.usiaPenerima})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '🗓️ ${FormatHelper.tanggalIndo(reservation.tanggalDiminta)} • ${reservation.jamDiminta}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ElwafyColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '📍 Wilayah: ${reservation.wilayahHomecare ?? reservation.outletNamaSnapshot ?? "-"}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
            if (reservation.mode == ServiceMode.homecare) ...[
              Text(
                '🏠 Alamat: ${reservation.alamatLengkap ?? "-"}',
                style: const TextStyle(fontSize: 12.5),
              ),
              if ((reservation.patokan ?? '').isNotEmpty)
                Text(
                  '🧭 Patokan: ${reservation.patokan}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            for (final item in reservation.items)
              Text(
                '• ${item.qty}x ${item.namaItemSnapshot}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if ((reservation.tautanPeta ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(reservation.tautanPeta!),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.location_on_rounded, size: 16),
                label: const Text('Buka Titik Google Maps'),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ElwafyColors.dangerRed,
                      side: const BorderSide(color: ElwafyColors.dangerRed),
                    ),
                    child: const Text('TOLAK'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ElwafyColors.successGreen,
                    ),
                    child: const Text('TERIMA TUGAS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
