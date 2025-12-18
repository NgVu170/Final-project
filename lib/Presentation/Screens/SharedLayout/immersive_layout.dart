import 'package:flutter/material.dart';
import '../../Widgets/navBar.dart';
import '../../Widgets/search_bar.dart';

// Widget này sẽ bọc lấy nội dung của từng màn hình
class ImmersiveLayout extends StatefulWidget {
  final Widget body;           // Nội dung màn hình (VD: TextField của Home)
  final int currentIndex;      // Tab hiện tại
  final Function(int) onTabTapped; // Hàm chuyển tab
  final Function(String)? onSearch; // Hàm search (nếu màn hình đó cần search)

  const ImmersiveLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
    this.onSearch,
  });

  @override
  State<ImmersiveLayout> createState() => _ImmersiveLayoutState();
}

class _ImmersiveLayoutState extends State<ImmersiveLayout> {
  bool _showUI = true; // Trạng thái ẩn/hiện chung cho tất cả các màn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng Stack ở đây để tái sử dụng logic Animation
      body: Stack(
        children: [
          // 1. NỘI DUNG CHÍNH (Body)
          Positioned.fill(
            child: GestureDetector(
              // Logic toggle UI khi chạm/vuốt nằm ở đây
              onTap: () {
                // Đóng bàn phím nếu đang mở
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() => _showUI = !_showUI);
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 0) setState(() => _showUI = true);
                if (details.primaryVelocity! < 0) setState(() => _showUI = false);
              },
              child: widget.body, // Nội dung truyền vào sẽ nằm ở đây
            ),
          ),

          // 2. SEARCH BAR (Chỉ hiện nếu màn hình đó có chức năng search)
          if (widget.onSearch != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showUI ? 50 : -150,
              left: 16,
              right: 16,
              child: CustomSearchBar(onChanged: widget.onSearch!),
            ),

          // 3. NAV BAR (Dùng lại widget ở Bước 1)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showUI ? 0 : -100,
            left: 0,
            right: 0,
            child: CustomNavBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}