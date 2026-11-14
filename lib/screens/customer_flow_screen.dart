import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/elwafy_models.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';

class CustomerFlowScreen extends StatefulWidget {
  final ElwafyStore store;

  const CustomerFlowScreen({
    super.key,
    required this.store,
  });

  @override
  State<CustomerFlowScreen> createState() => _CustomerFlowScreenState();
}

class _CustomerFlowScreenState extends State<CustomerFlowScreen> {
  int _customerTab = 0; // 0 = Beranda, 1 = Keranjang, 2 = Pesanan, 3 = Akun
  CatalogCategory? _selectedCategory;
  String _searchQuery = '';

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

  void _openStepByStepCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _CustomerCheckoutWizardScreen(
          store: widget.store,
          onReservationCreated: (res) {
            Navigator.of(ctx).pop();
            setState(() => _customerTab = 2); // Pindah ke tab Pesanan
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

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const ElwafyLogo(size: 34),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elwafy Care',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Mom, Kids & Baby Spa • by Bidan Elfi',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Tombol pintas ke Keranjang
          IconButton(
            onPressed: () => setState(() => _customerTab = 1),
            tooltip: 'Keranjang',
            icon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _customerTab,
        children: [
          _buildBerandaTab(),
          _buildKeranjangTab(),
          _buildPesananSayaTab(),
          _buildAkunDanPortalStafTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _customerTab,
        onDestinationSelected: (idx) => setState(() => _customerTab = idx),
        backgroundColor: Colors.white,
        indicatorColor: ElwafyColors.softBlueCard,
        height: 66,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalCartItems > 0,
              label: Text('$totalCartItems'),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: ElwafyColors.primaryBlue,
              ),
            ),
            label: 'Keranjang',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: widget.store.reservations.isNotEmpty,
              label: Text('${widget.store.reservations.length}'),
              backgroundColor: ElwafyColors.skyBlue,
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: widget.store.reservations.isNotEmpty,
              label: Text('${widget.store.reservations.length}'),
              backgroundColor: ElwafyColors.skyBlue,
              child: const Icon(
                Icons.receipt_long_rounded,
                color: ElwafyColors.primaryBlue,
              ),
            ),
            label: 'Pesanan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: ElwafyColors.primaryBlue,
            ),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  // TAB 0: BERANDA & KATALOG RINGKAS
  Widget _buildBerandaTab() {
    final totalCartItems = widget.store.totalCartItems;
    final totalCartPrice = widget.store.totalCartPrice;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Hero Card Ringkas & Bersih
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ElwafyColors.primaryBlue,
                      ElwafyColors.skyBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const ElwafyLogo(size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perawatan Ibu & Buah Hati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terapis bidan tersertifikasi siap datang ke rumah (Homecare) atau di Outlet Medan.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '⏰ Buka ${widget.store.settings.jamOperasionalDefault}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

            // Pencarian & Chip Kategori
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari layanan pijat bayi, laktasi, swim...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: ElwafyColors.primaryBlue,
                          size: 20,
                        ),
                        isDense: true,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
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
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Kartu Katalog Ringkas (Tap untuk lihat detail lengkap)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                totalCartItems > 0 ? 96 : 24,
              ),
              sliver: SliverList.separated(
                itemCount: _filteredCatalog.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _filteredCatalog[index];
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
                            // Baris Badge Ringkas
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    onPressed: () =>
                                        widget.store.addToCart(item.id),
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
                                      border: Border.all(
                                        color: ElwafyColors.primaryBlue,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => widget.store
                                              .decrementFromCart(item.id),
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ElwafyColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              widget.store.addToCart(item.id),
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
                },
              ),
            ),
          ],
        ),

        // Floating Mini Cart Bar
        if (totalCartItems > 0)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: InkWell(
              onTap: _openStepByStepCheckout,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
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
          ),
      ],
    );
  }

  // TAB 1: KERANJANG BELANJA CUSTOMER
  Widget _buildKeranjangTab() {
    final entries = widget.store.cartEntries;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: ElwafyColors.softBlueCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 46,
                  color: ElwafyColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keranjang Layanan Masih Kosong',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ElwafyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih layanan Mom, Kids, atau Baby terlebih dahulu di Beranda sebelum mengatur jadwal kunjungan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: ElwafyColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => setState(() => _customerTab = 0),
                icon: const Icon(Icons.explore_rounded),
                label: const Text('Lihat Katalog Layanan'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = entries[i].key;
              final qty = entries[i].value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${FormatHelper.rupiah(item.harga)} / sesi',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ElwafyColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subtotal: ${FormatHelper.rupiah(item.harga * qty)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: ElwafyColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                widget.store.decrementFromCart(item.id),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: ElwafyColors.primaryBlue,
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.store.addToCart(item.id),
                            icon: const Icon(Icons.add_circle_outline),
                            color: ElwafyColors.primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Estimasi',
                      style: TextStyle(
                        fontSize: 14,
                        color: ElwafyColors.textSecondary,
                      ),
                    ),
                    Text(
                      FormatHelper.rupiah(widget.store.totalCartPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ElwafyColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openStepByStepCheckout,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Isi Data & Jadwal Reservasi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: PESANAN SAYA (STATUS RESERVASI & TOMBOL WA)
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

  // TAB 3: AKUN CUSTOMER & AKSES PORTAL INTERNAL STAF (ADMIN / MITRA)
  Widget _buildAkunDanPortalStafTab() {
    final customer = widget.store.loggedInCustomer;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kartu Sesi Customer
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Info Cabang Outlet Elwafy Care
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Outlet Elwafy Care Medan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
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

        // Portal Internal Staf (Admin & Mitra) — Rapi & Tidak Mengganggu Navigasi Customer
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
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
                    backgroundColor: ElwafyColors.skyBlue.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: ElwafyColors.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Masuk Portal Mitra Homecare',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
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
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : color,
            ),
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

/// WIZARD RESERVASI 3 LANGKAH (STEP-BY-STEP) AGAR TIDAK PADAT DI MOBILE
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
  int _step = 0; // 0 = Data Kontak & Pasien, 1 = Lokasi & Jadwal, 2 = Konfirmasi

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  late final TextEditingController _namaPemesanCtrl;
  late final TextEditingController _waPemesanCtrl;
  final TextEditingController _namaPasienCtrl = TextEditingController();
  final TextEditingController _usiaPasienCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  ServiceMode _selectedMode = ServiceMode.homecare;
  String _selectedWilayah = 'Medan Johor';
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _patokanCtrl = TextEditingController();
  final TextEditingController _gpsCtrl = TextEditingController();
  final TextEditingController _mapsLinkCtrl = TextEditingController();

  late String _selectedOutletId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedJam = '10.00 WIB';

  static const List<String> _daftarWilayahMedan = [
    'Medan Johor',
    'Medan Sunggal / Setiabudi',
    'Medan Helvetia',
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
      alamatLengkap:
          _selectedMode == ServiceMode.homecare ? _alamatCtrl.text.trim() : null,
      patokan:
          _selectedMode == ServiceMode.homecare ? _patokanCtrl.text.trim() : null,
      wilayahHomecare:
          _selectedMode == ServiceMode.homecare ? _selectedWilayah : null,
      koordinatGps:
          _selectedMode == ServiceMode.homecare ? _gpsCtrl.text.trim() : null,
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
          // Progress Bar 3 Langkah
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

          // Tombol Bawah
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
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _waPemesanCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor WhatsApp Aktif *',
                      hintText: 'Contoh: 081265001234',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Wajib diisi'
                        : null,
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
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFB45309),
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
          backgroundColor:
              active ? ElwafyColors.primaryBlue : Colors.grey.shade300,
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
            color:
                active ? ElwafyColors.primaryBlue : ElwafyColors.textSecondary,
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet Konfirmasi Reservasi & Tombol Buka WhatsApp
class _ReservationConfirmationSheet extends StatelessWidget {
  final ElwafyStore store;
  final Reservation reservation;

  const _ReservationConfirmationSheet({
    required this.store,
    required this.reservation,
  });

  Future<void> _launchWhatsApp(BuildContext context, String message) async {
    String cleanPhone =
        store.settings.nomorWaAdmin.replaceAll(RegExp(r'[^0-9]'), '');
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
