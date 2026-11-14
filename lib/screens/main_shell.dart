import 'package:flutter/material.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';
import 'admin_dashboard_screen.dart';
import 'customer_flow_screen.dart';
import 'mitra_portal_screen.dart';

class MainShell extends StatelessWidget {
  final ElwafyStore store;

  const MainShell({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final activeRolePortal = store.activePortalTab;

        Widget activeApp;
        if (activeRolePortal == 1) {
          activeApp = AdminDashboardScreen(store: store);
        } else if (activeRolePortal == 2) {
          activeApp = MitraPortalScreen(store: store);
        } else {
          activeApp = CustomerFlowScreen(store: store);
        }

        // Bingkai Responsif Mobile-First:
        // Di HP tampil penuh 100%, di layar lebar (Web/Windows) terpusat ukuran layar HP (max 460px)
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 500) {
              return activeApp;
            }
            return Container(
              color: const Color(0xFFDCE8F7),
              alignment: Alignment.center,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                decoration: BoxDecoration(
                  color: ElwafyColors.babyBlueBg,
                  boxShadow: [
                    BoxShadow(
                      color: ElwafyColors.navyDark.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRect(child: activeApp),
              ),
            );
          },
        );
      },
    );
  }
}
