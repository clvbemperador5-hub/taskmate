import 'package:flutter/material.dart';
import '../screens/add_task_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/focus_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/schedule_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AppNavShell extends StatelessWidget {
  const AppNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentIndex = state.currentTabIndex;

    final screens = [
      const DashboardScreen(),
      const ScheduleScreen(),
      const FocusScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E1B4B).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Tasks Tab
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Tasks',
                isSelected: currentIndex == 0,
                onTap: () => state.setTabIndex(0),
              ),

              // 2. Schedule Tab
              _buildNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Schedule',
                isSelected: currentIndex == 1,
                onTap: () => state.setTabIndex(1),
              ),

              // 3. Center Raised Add Task Button
              Transform.translate(
                offset: const Offset(0, -10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // 4. Focus Tab
              _buildNavItem(
                icon: Icons.timer_outlined,
                activeIcon: Icons.timer,
                label: 'Focus',
                isSelected: currentIndex == 2,
                onTap: () => state.setTabIndex(2),
              ),

              // 5. Profile Tab
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => state.setTabIndex(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
