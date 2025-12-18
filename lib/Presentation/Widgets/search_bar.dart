import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget{
  final Function(String) onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>{
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState(){
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),

          prefixIcon: Icon(Icons.search,
            color: theme.primaryColor,),

            suffixIcon: _showClearButton
                ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
              },
            ) : null,

          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}