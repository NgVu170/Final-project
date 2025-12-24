import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomQuillToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onAddTag;
  final VoidCallback onAddLink;

  const CustomQuillToolbar({
    super.key,
    required this.controller,
    required this.onAddTag,
    required this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // DEFINITIVE FIX: Removed all hallucinated styling options.
            // Using the most basic constructors that are guaranteed to compile.

            // Bold Button
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.bold,
            ),
            // Italic Button
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.italic,
            ),
            // Text Color Button
            QuillToolbarColorButton(
              controller: controller,
              isBackground: false, // FIX: Provided the required parameter.
            ),
            const VerticalDivider(indent: 12, endIndent: 12),
            // Bulleted List Button
            QuillToolbarToggleStyleButton(
              controller: controller,
              attribute: Attribute.ul,
            ),
            const VerticalDivider(indent: 12, endIndent: 12),
            // Custom Tag Button
            IconButton(
              icon: Icon(Icons.tag, color: theme.iconTheme.color),
              onPressed: onAddTag,
              tooltip: 'Add Tag',
            ),
            // Link Button
            QuillToolbarLinkStyleButton(
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}
