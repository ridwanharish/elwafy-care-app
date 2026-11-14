import 'package:flutter/material.dart';
import '../models/elwafy_models.dart';

class ElwafyColors {
  // Warna utama diadaptasi dari Logo & Instagram @elwafy.care
  static const Color primaryBlue = Color(0xFF0A58CA); // Royal/Cobalt Blue ("Elwafy" & pita)
  static const Color skyBlue = Color(0xFF00A8FF); // Bright Cyan/Sky Blue (Lingkaran logo)
  static const Color lightSky = Color(0xFF56CCF2);
  static const Color babyBlueBg = Color(0xFFF2F8FF); // Cloud Baby Blue background
  static const Color softBlueCard = Color(0xFFE3F2FD);
  static const Color navyDark = Color(0xFF072B61);
  static const Color textPrimary = Color(0xFF1A2B49);
  static const Color textSecondary = Color(0xFF5A6E8C);
  static const Color white = Color(0xFFFFFFFF);

  // Warna aksen kategori
  static const Color babyCategory = Color(0xFF00A8FF);
  static const Color kidsCategory = Color(0xFF00B894);
  static const Color momCategory = Color(0xFFE84393);

  // Warna status
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color telegramBlue = Color(0xFF0088CC);
}

class ElwafyTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ElwafyColors.primaryBlue,
      primary: ElwafyColors.primaryBlue,
      secondary: ElwafyColors.skyBlue,
      surface: ElwafyColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ElwafyColors.babyBlueBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: ElwafyColors.primaryBlue,
        foregroundColor: ElwafyColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: ElwafyColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ElwafyColors.primaryBlue.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ElwafyColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ElwafyColors.primaryBlue.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ElwafyColors.primaryBlue.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ElwafyColors.primaryBlue, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ElwafyColors.primaryBlue,
          foregroundColor: ElwafyColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ElwafyColors.primaryBlue,
          side: const BorderSide(color: ElwafyColors.primaryBlue, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static Color statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.menungguKonfirmasiAdmin:
        return ElwafyColors.warningAmber;
      case ReservationStatus.perluPenyesuaianJadwal:
        return const Color(0xFFEA580C);
      case ReservationStatus.terkonfirmasi:
        return ElwafyColors.primaryBlue;
      case ReservationStatus.menungguResponsMitra:
        return ElwafyColors.purpleAccent;
      case ReservationStatus.petugasMenerimaTugas:
        return ElwafyColors.skyBlue;
      case ReservationStatus.ditolakMitra:
        return ElwafyColors.dangerRed;
      case ReservationStatus.selesai:
        return ElwafyColors.successGreen;
      case ReservationStatus.dibatalkan:
        return const Color(0xFF64748B);
    }
  }

  static IconData statusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.menungguKonfirmasiAdmin:
        return Icons.hourglass_top_rounded;
      case ReservationStatus.perluPenyesuaianJadwal:
        return Icons.edit_calendar_rounded;
      case ReservationStatus.terkonfirmasi:
        return Icons.verified_rounded;
      case ReservationStatus.menungguResponsMitra:
        return Icons.forward_to_inbox_rounded;
      case ReservationStatus.petugasMenerimaTugas:
        return Icons.directions_car_filled_rounded;
      case ReservationStatus.ditolakMitra:
        return Icons.cancel_schedule_send_rounded;
      case ReservationStatus.selesai:
        return Icons.check_circle_rounded;
      case ReservationStatus.dibatalkan:
        return Icons.block_rounded;
    }
  }
}

class ElwafyLogo extends StatelessWidget {
  final double size;
  final bool showBorder;

  const ElwafyLogo({
    super.key,
    this.size = 48,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ElwafyColors.white,
        border: showBorder
            ? Border.all(color: ElwafyColors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: ElwafyColors.navyDark.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/elwafy_logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: ElwafyColors.skyBlue,
              alignment: Alignment.center,
              child: Icon(
                Icons.child_care_rounded,
                color: Colors.white,
                size: size * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }
}

class FormatHelper {
  static String rupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  static String tanggalIndo(DateTime date) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${bulan[date.month - 1]} ${date.year}';
  }

  static String tanggalWaktuIndo(DateTime date) {
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${tanggalIndo(date)}, $jam:$menit WIB';
  }
}
