import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ToggleNavbarNotification extends Notification {}

class ImmersiveEditor extends StatefulWidget{
  final QuillController controller;
  final FocusNode focusNode;

  const ImmersiveEditor({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<ImmersiveEditor> createState() => _ImmersiveEditorState();
}

class _ImmersiveEditorState extends State<ImmersiveEditor>{
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async{
    try{
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e){
      debugPrint('[ERROR] launching url: $e');
    }
  }

  Future<void> _pickImage() async{
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null){
      final index = widget.controller.selection.baseOffset;
      final length = widget.controller.selection.extentOffset - index;
      widget.controller.replaceText(index, length, BlockEmbed.image(image.path), null);
      widget.controller.moveCursorToPosition(index + 1);
    }
  }

  void _insertTag(){
    final index = widget.controller.selection.baseOffset;
    widget.controller.document.insert(index, "#");
    widget.controller.formatText(index, 1, const ColorAttribute('#007AFF'));
    widget.controller.moveCursorToPosition(index + 1);
    widget.controller.formatSelection(Attribute.clone(Attribute.color, null));
  }

  @override
  Widget build(BuildContext context){
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          if (widget.focusNode.hasFocus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  )
                ],
              ),

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    QuillToolbarHistoryButton(isUndo: true, controller: widget.controller),

                    QuillToolbarFontFamilyButton(
                      controller: widget.controller,
                      options: QuillToolbarFontFamilyButtonOptions(
                        width: 110,
                        initialValue: 'roboto',
                        items: const {
                          'Roboto': 'roboto',
                          'Mirza': 'mirza',
                          'Lobster': 'lobster',
                          'Dancing': 'dancing-script',
                          'Arial': 'arial',
                        },
                        iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(color: colorScheme.primary),
                        ),
                      ),
                    ),

                    QuillToolbarFontSizeButton(controller: widget.controller),
                    const VerticalDivider(width: 20),

                    QuillToolbarToggleStyleButton(attribute: Attribute.bold, controller: widget.controller),
                    QuillToolbarToggleStyleButton(attribute: Attribute.italic, controller: widget.controller),
                    QuillToolbarToggleStyleButton(attribute: Attribute.underline, controller: widget.controller),
                    QuillToolbarColorButton(controller: widget.controller, isBackground: false),

                    const VerticalDivider(width: 20),

                    QuillToolbarLinkStyleButton(controller: widget.controller),
                    IconButton(
                      icon: Icon(Icons.image_outlined, color: colorScheme.onSurface),
                      onPressed: _pickImage,
                      tooltip: "Add image",
                    ),
                    IconButton(
                      icon: const Icon(Icons.tag, color: Colors.blueAccent),
                      onPressed: _insertTag,
                      tooltip: "Add tag",
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onDoubleTap: (){
                ToggleNavbarNotification().dispatch(context);
              },
              behavior: HitTestBehavior.translucent,

              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: QuillEditor.basic(
                 controller: widget.controller,
                 focusNode: widget.focusNode,
                 scrollController: _scrollController,

                 config: QuillEditorConfig(
                   placeholder: 'Write something now ...',
                   expands: false,
                   scrollable: true,
                   autoFocus: false,

                   padding: const EdgeInsets.only(top: 16, bottom: 300),

                   customStyleBuilder: (attribute){
                     if (attribute.key == 'font'){
                       switch (attribute.value) {
                         case 'mirza': return GoogleFonts.mirza();
                         case 'lobster': return GoogleFonts.lobster();
                         case 'dancing-script': return GoogleFonts.dancingScript();
                         case 'arial': return GoogleFonts.openSans();
                         default: return GoogleFonts.roboto();
                       }
                     }
                     return const TextStyle();
                   },

                   onLaunchUrl: (String? url){
                     if (url != null) _launchUrl(url);
                   }
                 ),
                ),
              )
            ),
          )
        ],
      )
    );
  }
}