import 'package:flutter/material.dart';
import '../../Core/Constants/SearchBar/search_type.dart';

class CustomSearchBar extends StatelessWidget {
  final SearchType searchType;
  final SortOrder sortOrder;

  final Function(String) onSearchQueryChanged;
  final Function(dynamic) onSearchTypeChanged;
  final Function(bool) onSortOrderChanged;

  const CustomSearchBar({
    super.key,
    required this.onSearchQueryChanged,
    required this.onSearchTypeChanged,
    required this.onSortOrderChanged,
    this.searchType = SearchType.content,
    this.sortOrder = SortOrder.ascending,
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
          //----Sort text ----
          flex: 2,
          child: TextField(
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

              //----Sort Icon ----
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
                  onSortOrderChanged(newOrder as bool);
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

