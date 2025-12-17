import 'package:flutter/material.dart';

class ParaColors extends ThemeExtension<ParaColors>{
  final Color project;
  final Color area;
  final Color resource;
  final Color archive;

  const ParaColors({
    required this.project,
    required this.area,
    required this.resource,
    required this.archive,
  });

  @override
  ParaColors copyWith({
    Color? project,
    Color? area,
    Color? resource,
    Color? archive,
  }){
    return ParaColors(
      project: project ?? this.project,
      area: area ?? this.area,
      resource: resource ?? this.resource,
      archive: archive ?? this.archive
    );
  }

  @override
  ParaColors lerp(ThemeExtension<ParaColors>? other, double t) {
    if(other is! ParaColors) return this;
    return ParaColors(
      project: Color.lerp(project, other.project, t)!,
      area: Color.lerp(area, other.area, t)!,
      resource: Color.lerp(resource, other.resource, t)!,
      archive: Color.lerp(archive, other.archive, t)!,
    );
  }
}


class AppThemes {
  static final modern = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6C5CE7),
    scaffoldBackgroundColor: const Color(0xFFF7F9FC),
    cardColor: Colors.white,
    extensions: <ThemeExtension<dynamic>>[
      const ParaColors(
        project: Color(0xFFFF7675),
        area: Color(0xFF74B9FF),
        resource: Color(0xFFFDCB6E),
        archive: Color(0xFFB2BEC3),
      )
    ]
  );

  static final dark = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF00CEC9),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      extensions: <ThemeExtension<dynamic>>[
        const ParaColors(
          project: Color(0xFFFF6B6B),
          area: Color(0xFF54A0FF),
          resource: Color(0xFFFF9F43),
          archive: Color(0xFF576574),
        )
      ],
      cardColor: const Color(0xFF2D2D2D)
  );

  static final earthy = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFD33682),
    scaffoldBackgroundColor: const Color(0xFFFDF6E3),
    cardColor: const Color(0xFFEEE8D5),
    extensions: <ThemeExtension<dynamic>>[
      const ParaColors(
        project: Color(0xFFCB4B16),
        area: Color(0xFF2AA198),
        resource: Color(0xFF859900),
        archive: Color(0xFF93A1A1),
      ),
    ],
  );
}