import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/app_section.dart';
import '../../services/notificacion_service.dart';
import '../../widgets/layout.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.navigate});

  final ValueChanged<AppSection> navigate;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificacionService.getNotifications();
  }

  Future<void> _refresh() async {
    setState(() => _future = NotificacionService.getNotifications());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => widget.navigate(AppSection.dashboard),
                  ),
                  const Text('Notificaciones', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await NotificacionService.markAllAsRead();
                      _refresh();
                    },
                    child: const Text('Marcar todas', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<AppNotification>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 60),
                          EmptyState(icon: Icons.notifications_none, label: 'No tienes notificaciones todavia'),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final n = items[i];
                        return InkWell(
                          onTap: () async {
                            if (!n.leida) {
                              await NotificacionService.markAsRead(n.id);
                              _refresh();
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.leida ? AppColors.panel : AppColors.accent.withOpacity(.08),
                              border: Border.all(color: AppColors.line),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  n.leida ? Icons.notifications_none : Icons.notifications_active,
                                  color: n.leida ? Colors.white38 : AppColors.accent,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(n.mensaje, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
