import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_app_using_para/Core/Constants/app_theme.dart';

part 'theme_state.dart';

enum AppThemeType { modern, dark, earthy }

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode_index';

  ThemeCubit() : super(ThemeState.initial()) {
    _loadSavedTheme();
  }

  // Helper: Map từ Enum sang ThemeData
  ThemeData _getThemeDataByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.modern: return AppThemes.modern;
      case AppThemeType.dark:   return AppThemes.dark;
      case AppThemeType.earthy: return AppThemes.earthy;
    }
  }

  // --- CHANGE THEME ---
  Future<void> changeTheme(AppThemeType themeType) async {
    // 1. Emit Loading (Để debug biết là đang xử lý)
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      // 2. Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeType.index);

      // 3. Lấy ThemeData tương ứng
      final newThemeData = _getThemeDataByType(themeType);

      // 4. Emit Success với Theme mới
      emit(state.copyWith(
        status: ThemeStatus.success,
        activeThemeType: themeType,
        themeData: newThemeData,
      ));

    } catch (e) {
      // 5. Nếu lỗi lưu, vẫn đổi theme trên UI tạm thời nhưng báo lỗi
      emit(state.copyWith(
        status: ThemeStatus.failure,
        errorMessage: "Không thể lưu cài đặt: $e",
        // Vẫn cho đổi theme để trải nghiệm user không bị gián đoạn
        activeThemeType: themeType,
        themeData: _getThemeDataByType(themeType),
      ));
    }
  }

  // --- LOAD THEME ---
  Future<void> _loadSavedTheme() async {
    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_themeKey) ?? 0;

      // Đảm bảo index hợp lệ (tránh crash nếu sau này xóa bớt theme)
      final safeIndex = (savedIndex >= 0 && savedIndex < AppThemeType.values.length)
          ? savedIndex
          : 0;

      final savedType = AppThemeType.values[safeIndex];
      final savedThemeData = _getThemeDataByType(savedType);

      emit(state.copyWith(
        status: ThemeStatus.success,
        activeThemeType: savedType,
        themeData: savedThemeData,
      ));
    } catch (e) {
      // Nếu load lỗi -> Về mặc định
      emit(state.copyWith(
        status: ThemeStatus.failure,
        errorMessage: "Lỗi tải theme: $e",
        activeThemeType: AppThemeType.modern,
        themeData: AppThemes.modern,
      ));
    }
  }
}