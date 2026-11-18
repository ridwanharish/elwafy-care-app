import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';

class ElwafyPoinScreen extends StatelessWidget {
  final ElwafyStore store;

  const ElwafyPoinScreen({super.key, required this.store});

  Future<void> _sendRedemptionToAdminWa(
    BuildContext context,
    RewardRedemption rdm,
  ) async {
    String cleanPhone = store.settings.nomorWaAdmin.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final text =
        'Halo Admin *Elwafy Care* 👋\nSaya ingin memvalidasi penukaran hadiah *Elwafy Poin*:\n\n'
        '🎁 *KODE PENUKARAN: ${rdm.kode}*\n'
        '• Nama Pelanggan: ${rdm.namaPemilik}\n'
        '• Hadiah: ${rdm.rewardNama}\n'
        '• Poin Ditukar: ${rdm.poin} Poin\n'
        '• Status: ${rdm.status.label}\n\n'
        'Mohon bantu validasi saat kunjungan Homecare / di Outlet Sei Mencirim ya Kak. Terima kasih! 🙏';
    final url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _confirmRedeemDialog(BuildContext context, RewardItem reward) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Tukar Elwafy Poin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tukar ${reward.poin} Poin dengan hadiah resmi berikut?',
                style: const TextStyle(
                  fontSize: 13,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ElwafyColors.babyBlueBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ElwafyColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Text(reward.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${reward.poin} Poin • Sisa Stok: ${reward.stok}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Catatan: Sistem akan menerbitkan Kode Penukaran unik (ELW-RDM-XXXX) dengan status "Menunggu validasi". Hadiah diserahkan setelah kode divalidasi oleh Admin Elwafy Care.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: ElwafyColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final result = store.redeemElwafyReward(reward.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success
                        ? ElwafyColors.successGreen
                        : ElwafyColors.dangerRed,
                  ),
                );
                if (result.success && result.redemption != null) {
                  _showRedemptionTicketSheet(context, result.redemption!);
                }
              },
              child: const Text('Tukar Sekarang'),
            ),
          ],
        );
      },
    );
  }

  void _showRedemptionTicketSheet(
    BuildContext context,
    RewardRedemption redemption,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: ElwafyColors.primaryBlue,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tiket Penukaran Hadiah Elwafy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ElwafyColors.babyBlueBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ElwafyColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            redemption.kode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ElwafyColors.warningAmber.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              redemption.status.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Text(
                        'Hadiah: ${redemption.rewardNama}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Poin Terkunci: ${redemption.poin} Poin • Pemilik: ${redemption.namaPemilik}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ElwafyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berlaku s/d: ${FormatHelper.tanggalIndo(redemption.expiry)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: ElwafyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tunjukkan kode di atas kepada Admin di Outlet Sei Mencirim atau kirim ke WhatsApp Admin agar hadiah disiapkan:',
                  style: TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _sendRedemptionToAdminWa(context, redemption),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ElwafyColors.whatsappGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Kirim Kode ke WhatsApp Admin'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: redemption.kode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Kode ${redemption.kode} berhasil disalin!',
                          ),
                          backgroundColor: ElwafyColors.primaryBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin Kode Penukaran'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final balance = store.customerPointsBalance;
        final rewards = store.rewards;
        final redemptions = store.redemptions;
        final ledger = store.pointLedger;
        final progressToFreeMassage = (balance / 100.0).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Elwafy Poin & Hadiah Bunda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Kartu Utama Saldo Elwafy Poin
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ElwafyColors.navyDark,
                      ElwafyColors.primaryBlue,
                      ElwafyColors.skyBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ElwafyColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: Color(0xFFFACC15),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Saldo Elwafy Poin Bunda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Member Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$balance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Poin Loyalitas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressToFreeMassage,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFACC15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      balance >= 100
                          ? '🎉 Poin Bunda sudah cukup untuk tukar Gratis 1x Sesi Baby Happy Massage!'
                          : 'Kumpulkan ${100 - balance} Poin lagi untuk Gratis 1x Sesi Baby Happy Massage (100 Poin).',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white70,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Poin tidak bernilai uang/Rupiah dan hanya dapat ditukar dengan produk atau layanan resmi yang disiapkan Elwafy Care melalui validasi kode Admin.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Cara Mendapatkan Poin (Bukan dari Rupiah, tapi dari Layanan Selesai)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cara Mengumpulkan Elwafy Poin:',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: ElwafyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _EarnRuleBox(
                              points: '+20 Poin',
                              label: 'Setiap Layanan\nSelesai',
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _EarnRuleBox(
                              points: '+30 Poin',
                              label: 'Setiap Paket\nLengkap Selesai',
                              color: ElwafyColors.skyBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _EarnRuleBox(
                              points: '+10 Poin',
                              label: 'Produk Add-on\nSelesai',
                              color: ElwafyColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Katalog Hadiah Resmi yang Disiapkan Elwafy Care
              const Text(
                'Tukar Poin dengan Hadiah Resmi Elwafy',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  color: ElwafyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Pilih hadiah yang tersedia, lalu tunjukkan kode penukaran ke Admin untuk validasi:',
                style: TextStyle(
                  fontSize: 12,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              for (final r in rewards) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ElwafyColors.softBlueCard,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                r.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: ElwafyColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.deskripsi,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ElwafyColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.poin} Poin',
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                                Text(
                                  'Stok disiapkan Elwafy: ${r.stok} kuota',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: ElwafyColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: balance >= r.poin && r.stok > 0
                                  ? () => _confirmRedeemDialog(context, r)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                minimumSize: Size.zero,
                              ),
                              icon: const Icon(
                                Icons.card_giftcard_rounded,
                                size: 16,
                              ),
                              label: Text(
                                balance >= r.poin
                                    ? 'Tukar Hadiah'
                                    : 'Kurang ${r.poin - balance} Poin',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),

              // 4. Tiket / Kode Penukaran Saya (Menunggu Validasi / Sudah Diambil)
              const Text(
                'Status Kode Penukaran Saya',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  color: ElwafyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              for (final rdm in redemptions)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _showRedemptionTicketSheet(context, rdm),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                rdm.status == RedemptionStatus.diambil
                                ? ElwafyColors.successGreen.withValues(
                                    alpha: 0.15,
                                  )
                                : rdm.status == RedemptionStatus.ditolak
                                ? ElwafyColors.dangerRed.withValues(alpha: 0.15)
                                : ElwafyColors.softBlueCard,
                            child: Icon(
                              rdm.status == RedemptionStatus.diambil
                                  ? Icons.check_circle_rounded
                                  : rdm.status == RedemptionStatus.ditolak
                                  ? Icons.replay_rounded
                                  : Icons.qr_code_2_rounded,
                              color: rdm.status == RedemptionStatus.diambil
                                  ? ElwafyColors.successGreen
                                  : rdm.status == RedemptionStatus.ditolak
                                  ? ElwafyColors.dangerRed
                                  : ElwafyColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rdm.kode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.5,
                                        color: ElwafyColors.primaryBlue,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            rdm.status ==
                                                RedemptionStatus.diambil
                                            ? ElwafyColors.successGreen
                                                  .withValues(alpha: 0.15)
                                            : rdm.status ==
                                                  RedemptionStatus.ditolak
                                            ? ElwafyColors.dangerRed.withValues(
                                                alpha: 0.15,
                                              )
                                            : ElwafyColors.warningAmber
                                                  .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        rdm.status.label,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              rdm.status ==
                                                  RedemptionStatus.diambil
                                              ? ElwafyColors.successGreen
                                              : rdm.status ==
                                                    RedemptionStatus.ditolak
                                              ? ElwafyColors.dangerRed
                                              : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rdm.rewardNama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${rdm.poin} Poin • Ketuk untuk lihat tiket & kirim WA',
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
                  ),
                ),
              const SizedBox(height: 12),

              // 5. Riwayat Perolehan & Penggunaan Poin
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Mutasi Elwafy Poin',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: ElwafyColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 18),
                      for (final entry in ledger)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(
                                entry.poin >= 0
                                    ? Icons.add_circle_outline_rounded
                                    : Icons.remove_circle_outline_rounded,
                                size: 18,
                                color: entry.poin >= 0
                                    ? ElwafyColors.successGreen
                                    : ElwafyColors.primaryBlue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.deskripsi,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      FormatHelper.tanggalIndo(entry.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: ElwafyColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                entry.poin >= 0
                                    ? '+${entry.poin} Poin'
                                    : '${entry.poin} Poin',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: entry.poin >= 0
                                      ? ElwafyColors.successGreen
                                      : ElwafyColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EarnRuleBox extends StatelessWidget {
  final String points;
  final String label;
  final Color color;

  const _EarnRuleBox({
    required this.points,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            points,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: ElwafyColors.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
