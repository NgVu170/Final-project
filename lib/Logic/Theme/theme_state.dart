part of 'theme_cubit.dart';

enum ThemeStatus { initial, loading, success, failure }

class ThemeState extends Equatable {
  final ThemeStatus status;
  final AppThemeType activeThemeType; // Để biết đang chọn Modern/Dark/Earthy
  final ThemeData themeData;          // Dữ liệu thật để App dùng
  final String? errorMessage;         // Chứa lỗi nếu có

  const ThemeState({
    this.status = ThemeStatus.initial,
    this.activeThemeType = AppThemeType.modern, // Mặc định
    required this.themeData, // Bắt buộc phải có theme ban đầu
    this.errorMessage,
  });

  // Hàm khởi tạo mặc định (Factory)
  factory ThemeState.initial() {
    return ThemeState(
      status: ThemeStatus.initial,
      activeThemeType: AppThemeType.modern,
      themeData: AppThemes.modern, // Lấy từ file app_theme.dart
    );
  }

  // Hàm copyWith quan trọng để update state
  ThemeState copyWith({
    ThemeStatus? status,
    AppThemeType? activeThemeType,
    ThemeData? themeData,
    String? errorMessage,
  }) {
    return ThemeState(
      status: status ?? this.status,
      activeThemeType: activeThemeType ?? this.activeThemeType,
      themeData: themeData ?? this.themeData,
      errorMessage: errorMessage, // Error không giữ lại giá trị cũ nếu không truyền
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}