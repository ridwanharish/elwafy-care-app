import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';
import 'elwafy_poin_screen.dart';
import 'tanya_bidan_screen.dart';

class CustomerFlowScreen extends StatefulWidget {
  final ElwafyStore store;

  const CustomerFlowScreen({super.key, required this.store});

  @override
  State<CustomerFlowScreen> createState() => _CustomerFlowScreenState();
}

class _CustomerFlowScreenState extends State<CustomerFlowScreen> {
  // 0 = Beranda (Berita & Quick Menu), 1 = Tanya Bidan, 2 = Layanan (Katalog), 3 = Pesanan, 4 = Akun
  int _customerTab = 0;
  CatalogCategory? _selectedCategory;
  String _searchQuery = '';
  String _selectedArticleCategory = 'Semua';
  late final TextEditingController _catalogSearchCtrl;

  @override
  void initState() {
    super.initState();
    _catalogSearchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _catalogSearchCtrl.dispose();
    super.dispose();
  }

  List<CatalogItem> get _filteredCatalog {
    return widget.store.catalog.where((item) {
      if (!item.statusAktif) return false;
      if (_selectedCategory != null && item.kategori != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.nama.toLowerCase().contains(q) ||
            item.deskripsi.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Color _categoryColor(CatalogCategory cat) {
    switch (cat) {
      case CatalogCategory.baby:
        return ElwafyColors.babyCategory;
      case CatalogCategory.kids:
        return ElwafyColors.kidsCategory;
      case CatalogCategory.mom:
        return ElwafyColors.momCategory;
    }
  }

  IconData _categoryIcon(CatalogCategory cat) {
    switch (cat) {
      case CatalogCategory.baby:
        return Icons.child_friendly_rounded;
      case CatalogCategory.kids:
        return Icons.sentiment_very_satisfied_rounded;
      case CatalogCategory.mom:
        return Icons.pregnant_woman_rounded;
    }
  }

  void _openArticleReader(HealthArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleReaderScreen(
          store: widget.store,
          article: article,
          onSelectRelatedService: () => setState(() => _customerTab = 2),
          onJumpToConsult: () => setState(() => _customerTab = 1),
        ),
      ),
    );
  }

  void _openElwafyPoinScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ElwafyPoinScreen(store: widget.store)),
    );
  }

  void _openCustomerLoginSheet() {
    final current = widget.store.loggedInCustomer;
    final namaCtrl = TextEditingController(
      text: current?.nama ?? 'Bunda Sarah Azzahra',
    );
    final waCtrl = TextEditingController(
      text: current?.whatsapp ?? '081260998877',
    );
    String selectedWilayah =
        current?.wilayah ?? 'Jl. Sei Mencirim, Kec. Sunggal';
    const wilayahList = [
      'Jl. Sei Mencirim, Kec. Sunggal',
      'Medan Krio / Paya Geli, Sunggal',
      'Medan Sunggal / Setiabudi',
      'Medan Helvetia',
      'Medan Johor',
      'Medan Polonia / Baru',
      'Medan Amplas',
      'Medan Denai / Tembung',
      'Medan Marelan',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Masuk / Atur Profil & Lokasi Bunda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ElwafyColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Text(
                      'Data Bunda dan lokasi Homecare akan terisi otomatis (Autofill) saat reservasi:',
                      style: TextStyle(
                        fontSize: 12,
                        color: ElwafyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Bunda',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: waCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp Aktif',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: wilayahList.contains(selectedWilayah)
                          ? selectedWilayah
                          : wilayahList.first,
                      decoration: const InputDecoration(
                        labelText: 'Wilayah / Kecamatan di Medan',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: wilayahList
                          .map(
                            (w) => DropdownMenuItem(
                              value: w,
                              child: Text(
                                w,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedWilayah = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (namaCtrl.text.trim().isEmpty) return;
                          widget.store.loginCustomCustomer(
                            nama: namaCtrl.text.trim(),
                            whatsapp: waCtrl.text.trim().isEmpty
                                ? '081260998877'
                                : waCtrl.text.trim(),
                            wilayah: selectedWilayah,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selamat datang, ${namaCtrl.text.trim()}! Lokasi diset ke $selectedWilayah.',
                              ),
                              backgroundColor: ElwafyColors.primaryBlue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Simpan & Masuk Akun Bunda'),
                      ),
                    ),
                    if (current != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.store.logoutCustomer();
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ElwafyColors.dangerRed,
                            side: const BorderSide(
                              color: ElwafyColors.dangerRed,
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Keluar ke Mode Tamu (Guest)'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openPromoAndVoucherSheet({
    required String title,
    required String subtitle,
    required String voucherCode,
    String? recommendedCatalogId,
  }) {
    final item = recommendedCatalogId != null
        ? widget.store.catalog
              .where((c) => c.id == recommendedCatalogId)
              .firstOrNull
        : null;

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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ElwafyColors.textPrimary,
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
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ElwafyColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ElwafyColors.babyBlueBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ElwafyColors.primaryBlue.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Promo / Benefit Elwafy:',
                            style: TextStyle(
                              fontSize: 11,
                              color: ElwafyColors.textSecondary,
                            ),
                          ),
                          Text(
                            voucherCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: voucherCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kode $voucherCode disalin!'),
                              backgroundColor: ElwafyColors.primaryBlue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Salin'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (item != null) {
                        widget.store.addToCart(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.nama} ditambahkan ke keranjang!',
                            ),
                            backgroundColor: ElwafyColors.primaryBlue,
                          ),
                        );
                      }
                      setState(() => _customerTab = 2);
                    },
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: Text(
                      item != null
                          ? 'Ambil Paket (${item.nama})'
                          : 'Lihat Katalog Layanan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemDetailSheet(CatalogItem item) {
    final catColor = _categoryColor(item.kategori);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: widget.store,
          builder: (ctx, _) {
            final qty = widget.store.cart[item.id] ?? 0;
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${item.kategori.label} Care',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: catColor,
                            ),
                          ),
                        ),
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
                            item.tipe.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                        ),
                        if (item.durasiMenit != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '⏱ ${item.durasiMenit} Menit',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ElwafyColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ElwafyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      FormatHelper.rupiah(item.harga),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.deskripsi,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: ElwafyColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    if (item.manfaat.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Manfaat Layanan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: ElwafyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final m in item.manfaat)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: ElwafyColors.skyBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (qty > 0) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: ElwafyColors.softBlueCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ElwafyColors.primaryBlue,
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      widget.store.decrementFromCart(item.id),
                                  icon: const Icon(
                                    Icons.remove_rounded,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.store.addToCart(item.id),
                                  icon: const Icon(
                                    Icons.add_rounded,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (qty == 0) {
                                widget.store.addToCart(item.id);
                              }
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.shopping_bag_rounded),
                            label: Text(
                              qty == 0
                                  ? 'Tambah ke Keranjang'
                                  : 'Selesai ($qty Dipilih)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: widget.store,
          builder: (ctx, _) {
            final entries = widget.store.cartEntries;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Keranjang Layanan Anda',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Belum ada layanan di keranjang.',
                            style: TextStyle(color: ElwafyColors.textSecondary),
                          ),
                        ),
                      )
                    else ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (_, i) {
                            final item = entries[i].key;
                            final qty = entries[i].value;
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Text(
                                        FormatHelper.rupiah(item.harga * qty),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: ElwafyColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.store.decrementFromCart(item.id),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.store.addToCart(item.id),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: ElwafyColors.primaryBlue,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Estimasi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            FormatHelper.rupiah(widget.store.totalCartPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openStepByStepCheckout();
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text('Lanjut Isi Jadwal Reservasi'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openStepByStepCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _CustomerCheckoutWizardScreen(
          store: widget.store,
          onReservationCreated: (res) {
            Navigator.of(ctx).pop();
            setState(() => _customerTab = 3); // Pindah ke tab Pesanan
            _showConfirmationDialog(res);
          },
        ),
      ),
    );
  }

  void _showConfirmationDialog(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ReservationConfirmationSheet(
        store: widget.store,
        reservation: reservation,
      ),
    );
  }

  void _showAdminLoginDialog() {
    final emailCtrl = TextEditingController(text: 'admin@elwafy.care');
    final passCtrl = TextEditingController(text: 'admin123');
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: ElwafyColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Login Admin Elwafy Care',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masukkan akun pengelola UMKM untuk membuka Dashboard Admin:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: ElwafyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email / Username Admin',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Kata Sandi',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ElwafyColors.dangerRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: ElwafyColors.dangerRed,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMsg!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ElwafyColors.dangerRed,
                                  fontWeight: FontWeight.w600,
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final admin = widget.store.users.firstWhere(
                      (u) => u.role == UserRole.admin,
                    );
                    if (emailCtrl.text.trim().toLowerCase() ==
                            admin.emailOrUsername.toLowerCase() &&
                        passCtrl.text == admin.passwordHash) {
                      Navigator.pop(ctx);
                      widget.store.setPortalTab(1);
                    } else {
                      setModalState(() {
                        errorMsg =
                            'Login gagal! Email atau kata sandi tidak sesuai. Silakan coba masuk kembali.';
                      });
                    }
                  },
                  child: const Text('Masuk Dashboard'),
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
    final totalCartItems = widget.store.totalCartItems;
    final customer = widget.store.loggedInCustomer;
    final currentLocation = customer?.wilayah ?? 'Jl. Sei Mencirim, Sunggal';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(
        // Tombol Back HP: dari tab lain kembali ke Beranda dulu, baru keluar app
        canPop: _customerTab == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _customerTab = 0);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: ElwafyColors.textPrimary,
            elevation: 0,
            scrolledUnderElevation: 1,
            surfaceTintColor: Colors.white,
            titleSpacing: 14,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFEAEFF7)),
            ),
            title: Row(
              children: [
                // Kiri: Avatar + Masuk/Daftar (Persis gaya Halodoc)
                Expanded(
                  child: InkWell(
                    onTap: _openCustomerLoginSheet,
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD6E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: ElwafyColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            customer != null ? customer.nama : 'Masuk/Daftar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: ElwafyColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Kanan: Lokasi + Pin Biru
                InkWell(
                  onTap: _openCustomerLoginSheet,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 115),
                        child: Text(
                          currentLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ElwafyColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.location_on_rounded,
                        color: ElwafyColors.primaryBlue,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _openCartBottomSheet,
                tooltip: 'Keranjang',
                icon: Badge(
                  isLabelVisible: totalCartItems > 0,
                  label: Text('$totalCartItems'),
                  backgroundColor: ElwafyColors.primaryBlue,
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: ElwafyColors.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: IndexedStack(
            index: _customerTab,
            children: [
              _buildBerandaHalodocStyleTab(),
              TanyaBidanTab(
                store: widget.store,
                onJumpToLayananTab: () => setState(() => _customerTab = 2),
              ),
              _buildLayananKatalogTab(),
              _buildPesananSayaTab(),
              _buildAkunDanPortalStafTab(),
            ],
          ),
          bottomNavigationBar: _buildHalodocStyleBottomBar(totalCartItems),
        ),
      ),
    );
  }

  Widget _buildHalodocStyleBottomBar(int totalCartItems) {
    final resCount = widget.store.reservations.length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              Expanded(
                child: _BottomBarNavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  selected: _customerTab == 0,
                  onTap: () => setState(() => _customerTab = 0),
                ),
              ),
              Expanded(
                child: _BottomBarNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  badgeCount: resCount,
                  selected: _customerTab == 3,
                  onTap: () => setState(() => _customerTab = 3),
                ),
              ),
              // Tombol Bulat Tengah ala Halodoc (Tanya Bidan / Konsultasi Cepat)
              SizedBox(
                width: 74,
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _customerTab = 1),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A58CA), Color(0xFF00A8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: ElwafyColors.primaryBlue.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          Text(
                            'Bidan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _BottomBarNavItem(
                  icon: Icons.spa_rounded,
                  label: 'Layanan',
                  badgeCount: totalCartItems,
                  selected: _customerTab == 2,
                  onTap: () => setState(() => _customerTab = 2),
                ),
              ),
              Expanded(
                child: _BottomBarNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  selected: _customerTab == 4,
                  onTap: () => setState(() => _customerTab = 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 0: BERANDA GAYA HALODOC (AMATI, TIRU, MODIFIKASI DENGAN TEMA BIRU ELWAFY CARE)
  Widget _buildBerandaHalodocStyleTab() {
    final allArticles = widget.store.articles;
    final categoryTabs = [
      'Semua',
      'Tumbuh Kembang Bayi',
      'Pernapasan & Imun',
      'Gizi & Nutrisi Anak',
      'Laktasi & Ibu Nifas',
    ];
    final filteredArticles = _selectedArticleCategory == 'Semua'
        ? allArticles
        : allArticles
              .where((a) => a.kategori == _selectedArticleCategory)
              .toList();

    final homecareItems = widget.store.catalog
        .where((c) => c.statusAktif && c.bisaHomecare)
        .toList();
    final totalCartItems = widget.store.totalCartItems;
    final totalCartPrice = widget.store.totalCartPrice;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(0, 14, 0, totalCartItems > 0 ? 96 : 28),
          children: [
            // 1. DUA KARTU PILL ATAS (Mirip "halocoins" & "Family Care BARU" di Halodoc)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _TopPillFeatureCard(
                      title: 'elwafypoin',
                      subtitle: '${widget.store.customerPointsBalance} Poin',
                      icon: Icons.stars_rounded,
                      primaryColor: ElwafyColors.primaryBlue,
                      bgTint: const Color(0xFFF0F7FF),
                      onTap: _openElwafyPoinScreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopPillFeatureCard(
                      title: 'Family Care',
                      badgeText: 'BARU',
                      icon: Icons.family_restroom_rounded,
                      primaryColor: ElwafyColors.skyBlue,
                      bgTint: const Color(0xFFF2FBFF),
                      onTap: () => _openPromoAndVoucherSheet(
                        title: 'Elwafy Family Homecare',
                        subtitle:
                            'Layanan kunjungan Bidan ke rumah untuk perawatan Ibu Nifas/Laktasi sekaligus Pijat Bayi & Kakak dalam 1 kali kunjungan!',
                        voucherCode: 'FAMILYCARE25',
                        recommendedCatalogId: 'cat-mom-1',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. GRID 8 MENU BULAT (2 BARIS x 4 KOLOM PERSIS HALODOC)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Chat dengan\nBidan',
                          icon: Icons.support_agent_rounded,
                          accentColor: ElwafyColors.primaryBlue,
                          badgeColor: const Color(0xFF00A8FF),
                          onTap: () => setState(() => _customerTab = 1),
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Baby & Kids\nSpa',
                          icon: Icons.child_care_rounded,
                          accentColor: const Color(0xFF0284C7),
                          badgeColor: const Color(0xFF38BDF8),
                          onTap: () {
                            setState(() {
                              _selectedCategory = CatalogCategory.baby;
                              _customerTab = 2;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Layanan\nHomecare',
                          icon: Icons.home_work_rounded,
                          accentColor: ElwafyColors.primaryBlue,
                          badgeColor: const Color(0xFF10B981),
                          onTap: () => setState(() => _customerTab = 2),
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Mom &\nLaktasi',
                          icon: Icons.pregnant_woman_rounded,
                          accentColor: const Color(0xFF2563EB),
                          badgeColor: const Color(0xFF60A5FA),
                          onTap: () {
                            setState(() {
                              _selectedCategory = CatalogCategory.mom;
                              _customerTab = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Terapi Batuk\n& Pilek',
                          brandBadgeText: 'elwafyfit',
                          icon: Icons.air_rounded,
                          accentColor: ElwafyColors.primaryBlue,
                          onTap: () {
                            final item = widget.store.catalog
                                .where((c) => c.id == 'cat-baby-3')
                                .firstOrNull;
                            if (item != null) _showItemDetailSheet(item);
                          },
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Tindik Steril\nBayi',
                          brandBadgeText: 'elwafyCare',
                          icon: Icons.verified_rounded,
                          accentColor: ElwafyColors.skyBlue,
                          onTap: () {
                            final item = widget.store.catalog
                                .where((c) => c.id == 'cat-baby-4')
                                .firstOrNull;
                            if (item != null) _showItemDetailSheet(item);
                          },
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Buat Janji\nOutlet',
                          brandBadgeText: 'elwafyVisit',
                          icon: Icons.storefront_rounded,
                          accentColor: const Color(0xFF1D4ED8),
                          onTap: () => setState(() => _customerTab = 2),
                        ),
                      ),
                      Expanded(
                        child: _HalodocCircleMenuIcon(
                          title: 'Lihat Semua',
                          icon: Icons.grid_view_rounded,
                          accentColor: ElwafyColors.primaryBlue,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                              _customerTab = 2;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. SEKSI "Promo Menarik" + BANNER VISUAL DUMMY + BAR KUPON HIJAU
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Promo Menarik',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: ElwafyColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 184,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _PromoBannerCard(
                    assetPath: 'assets/images/promo_banner_1.jpg',
                    onTap: () => _openPromoAndVoucherSheet(
                      title: 'Promo Hemat Kakak-Adik Homecare',
                      subtitle:
                          'Booking perawatan Baby Spa / Massage bersama Kakak dalam satu kunjungan Homecare lebih hemat hingga Rp30.000 + Gratis Roll-On Oil.',
                      voucherCode: 'HEMATBARENG30',
                      recommendedCatalogId: 'cat-baby-2',
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PromoBannerCard(
                    assetPath: 'assets/images/promo_banner_2.jpg',
                    onTap: () => _openPromoAndVoucherSheet(
                      title: 'Paket Bundling Mom & Baby Care',
                      subtitle:
                          'Perawatan lengkap Pijat Nifas & Oksitosin Laktasi untuk Bunda ditambah Pijat Bayi Sehat langsung di rumah Bunda.',
                      voucherCode: 'MOMBUNDLING220',
                      recommendedCatalogId: 'cat-mom-1',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bar Kupon Spesial Hijau (Persis di bawah banner Promo Halodoc)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => _openPromoAndVoucherSheet(
                  title: 'Kupon Spesial Homecare Medan',
                  subtitle:
                      'Gunakan kode kupon di bawah pada catatan reservasi WhatsApp untuk mendapatkan potongan biaya kunjungan Homecare area Sunggal, Medan Johor, Setiabudi & Helvetia!',
                  voucherCode: 'HOMECAREMEDAN15',
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D8A52), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.percent_rounded,
                              size: 16,
                              color: Color(0xFF0D8A52),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Kupon spesial Homecare Medan tersedia untuk Bunda!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Color(0xFF0D8A52),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. SEKSI "Layanan Kesehatan di Rumah" (Kartu Gambar Bergambar Horizontal)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Layanan Kesehatan di Rumah',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: ElwafyColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: homecareItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final item = homecareItems[idx];
                  return _HomecareVisualThumbnailCard(
                    item: item,
                    index: idx,
                    onTap: () => _showItemDetailSheet(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // 5. SEKSI "Baca 100+ Artikel Baru" + TOMBOL "Lihat Semua" + CHIP KATEGORI + KARTU GAMBAR DUMMY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Baca 100+ Artikel Baru',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: ElwafyColors.textPrimary,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedArticleCategory = 'Semua');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ElwafyColors.primaryBlue,
                      side: const BorderSide(color: ElwafyColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chip Filter Kategori Artikel (Persis gaya Pill Halodoc)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final cat in categoryTabs) ...[
                    _HalodocArticleCategoryPill(
                      label: cat,
                      selected: _selectedArticleCategory == cat,
                      onTap: () =>
                          setState(() => _selectedArticleCategory = cat),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Kartu Artikel Horizontal Besar dengan Gambar Dummy di Atas
            SizedBox(
              height: 274,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredArticles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, idx) {
                  final art = filteredArticles[idx];
                  return _HalodocArticleImageCard(
                    article: art,
                    index: idx,
                    onTap: () => _openArticleReader(art),
                  );
                },
              ),
            ),
          ],
        ),

        if (totalCartItems > 0)
          _buildFloatingCartBanner(totalCartItems, totalCartPrice),
      ],
    );
  }

  // TAB 2: LAYANAN KATALOG LENGKAP
  Widget _buildLayananKatalogTab() {
    final totalCartItems = widget.store.totalCartItems;
    final totalCartPrice = widget.store.totalCartPrice;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _catalogSearchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari pijat bayi, laktasi, swim, tindik...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: ElwafyColors.primaryBlue,
                          size: 20,
                        ),
                        isDense: true,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _catalogSearchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.clear_rounded, size: 18),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CategoryPill(
                            label: 'Semua',
                            icon: Icons.apps_rounded,
                            selected: _selectedCategory == null,
                            color: ElwafyColors.primaryBlue,
                            onTap: () =>
                                setState(() => _selectedCategory = null),
                          ),
                          const SizedBox(width: 8),
                          for (final cat in CatalogCategory.values) ...[
                            _CategoryPill(
                              label: cat.label,
                              icon: _categoryIcon(cat),
                              selected: _selectedCategory == cat,
                              color: _categoryColor(cat),
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_filteredCatalog.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: ElwafyColors.textSecondary,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Layanan tidak ditemukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Coba gunakan kata kunci lain atau tampilkan semua kategori.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ElwafyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          _catalogSearchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = null;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset Pencarian & Filter'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  totalCartItems > 0 ? 96 : 24,
                ),
                sliver: SliverList.separated(
                  itemCount: _filteredCatalog.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildCompactCatalogCard(_filteredCatalog[index]);
                  },
                ),
              ),
          ],
        ),
        if (totalCartItems > 0)
          _buildFloatingCartBanner(totalCartItems, totalCartPrice),
      ],
    );
  }

  Widget _buildCompactCatalogCard(CatalogItem item) {
    final qty = widget.store.cart[item.id] ?? 0;
    final catColor = _categoryColor(item.kategori);

    return Card(
      child: InkWell(
        onTap: () => _showItemDetailSheet(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.kategori.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: catColor,
                      ),
                    ),
                  ),
                  if (item.durasiMenit != null)
                    Text(
                      '• ${item.durasiMenit} mnt',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ElwafyColors.textSecondary,
                      ),
                    ),
                  Text(
                    item.bisaHomecare
                        ? '• 🏠 Bisa Homecare'
                        : '• 🏥 Khusus Outlet',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: item.bisaHomecare
                          ? ElwafyColors.successGreen
                          : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.nama,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ElwafyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FormatHelper.rupiah(item.harga),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ElwafyColors.primaryBlue,
                          ),
                        ),
                        const Text(
                          'Ketuk untuk detail layanan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: ElwafyColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (qty == 0)
                    ElevatedButton(
                      onPressed: () => widget.store.addToCart(item.id),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('+ Pilih'),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: ElwafyColors.softBlueCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ElwafyColors.primaryBlue),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                widget.store.decrementFromCart(item.id),
                            icon: const Icon(
                              Icons.remove_rounded,
                              size: 18,
                              color: ElwafyColors.primaryBlue,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '$qty',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ElwafyColors.primaryBlue,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.store.addToCart(item.id),
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: ElwafyColors.primaryBlue,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCartBanner(int totalCartItems, int totalCartPrice) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: InkWell(
        onTap: _openStepByStepCheckout,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ElwafyColors.navyDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ElwafyColors.navyDark.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ElwafyColors.skyBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalCartItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Estimasi Reservasi',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      FormatHelper.rupiah(totalCartPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Lanjut Jadwal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 3: PESANAN SAYA (STATUS RESERVASI & TOMBOL WA)
  Widget _buildPesananSayaTab() {
    final list = widget.store.reservations;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final r = list[index];
        final statusColor = ElwafyTheme.statusColor(r.statusReservasi);

        return Card(
          child: InkWell(
            onTap: () => _showConfirmationDialog(r),
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
                        r.nomorReservasi,
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
                          r.statusReservasi.label,
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
                    '👶 Pasien: ${r.namaPenerimaLayanan} (${r.usiaPenerima})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🗓️ ${FormatHelper.tanggalIndo(r.tanggalDiminta)} • ${r.jamDiminta} (${r.mode.label})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ElwafyColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FormatHelper.rupiah(r.totalSnapshot),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showConfirmationDialog(r),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.chat_rounded, size: 16),
                        label: const Text('Rincian & WhatsApp'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 4: AKUN CUSTOMER & AKSES PORTAL INTERNAL STAF
  Widget _buildAkunDanPortalStafTab() {
    final customer = widget.store.loggedInCustomer;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: ElwafyColors.softBlueCard,
                      child: Icon(
                        customer != null
                            ? Icons.verified_user_rounded
                            : Icons.person_outline_rounded,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer != null
                                ? customer.nama
                                : 'Pelanggan Tamu (Guest)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                          ),
                          Text(
                            customer != null
                                ? 'WA: ${customer.whatsapp} • ${customer.wilayah}'
                                : 'Customer tidak wajib login untuk membuat reservasi.',
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.store.toggleCustomerLogin,
                    icon: Icon(
                      customer != null
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      size: 18,
                    ),
                    label: Text(
                      customer != null
                          ? 'Keluar ke Mode Tamu (Guest)'
                          : 'Masuk Akun Customer (Aktifkan Autofill)',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openElwafyPoinScreen,
                    icon: const Icon(Icons.stars_rounded, size: 18),
                    label: Text(
                      'Elwafy Poin & Tukar Hadiah (${widget.store.customerPointsBalance} Poin)',
                    ),
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
                const Text(
                  'Lokasi Outlet Elwafy Care Medan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                const SizedBox(height: 10),
                for (final o in widget.store.outlets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          size: 18,
                          color: ElwafyColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                o.alamat,
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
                      Icons.admin_panel_settings_rounded,
                      color: ElwafyColors.primaryBlue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Akses Portal Internal UMKM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Khusus pengelola Elwafy Care (Admin) dan bidan terapis (Mitra Homecare):',
                  style: TextStyle(
                    fontSize: 12,
                    color: ElwafyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ElwafyColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: ElwafyColors.softBlueCard,
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Masuk Dashboard Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Kelola reservasi, konfirmasi jadwal & assign mitra',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showAdminLoginDialog,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ElwafyColors.skyBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: ElwafyColors.skyBlue.withValues(
                      alpha: 0.15,
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Masuk Portal Mitra Homecare',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Buka tautan tugas WA, terima atau tolak penugasan',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => widget.store.setPortalTab(2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _BottomBarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? ElwafyColors.primaryBlue : const Color(0xFF94A3B8);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            backgroundColor: ElwafyColors.primaryBlue,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPillFeatureCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData icon;
  final Color primaryColor;
  final Color bgTint;
  final VoidCallback onTap;

  const _TopPillFeatureCard({
    required this.title,
    this.subtitle,
    this.badgeText,
    required this.icon,
    required this.primaryColor,
    required this.bgTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ElwafyColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: bgTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: -8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HalodocCircleMenuIcon extends StatelessWidget {
  final String title;
  final String? brandBadgeText;
  final IconData icon;
  final Color accentColor;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _HalodocCircleMenuIcon({
    required this.title,
    this.brandBadgeText,
    required this.icon,
    required this.accentColor,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEBFF),
                shape: BoxShape.circle,
              ),
              child: brandBadgeText != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          brandBadgeText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: accentColor,
                          ),
                        ),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(icon, color: accentColor, size: 28),
                        if (badgeColor != null)
                          Positioned(
                            top: 11,
                            right: 11,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: ElwafyColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _PromoBannerCard({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 332,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ElwafyColors.primaryBlue.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: ElwafyColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFFDCEBFF),
            child: const Center(
              child: Icon(
                Icons.local_offer_rounded,
                size: 48,
                color: ElwafyColors.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomecareVisualThumbnailCard extends StatelessWidget {
  final CatalogItem item;
  final int index;
  final VoidCallback onTap;

  const _HomecareVisualThumbnailCard({
    required this.item,
    required this.index,
    required this.onTap,
  });

  static const List<String> _dummyHomecarePhotos = [
    'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1544126592-807ade215a0b?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=400&q=80',
  ];

  String _shortHomecareTitle(String fullName) {
    if (fullName.contains('Cough & Cold')) return 'Terapi Batuk & Flu';
    if (fullName.contains('Brain Gym, Swim')) return 'Baby Swim & Spa';
    if (fullName.contains('Baby Happy')) return 'Pijat Bayi Sehat';
    if (fullName.contains('Tindik')) return 'Tindik Steril Bayi';
    if (fullName.contains('Kids Immune')) return 'Pijat Nafsu Makan';
    if (fullName.contains('Postnatal')) return 'Pijat Laktasi & Nifas';
    if (fullName.contains('Prenatal')) return 'Pijat Ibu Hamil';
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _dummyHomecarePhotos[index % _dummyHomecarePhotos.length];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 92,
              width: 112,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [ElwafyColors.primaryBlue, ElwafyColors.skyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        Icons.spa_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 36,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ElwafyColors.primaryBlue.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
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
                        color: ElwafyColors.primaryBlue.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Homecare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _shortHomecareTitle(item.nama),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ElwafyColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HalodocArticleCategoryPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HalodocArticleCategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ElwafyColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ElwafyColors.primaryBlue, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ElwafyColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

class _HalodocArticleImageCard extends StatelessWidget {
  final HealthArticle article;
  final int index;
  final VoidCallback onTap;

  const _HalodocArticleImageCard({
    required this.article,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = article.imageUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 265,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Dummy Artikel di Bagian Atas (Persis gaya kartu artikel Halodoc)
            SizedBox(
              height: 145,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD6E8FF), Color(0xFFB3D8FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.child_care_rounded,
                          size: 54,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${article.waktuBacaMenit} mnt baca',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: ElwafyColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F0FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.kategori,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : ElwafyColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// WIZARD RESERVASI 3 LANGKAH (STEP-BY-STEP)
class _CustomerCheckoutWizardScreen extends StatefulWidget {
  final ElwafyStore store;
  final ValueChanged<Reservation> onReservationCreated;

  const _CustomerCheckoutWizardScreen({
    required this.store,
    required this.onReservationCreated,
  });

  @override
  State<_CustomerCheckoutWizardScreen> createState() =>
      _CustomerCheckoutWizardScreenState();
}

class _CustomerCheckoutWizardScreenState
    extends State<_CustomerCheckoutWizardScreen> {
  int _step = 0;

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  late final TextEditingController _namaPemesanCtrl;
  late final TextEditingController _waPemesanCtrl;
  final TextEditingController _namaPasienCtrl = TextEditingController();
  final TextEditingController _usiaPasienCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  ServiceMode _selectedMode = ServiceMode.homecare;
  String _selectedWilayah = 'Jl. Sei Mencirim, Kec. Sunggal';
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _patokanCtrl = TextEditingController();
  final TextEditingController _gpsCtrl = TextEditingController();
  final TextEditingController _mapsLinkCtrl = TextEditingController();

  late String _selectedOutletId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedJam = '10.00 WIB';

  static const List<String> _daftarWilayahMedan = [
    'Jl. Sei Mencirim, Kec. Sunggal',
    'Medan Krio / Paya Geli, Sunggal',
    'Medan Sunggal / Setiabudi',
    'Medan Helvetia',
    'Medan Johor',
    'Medan Polonia / Baru',
    'Medan Amplas',
    'Medan Denai / Tembung',
    'Medan Marelan',
    'Deli Serdang (Sekitar Medan)',
  ];

  static const List<String> _pilihanSlotJam = [
    '09.00 WIB',
    '10.00 WIB',
    '11.00 WIB',
    '13.00 WIB',
    '14.00 WIB',
    '15.00 WIB',
    '16.30 WIB',
  ];

  @override
  void initState() {
    super.initState();
    final customer = widget.store.loggedInCustomer;
    _namaPemesanCtrl = TextEditingController(text: customer?.nama ?? '');
    _waPemesanCtrl = TextEditingController(text: customer?.whatsapp ?? '');
    if (customer != null) {
      _selectedWilayah = customer.wilayah;
    }
    _selectedOutletId = widget.store.outlets.first.id;
  }

  @override
  void dispose() {
    _namaPemesanCtrl.dispose();
    _waPemesanCtrl.dispose();
    _namaPasienCtrl.dispose();
    _usiaPasienCtrl.dispose();
    _catatanCtrl.dispose();
    _alamatCtrl.dispose();
    _patokanCtrl.dispose();
    _gpsCtrl.dispose();
    _mapsLinkCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (_step1FormKey.currentState?.validate() != true) return;
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_step2FormKey.currentState?.validate() != true) return;
      setState(() => _step = 2);
    } else {
      _submitReservation();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _simulasiAmbilGps() {
    setState(() {
      _gpsCtrl.text = '3.5384, 98.6712';
      _mapsLinkCtrl.text = 'https://maps.google.com/?q=3.5384,98.6712';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinat GPS & link Maps berhasil terisi!'),
        backgroundColor: ElwafyColors.primaryBlue,
      ),
    );
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitReservation() {
    final res = widget.store.createCustomerReservation(
      namaPemesan: _namaPemesanCtrl.text.trim(),
      waPemesan: _waPemesanCtrl.text.trim(),
      namaPenerima: _namaPasienCtrl.text.trim(),
      usiaPenerima: _usiaPasienCtrl.text.trim().isEmpty
          ? '-'
          : _usiaPasienCtrl.text.trim(),
      catatanKhusus: _catatanCtrl.text.trim(),
      mode: _selectedMode,
      outletId: _selectedMode == ServiceMode.outlet ? _selectedOutletId : null,
      alamatLengkap: _selectedMode == ServiceMode.homecare
          ? _alamatCtrl.text.trim()
          : null,
      patokan: _selectedMode == ServiceMode.homecare
          ? _patokanCtrl.text.trim()
          : null,
      wilayahHomecare: _selectedMode == ServiceMode.homecare
          ? _selectedWilayah
          : null,
      koordinatGps: _selectedMode == ServiceMode.homecare
          ? _gpsCtrl.text.trim()
          : null,
      tautanPeta: _selectedMode == ServiceMode.homecare
          ? _mapsLinkCtrl.text.trim()
          : null,
      tanggalDiminta: _selectedDate,
      jamDiminta: _selectedJam,
    );
    widget.onReservationCreated(res);
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Langkah 1/3 • Data Kontak & Pasien',
      'Langkah 2/3 • Lokasi & Jadwal',
      'Langkah 3/3 • Tinjau & Simpan',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _prevStep,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          titles[_step],
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StepIndicatorChip(
                  number: '1',
                  label: 'Pasien',
                  active: _step >= 0,
                ),
                Expanded(
                  child: Divider(
                    color: _step >= 1
                        ? ElwafyColors.primaryBlue
                        : Colors.grey.shade300,
                    thickness: 2,
                    indent: 6,
                    endIndent: 6,
                  ),
                ),
                _StepIndicatorChip(
                  number: '2',
                  label: 'Jadwal',
                  active: _step >= 1,
                ),
                Expanded(
                  child: Divider(
                    color: _step >= 2
                        ? ElwafyColors.primaryBlue
                        : Colors.grey.shade300,
                    thickness: 2,
                    indent: 6,
                    endIndent: 6,
                  ),
                ),
                _StepIndicatorChip(
                  number: '3',
                  label: 'Ringkasan',
                  active: _step >= 2,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _step == 0
                ? _buildStep1Pasien()
                : _step == 1
                ? _buildStep2LokasiJadwal()
                : _buildStep3Ringkasan(),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _step == 2
                            ? Icons.check_circle_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _step == 2
                            ? 'Buat Reservasi'
                            : 'Lanjut ke Langkah ${_step + 2}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Pasien() {
    final customer = widget.store.loggedInCustomer;
    return Form(
      key: _step1FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer != null
                        ? 'Kontak Pemesan (Terisi Otomatis)'
                        : 'Kontak Pemesan (Mode Tamu)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaPemesanCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bunda / Pemesan *',
                      hintText: 'Contoh: Bunda Rania',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _waPemesanCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp Aktif *',
                      hintText: 'Contoh: 081265001234',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
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
                  const Text(
                    'Data Penerima Layanan (Pasien)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaPasienCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bayi / Anak / Bunda *',
                      hintText: 'Contoh: Baby Alfarezel',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama pasien wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usiaPasienCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usia Anak / Kondisi Bunda',
                      hintText: 'Contoh: 5 Bulan / Nifas H+10',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _catatanCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Keluhan (Opsional)',
                      hintText: 'Contoh: Bayi agak batuk ringan',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2LokasiJadwal() {
    return Form(
      key: _step2FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Mode Layanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeChoiceTile(
                          title: 'Homecare',
                          subtitle: 'Terapis ke Rumah',
                          icon: Icons.home_rounded,
                          selected: _selectedMode == ServiceMode.homecare,
                          onTap: () => setState(
                            () => _selectedMode = ServiceMode.homecare,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ModeChoiceTile(
                          title: 'Ke Outlet',
                          subtitle: 'Cabang Elwafy',
                          icon: Icons.storefront_rounded,
                          selected: _selectedMode == ServiceMode.outlet,
                          onTap: () => setState(
                            () => _selectedMode = ServiceMode.outlet,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_selectedMode == ServiceMode.homecare) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWilayah,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Wilayah / Kecamatan',
                      ),
                      items: _daftarWilayahMedan
                          .map(
                            (w) => DropdownMenuItem(value: w, child: Text(w)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedWilayah = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _alamatCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap Rumah *',
                        hintText: 'Nama jalan, nomor rumah, komplek...',
                      ),
                      validator: (v) {
                        if (_selectedMode == ServiceMode.homecare &&
                            (v == null || v.trim().isEmpty)) {
                          return 'Alamat rumah wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _patokanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Patokan Rumah (Opsional)',
                        hintText: 'Contoh: Pagar putih depan masjid',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gpsCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Titik GPS (Opsional)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _simulasiAmbilGps,
                          icon: const Icon(Icons.my_location_rounded, size: 16),
                          label: const Text('GPS'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _mapsLinkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tautan Peta / Google Maps (Opsional)',
                        hintText: 'https://maps.google.com/...',
                      ),
                    ),
                  ] else ...[
                    for (final outlet in widget.store.outlets)
                      InkWell(
                        onTap: () =>
                            setState(() => _selectedOutletId = outlet.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedOutletId == outlet.id
                                ? ElwafyColors.softBlueCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedOutletId == outlet.id
                                  ? ElwafyColors.primaryBlue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedOutletId == outlet.id
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
                                      outlet.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      outlet.alamat,
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
                  ],
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
                  const Text(
                    'Tanggal & Jam yang Diinginkan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Reservasi',
                        suffixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Text(
                        FormatHelper.tanggalIndo(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pilihanSlotJam.map((jam) {
                      final selected = _selectedJam == jam;
                      return ChoiceChip(
                        label: Text(jam),
                        selected: selected,
                        selectedColor: ElwafyColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : ElwafyColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        onSelected: (_) => setState(() => _selectedJam = jam),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '* Jadwal belum dianggap pasti sebelum Admin mengonfirmasi.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Ringkasan() {
    final entries = widget.store.cartEntries;
    final selectedOutlet = widget.store.outlets
        .where((o) => o.id == _selectedOutletId)
        .firstOrNull;

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
                  'Periksa Ringkasan Reservasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: ElwafyColors.primaryBlue,
                  ),
                ),
                const Divider(height: 20),
                _SummaryItemRow('Pemesan', _namaPemesanCtrl.text),
                _SummaryItemRow('WhatsApp', _waPemesanCtrl.text),
                _SummaryItemRow(
                  'Pasien',
                  '${_namaPasienCtrl.text} (${_usiaPasienCtrl.text.isEmpty ? "-" : _usiaPasienCtrl.text})',
                ),
                _SummaryItemRow('Mode', _selectedMode.label),
                if (_selectedMode == ServiceMode.homecare)
                  _SummaryItemRow(
                    'Lokasi',
                    '$_selectedWilayah — ${_alamatCtrl.text}',
                  )
                else
                  _SummaryItemRow('Outlet', selectedOutlet?.nama ?? '-'),
                _SummaryItemRow(
                  'Jadwal',
                  '${FormatHelper.tanggalIndo(_selectedDate)} • $_selectedJam',
                ),
                const Divider(height: 20),
                for (final e in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${e.value}x ${e.key.nama}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          FormatHelper.rupiah(e.key.harga * e.value),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      FormatHelper.rupiah(widget.store.totalCartPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIndicatorChip extends StatelessWidget {
  final String number;
  final String label;
  final bool active;

  const _StepIndicatorChip({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active
              ? ElwafyColors.primaryBlue
              : Colors.grey.shade300,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : ElwafyColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active
                ? ElwafyColors.primaryBlue
                : ElwafyColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ModeChoiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? ElwafyColors.softBlueCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ElwafyColors.primaryBlue : Colors.grey.shade300,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? ElwafyColors.primaryBlue
                  : ElwafyColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: selected
                    ? ElwafyColors.primaryBlue
                    : ElwafyColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: ElwafyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItemRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: ElwafyColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationConfirmationSheet extends StatelessWidget {
  final ElwafyStore store;
  final Reservation reservation;

  const _ReservationConfirmationSheet({
    required this.store,
    required this.reservation,
  });

  Future<void> _launchWhatsApp(BuildContext context, String message) async {
    String cleanPhone = store.settings.nomorWaAdmin.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final waMessage = store.buildCustomerWhatsAppMessage(reservation);

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
                  Icons.check_circle_rounded,
                  color: ElwafyColors.successGreen,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reservasi Berhasil Disimpan!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Nomor: ${reservation.nomorReservasi}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: ElwafyColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  waMessage,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(context, waMessage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElwafyColors.whatsappGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Buka WhatsApp & Kirim Pesanan'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: waMessage));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesan WhatsApp berhasil disalin!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Salin Teks Pesan WA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
