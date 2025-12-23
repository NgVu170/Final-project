import 'package:flutter/material.dart';
import '../../Core/Constants/SearchBar/search_type.dart';

class CustomSearchBar extends StatelessWidget {
  // Pass the current values in to make this a controlled widget.
  final String searchQuery;
  final SearchType searchType;
  final SortOrder sortOrder;

  // Callbacks with specific types for type safety.
  final Function(String) onSearchQueryChanged;
  final Function(SearchType) onSearchTypeChanged;
  final Function(SortOrder) onSortOrderChanged;

  const CustomSearchBar({
    super.key,
    required this.searchQuery,
    required this.searchType,
    required this.sortOrder,
    required this.onSearchQueryChanged,
    required this.onSearchTypeChanged,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: TextEditingController(text: searchQuery),
            onChanged: onSearchQueryChanged,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: outlineBorder,
              focusedBorder: outlineBorder.copyWith(
                borderSide: BorderSide(color: colorScheme.primary)
              ),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              suffixIcon: IconButton(
                tooltip: "Change order",
                icon: Icon(
                  sortOrder == SortOrder.ascending
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  final newOrder = sortOrder == SortOrder.ascending
                      ? SortOrder.descending
                      : SortOrder.ascending;
                  // Pass the enum value directly.
                  onSortOrderChanged(newOrder);
                },
              )
            ),
          )
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SearchType>(
                value: searchType,
                isExpanded: true,
                icon: Icon(Icons.filter_list, size: 20, color: colorScheme.onSurfaceVariant),
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                dropdownColor: colorScheme.surfaceContainerHighest,
                onChanged: (SearchType? newValue) {
                  if (newValue != null) {
                    onSearchTypeChanged(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: SearchType.content,
                    child: Text("Content", overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: SearchType.tags,
                    child: Text("Tags", overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: SearchType.notes,
                    child: Text("Notes", overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: SearchType.links,
                    child: Text("Links", overflow: TextOverflow.ellipsis),
                  ),

                  DropdownMenuItem(
                    value: SearchType.created,
                    child: Text("Day created", overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
