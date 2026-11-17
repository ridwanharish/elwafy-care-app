import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';

class TanyaBidanTab extends StatefulWidget {
  final ElwafyStore store;
  final VoidCallback onJumpToLayananTab;

  const TanyaBidanTab({
    super.key,
    required this.store,
    required this.onJumpToLayananTab,
  });

  @override
  State<TanyaBidanTab> createState() => _TanyaBidanTabState();
}

class _TanyaBidanTabState extends State<TanyaBidanTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'Semua';

  static const List<String> _specialtyTabs = [
    'Semua',
    'Laktasi & Nifas',
    'Batuk & Flu Bayi',
    'Tumbuh Kembang & GTM',
  ];

  static const List<({String label, String prompt, String consultantId})>
  _quickTopics = [
    (
      label: '🤧 Bayi Batuk Pilek',
      prompt:
          'Halo Bidan, bayi saya sedang batuk pilek dan napasnya agak grok-grok. Apa saran perawatannya ya?',
      consultantId: 'cons-2',
    ),
    (
      label: '🤱 ASI Seret / Bengkak',
      prompt:
          'Halo Bidan Elfi, ASI saya agak seret dan payudara terasa kencang. Bagaimana solusinya ya?',
      consultantId: 'cons-1',
    ),
    (
      label: '🍽️ Anak Susah Makan (GTM)',
      prompt:
          'Halo Bidan, anak saya akhir-akhir ini susah makan (GTM). Apakah bisa dibantu dengan pijat Tuina?',
      consultantId: 'cons-3',
    ),
    (
      label: '😴 Bayi Rewel & Kembung',
      prompt:
          'Halo Bidan, bayi saya sering ngulet, kembung, dan rewel saat malam. Layanan apa yang cocok?',
      consultantId: 'cons-1',
    ),
    (
      label: '🤰 Pegal Saat Hamil',
      prompt:
          'Halo Bidan, saya sedang hamil trimester 3 dan sering nyeri pinggang. Apakah aman dipijat?',
      consultantId: 'cons-4',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MidwifeConsultant> get _filteredConsultants {
    return widget.store.consultants.where((c) {
      if (_selectedSpecialty != 'Semua' &&
          c.kategoriSpesialis != _selectedSpecialty) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = c.nama.toLowerCase().contains(q);
        final matchSpec = c.spesialis.toLowerCase().contains(q);
        final matchTopic = c.topikKeahlian.any(
          (t) => t.toLowerCase().contains(q),
        );
        return matchName || matchSpec || matchTopic;
      }
      return true;
    }).toList();
  }

  void _openChatRoom(
    BuildContext context,
    MidwifeConsultant consultant, {
    String? initialQuestion,
  }) {
    if (initialQuestion != null && initialQuestion.trim().isNotEmpty) {
      widget.store.sendCustomerConsultMessage(consultant.id, initialQuestion);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConsultChatScreen(
          store: widget.store,
          consultant: consultant,
          onJumpToLayananTab: widget.onJumpToLayananTab,
        ),
      ),
    );
  }

  void _showMidwifeProfileSheet(MidwifeConsultant c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 72,
                        height: 84,
                        child: Image.network(
                          c.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: ElwafyColors.softBlueCard,
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: ElwafyColors.primaryBlue,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.nama,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: ElwafyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.spesialis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: ElwafyColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _MidwifeStatBadge(
                                icon: Icons.work_rounded,
                                label: c.pengalaman,
                              ),
                              _MidwifeStatBadge(
                                icon: Icons.thumb_up_alt_rounded,
                                label: c.kepuasanPersen,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _CredentialInfoRow(
                  icon: Icons.verified_user_rounded,
                  title: 'Nomor STR Terdaftar',
                  value: c.nomorStr,
                ),
                const SizedBox(height: 10),
                _CredentialInfoRow(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Sertifikasi & Keahlian Klinis',
                  value: c.sertifikasi,
                ),
                const SizedBox(height: 10),
                _CredentialInfoRow(
                  icon: Icons.location_on_rounded,
                  title: 'Wilayah Praktik & Homecare',
                  value: c.lokasiPraktik,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Topik Konsultasi Utama:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: ElwafyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: c.topikKeahlian.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ElwafyColors.softBlueCard,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓ $t',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openChatRoom(context, c);
                    },
                    icon: const Icon(Icons.forum_rounded),
                    label: Text('Mulai Chat dengan ${c.nama.split(",").first}'),
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
    final allConsultants = widget.store.consultants;
    final filtered = _filteredConsultants;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        // 1. Kolom Pencarian Bidan / Keluhan ala Halodoc
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari bidan atau keluhan (batuk, ASI, GTM)...',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: ElwafyColors.primaryBlue,
              size: 20,
            ),
            isDense: true,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.clear_rounded, size: 18),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // 2. Banner 3 Jaminan Konsultasi Bidan ala Halodoc (Tema Biru Elwafy)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ElwafyColors.primaryBlue, ElwafyColors.skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: _ConsultGuaranteeItem(
                  icon: Icons.verified_user_rounded,
                  label: 'Bidan Ber-STR\n& Tersertifikasi',
                ),
              ),
              Expanded(
                child: _ConsultGuaranteeItem(
                  icon: Icons.bolt_rounded,
                  label: 'Tanya Jawab\nCepat & Gratis',
                ),
              ),
              Expanded(
                child: _ConsultGuaranteeItem(
                  icon: Icons.medical_information_rounded,
                  label: 'Rekomendasi\nTerapi Tepat',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Pilihan Topik Keluhan Cepat (1-Tap Langsung Dijawab)
        const Text(
          'Keluhan yang Sering Ditanyakan Bunda:',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: ElwafyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickTopics.map((topic) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: ElwafyColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                  label: Text(
                    topic.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  onPressed: () {
                    final c = allConsultants.firstWhere(
                      (item) => item.id == topic.consultantId,
                      orElse: () => allConsultants.first,
                    );
                    _openChatRoom(context, c, initialQuestion: topic.prompt);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // 4. Filter Spesialisasi Bidan (Pill Horizontal ala Halodoc)
        const Text(
          'Pilih Bidan Siaga Elwafy Care',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            color: ElwafyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Konsultasikan keluhan Bunda & buah hati sebelum booking Homecare/Outlet',
          style: TextStyle(fontSize: 12, color: ElwafyColors.textSecondary),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _specialtyTabs.map((spec) {
              final selected = _selectedSpecialty == spec;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedSpecialty = spec),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? ElwafyColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ElwafyColors.primaryBlue),
                    ),
                    child: Text(
                      spec,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : ElwafyColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 5. Daftar Kartu Bidan Gaya Halodoc ("Chat dengan Dokter")
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 42,
                  color: ElwafyColors.textSecondary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bidan tidak ditemukan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedSpecialty = 'Semua';
                    });
                  },
                  child: const Text('Tampilkan Semua Bidan'),
                ),
              ],
            ),
          )
        else
          for (final c in filtered) ...[
            _HalodocMidwifeCard(
              consultant: c,
              onTapChat: () => _openChatRoom(context, c),
              onTapProfile: () => _showMidwifeProfileSheet(c),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ConsultGuaranteeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConsultGuaranteeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// KARTU BIDAN GAYA HALODOC "CHAT DENGAN DOKTER" (FOTO POTRET KIRI + BADGE PENGALAMAN/RATING + HARGA CORET GRATIS + TOMBOL CHAT BIRU)
class _HalodocMidwifeCard extends StatelessWidget {
  final MidwifeConsultant consultant;
  final VoidCallback onTapChat;
  final VoidCallback onTapProfile;

  const _HalodocMidwifeCard({
    required this.consultant,
    required this.onTapChat,
    required this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTapProfile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kiri: Foto Potret Dummy Bidan + Status Online
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 82,
                      height: 104,
                      child: Image.network(
                        consultant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: ElwafyColors.softBlueCard,
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: ElwafyColors.primaryBlue,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: ElwafyColors.successGreen,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: ElwafyColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Kanan: Informasi Bidan, Badge Pengalaman/Kepuasan, Harga & Tombol Chat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultant.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: ElwafyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consultant.spesialis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ElwafyColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 2 Badge Abu-abu/Biru Muda ala Halodoc (Tahun Pengalaman & % Kepuasan)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MidwifeStatBadge(
                          icon: Icons.work_rounded,
                          label: consultant.pengalaman,
                        ),
                        _MidwifeStatBadge(
                          icon: Icons.thumb_up_alt_rounded,
                          label: consultant.kepuasanPersen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Baris Bawah: Harga Gratis (Coret Rp 25.000) + Tombol Chat Biru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Biaya Konsultasi',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ElwafyColors.textSecondary,
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Gratis',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: ElwafyColors.primaryBlue,
                                    ),
                                  ),
                                  Text(
                                    'Rp 25.000',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onTapChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElwafyColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 9,
                            ),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Chat',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MidwifeStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MidwifeStatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _CredentialInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ElwafyColors.primaryBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ElwafyColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// LAYAR CHAT KONSULTASI INTERAKTIF ALA HALODOC
class ConsultChatScreen extends StatefulWidget {
  final ElwafyStore store;
  final MidwifeConsultant consultant;
  final VoidCallback onJumpToLayananTab;

  const ConsultChatScreen({
    super.key,
    required this.store,
    required this.consultant,
    required this.onJumpToLayananTab,
  });

  @override
  State<ConsultChatScreen> createState() => _ConsultChatScreenState();
}

class _ConsultChatScreenState extends State<ConsultChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _msgCtrl.text).trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    widget.store.sendCustomerConsultMessage(widget.consultant.id, text);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openDirectWhatsApp() async {
    String cleanPhone = widget.consultant.whatsapp.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final text =
        'Halo *${widget.consultant.nama}*, saya ingin berkonsultasi mengenai perawatan ibu/bayi di *Elwafy Care*.';
    final url = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final thread = widget.store.getThreadForConsultant(
          widget.consultant.id,
        );

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Image.network(
                      widget.consultant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.white24,
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.consultant.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '● Online • ${widget.consultant.nomorStr}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFFA7F3D0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: _openDirectWhatsApp,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text(
                  'Chat WA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Banner Privasi Medis ala Halodoc
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                color: const Color(0xFFE0F2FE),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 15,
                      color: ElwafyColors.primaryBlue,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Konsultasi dijawab oleh Bidan ber-STR resmi Elwafy Care Medan.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(14),
                  itemCount: thread.messages.length,
                  itemBuilder: (context, i) {
                    final msg = thread.messages[i];
                    final isMe = msg.isFromCustomer;
                    final recommendedItem = msg.recommendedCatalogItemId != null
                        ? widget.store.catalog
                              .where(
                                (c) => c.id == msg.recommendedCatalogItemId,
                              )
                              .firstOrNull
                        : null;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: const BoxConstraints(maxWidth: 330),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isMe ? ElwafyColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                          border: isMe
                              ? null
                              : Border.all(
                                  color: ElwafyColors.primaryBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  msg.senderName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                              ),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isMe
                                    ? Colors.white
                                    : ElwafyColors.textPrimary,
                              ),
                            ),
                            if (recommendedItem != null) ...[
                              const SizedBox(height: 12),
                              // Kartu Catatan Rekomendasi Terapi Digital ala Resep Halodoc
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ElwafyColors.primaryBlue.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCEBFF),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(11),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.assignment_turned_in_rounded,
                                            size: 14,
                                            color: ElwafyColors.primaryBlue,
                                          ),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'CATATAN REKOMENDASI TERAPI BIDAN',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: ElwafyColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recommendedItem.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12.5,
                                              color: ElwafyColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${recommendedItem.durasiMenit ?? 45} Menit • ${recommendedItem.bisaHomecare ? "Bisa Homecare ke Rumah" : "Layanan Outlet"}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: ElwafyColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            FormatHelper.rupiah(
                                              recommendedItem.harga,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: ElwafyColors.primaryBlue,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                widget.store.addToCart(
                                                  recommendedItem.id,
                                                );
                                                Navigator.pop(context);
                                                widget.onJumpToLayananTab();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '${recommendedItem.nama} ditambahkan ke keranjang!',
                                                    ),
                                                    backgroundColor:
                                                        ElwafyColors
                                                            .primaryBlue,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 10,
                                                    ),
                                                minimumSize: Size.zero,
                                              ),
                                              icon: const Icon(
                                                Icons.add_shopping_cart_rounded,
                                                size: 15,
                                              ),
                                              label: const Text(
                                                'Ambil & Jadwalkan Terapi Ini',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bar Pertanyaan Cepat
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickAskButton(
                        label: 'Bayi batuk pilek',
                        onTap: () => _sendMessage(
                          'Bayi saya sedang batuk pilek dan grok-grok, terapi apa yang cocok ya Bidan?',
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QuickAskButton(
                        label: 'ASI seret / bengkak',
                        onTap: () => _sendMessage(
                          'ASI saya agak seret setelah melahirkan, apakah bisa pijat laktasi ke rumah?',
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QuickAskButton(
                        label: 'Anak susah makan (GTM)',
                        onTap: () => _sendMessage(
                          'Anak saya susah makan (GTM), apakah ada pijat nafsu makan?',
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QuickAskButton(
                        label: 'Bawa kolam renang ke rumah?',
                        onTap: () => _sendMessage(
                          'Kalau pesan Baby Swim Homecare apakah kolamnya dibawa oleh terapis?',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Kolom Input Chat
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Tulis pertanyaan keluhan ke Bidan...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _sendMessage,
                        style: IconButton.styleFrom(
                          backgroundColor: ElwafyColors.primaryBlue,
                        ),
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
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

class _QuickAskButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAskButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: ElwafyColors.softBlueCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: ElwafyColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

/// HALAMAN BACA ARTIKEL / BERITA KESEHATAN PENUH
class ArticleReaderScreen extends StatelessWidget {
  final ElwafyStore store;
  final HealthArticle article;
  final VoidCallback onSelectRelatedService;
  final VoidCallback onJumpToConsult;

  const ArticleReaderScreen({
    super.key,
    required this.store,
    required this.article,
    required this.onSelectRelatedService,
    required this.onJumpToConsult,
  });

  @override
  Widget build(BuildContext context) {
    final relatedItem = article.relatedCatalogItemId != null
        ? store.catalog
              .where((c) => c.id == article.relatedCatalogItemId)
              .firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edukasi & Berita Elwafy Care',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Ilustrasi / Foto Dummy Artikel di bagian atas pembaca
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ElwafyColors.primaryBlue,
                            ElwafyColors.skyBlue,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.child_care_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ElwafyColors.softBlueCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.kategori,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: ElwafyColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.judul,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: ElwafyColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ditulis oleh ${article.penulis} • ${FormatHelper.tanggalIndo(article.tanggalPublikasi)} • ⏱ ${article.waktuBacaMenit} mnt baca',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ElwafyColors.textSecondary,
                        ),
                      ),
                      const Divider(height: 24),
                      for (final p in article.isiParagraf)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: ElwafyColors.textPrimary,
                            ),
                          ),
                        ),
                      if (article.poinPenting.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ElwafyColors.babyBlueBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ElwafyColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 Poin Penting untuk Bunda:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: ElwafyColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (final pt in article.poinPenting)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: ElwafyColors.skyBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          pt,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rekomendasi Layanan Terkait Artikel
          if (relatedItem != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perawatan Elwafy Terkait Artikel Ini:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      relatedItem.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatHelper.rupiah(relatedItem.harga),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onJumpToConsult();
                            },
                            icon: const Icon(Icons.forum_outlined, size: 16),
                            label: const Text('Tanya Bidan'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              store.addToCart(relatedItem.id);
                              Navigator.pop(context);
                              onSelectRelatedService();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${relatedItem.nama} masuk ke keranjang!',
                                  ),
                                  backgroundColor: ElwafyColors.primaryBlue,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                            ),
                            label: const Text('+ Pesan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
