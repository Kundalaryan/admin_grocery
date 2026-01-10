import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your screens here
import 'dashboard/presentation/screens/dashboard_screen.dart';
import 'inventory/presentation/screens/inventory_screen.dart';
import 'orders/presentation/screens/orders_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // 1. Variable to track which tab is active (0 = Dashboard, 1 = Orders)
  int _currentIndex = 0;

  // 2. List of screens to show
  final List<Widget> _pages = [
    const DashboardScreen(),
    const OrdersScreen(),
    const InventoryScreen(), // Placeholder
    const Scaffold(body: Center(child: Text("Settings Coming Soon"))),  // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. INDEXED STACK: Keeps the state of pages alive (doesn't reload when switching)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 4. The Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1986E6),
          unselectedItemColor: const Color(0xFFA0AEC0),
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: "Inventory",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}