import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import '../../Data/Model/note.dart';
import '../../Data/Model/folder.dart';
import '../../Core/Utils/firestore_helper.dart';

void main() async {
  // 1. Khởi tạo Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TestConnectionPage(),
    );
  }
}

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  // Biến trạng thái để hiển thị vòng tròn xoay xoay khi đang lưu
  bool _isLoading = false;

  // --- HÀM TEST KẾT NỐI ---
  Future<void> _runTest() async {
    setState(() => _isLoading = true); // Bắt đầu xoay

    // Giả lập ID người dùng (Sau này sẽ lấy từ Firebase Auth)
    String fakeUserId = "user_test_001";

    try {
      // 1. Tạo dữ liệu mẫu theo Model chuẩn
      final testFolder = Folder(
        userId: fakeUserId,
        name: "Test Project từ Flutter",
        type: "project",
        icon: "🚀",
        color: "#FF5733", // Màu cam
        isSystem: false,
        createdAt: DateTime.now(),
      );

      // 2. Gọi Helper để đẩy lên Firestore
      await FirestoreHelper.folderRef(fakeUserId).add(testFolder);

      // 3. Thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ghi thành công! Kiểm tra Firebase Console đi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      print("SUCCESS: Đã ghi folder mới vào Firestore!");

    } catch (e) {
      // 4. Thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi rồi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("ERROR: $e");
    } finally {
      setState(() => _isLoading = false); // Tắt xoay
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Firebase Connection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bấm nút dưới để ghi thử dữ liệu",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Nút bấm kích hoạt test
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _runTest,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Gửi dữ liệu lên Firestore"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}