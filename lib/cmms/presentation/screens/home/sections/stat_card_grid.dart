import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../../utils/routes/cmms_routes.dart';
import '../../../../data/services/equipment_service.dart'; // 👈 Import cho InspectionService
import '../../../../data/services/task_equipment_today_service.dart';
import '../widgets/stat_card.dart';
import '../models/stat_card_data.dart';

// 👈 Giả sử RouteObserver được khai báo toàn cục ở main.dart hoặc nơi khác.
// Nếu chưa có, thêm ở MaterialApp: navigatorObservers: [routeObserver],
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class StatCardGrid extends StatefulWidget {
  const StatCardGrid({super.key});

  @override
  State<StatCardGrid> createState() => _StatCardGridState();
}

class _StatCardGridState extends State<StatCardGrid> with RouteAware {
  int equipmentCount = 0;
  int dailyinspectionCount = 0;
  int maintenanceCount = 0;
  int overDueCount = 0;
  bool isLoading = true;
  int pendingFetches = 0; // 👈 Thêm counter để theo dõi loading chính xác hơn

  @override
  void initState() {
    super.initState();
    _refreshData(); // 👈 Gọi hàm refresh thay vì các fetch riêng lẻ
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe vào RouteObserver khi dependencies thay đổi
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route as PageRoute);
    }
  }

  @override
  void dispose() {
    // Unsubscribe để tránh memory leak
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 👈 Gọi khi pop từ trang con để refetch dữ liệu mới
    _refreshData();
  }

  // 👈 Hàm mới: Refetch tất cả dữ liệu và quản lý loading
  void _refreshData() {
    setState(() {
      isLoading = true;
      pendingFetches = 4; // 👈 Số lượng fetch methods
    });
    _fetchEquipmentCount();
    _fetchDailyinspectionCount();
    _fetchMaintenanceCount();
    _fetchOverDueCount();
  }

  // 👈 Helper để cập nhật loading khi một fetch hoàn thành
  void _onFetchComplete() {
    if (mounted) {
      setState(() {
        pendingFetches--;
        if (pendingFetches <= 0) {
          isLoading = false;
        }
      });
    }
  }

  Future<void> _fetchEquipmentCount() async {
    try {
      final count = await EquipmentService.getEquipments();
      if (mounted) {
        setState(() {
          equipmentCount = count.data.length;
        });
      }
    } catch (e) {
      // Xử lý lỗi (không set count nếu lỗi)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu thiết bị: ${e.toString()}')),
        );
      }
    } finally {
      _onFetchComplete();
    }
  }

  Future<void> _fetchDailyinspectionCount() async {
    try {
      final count = await InspectionService.fetchInspections();
      if (mounted) {
        setState(() {
          dailyinspectionCount = count.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi tải dữ liệu kiểm tra hàng ngày: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      _onFetchComplete();
    }
  }

  Future<void> _fetchMaintenanceCount() async {
    try {
      final count = await InspectionService.fetchInspectionsMaintenance();
      if (mounted) {
        setState(() {
          maintenanceCount = count.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu bảo trì: ${e.toString()}')),
        );
      }
    } finally {
      _onFetchComplete();
    }
  }

  Future<void> _fetchOverDueCount() async {
    try {
      final count = await InspectionService.fetchOverDue();
      if (mounted) {
        setState(() {
          overDueCount = count.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu quá hạn: ${e.toString()}')),
        );
      }
    } finally {
      _onFetchComplete();
    }
  }

  // 👈 Widget skeleton cho một card (placeholder khi loading)
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: icon + title
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Skeleton cho icon

                // Skeleton cho title (và mô tả nếu có)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description (nếu cần thêm)
                      Container(
                        height: 8,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Skeleton cho value (nằm riêng bên dưới)
            Container(
              height: 20,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statCards = [
      StatCardData(
        AppLocalizations.of(context)!.dailyInspectionTitle,
        AppLocalizations.of(context)!.needToInspect,
        dailyinspectionCount.toString(),
        Icons.assignment,
        Colors.blue[100]!,
        () {
          Navigator.pushNamed(context, CmmsRoutes.todayTasks);
        },
      ),
      StatCardData(
        AppLocalizations.of(context)!.maintenanceMachineTitle,
        AppLocalizations.of(context)!.scheduledToday,
        maintenanceCount.toString(),
        Icons.assignment,
        Colors.blue[100]!,
        () {
          Navigator.pushNamed(context, CmmsRoutes.maintenanceTasks);
        },
      ),
      StatCardData(
        AppLocalizations.of(context)!.equipmentsTitle,
        "",
        equipmentCount.toString(),
        Icons.storage,
        Colors.green[100]!,
        () {
          Navigator.pushNamed(context, CmmsRoutes.equipment);
        },
      ),
      StatCardData(
        AppLocalizations.of(context)!.overdueTitle,
        "",
        overDueCount.toString(),
        Icons.access_time,
        Colors.yellow[100]!,
        () {
          Navigator.pushNamed(context, CmmsRoutes.overdue);
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: dưới 600px thì 2 cột, lớn hơn thì 4 cột
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            mainAxisExtent: 105, // Cố định chiều cao
          ),
          itemCount: statCards.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              // 👈 Hiển thị skeleton card khi loading
              return _buildSkeletonCard();
            }
            final card = statCards[index];
            return StatCard(
              title: card.title,
              description: card.description,
              value: card.value,
              icon: card.icon,
              color: card.color,
              onTap: card.onTap,
            );
          },
        );
      },
    );
  }
}
