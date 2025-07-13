import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateListBottomSheet extends StatefulWidget {
  final Function(String, IconData, Color) onListInfoSaved;

  const CreateListBottomSheet({
    super.key,
    required this.onListInfoSaved,
  });

  @override
  _CreateListBottomSheetState createState() => _CreateListBottomSheetState();
}

class _CreateListBottomSheetState extends State<CreateListBottomSheet> {
  IconData selectedIcon = Icons.list;
  late TextEditingController _textEditingController;
  Color selectedColor = Colors.blue;
  final FocusNode _focusNode = FocusNode();

  final List<IconData> iconList = [
    Icons.list,
    Icons.mood,
    Icons.music_note,
    Icons.key,
    Icons.check,
    Icons.card_giftcard,
    Icons.sunny,
    Icons.videogame_asset_rounded,
    Icons.cake,
    Icons.smart_toy_rounded,
    Icons.school_rounded,
    Icons.attach_file,
    Icons.attach_money,
    Icons.camera_alt,
    Icons.book,
    Icons.border_all,
    Icons.business,
    Icons.check_circle,
    Icons.child_friendly,
    Icons.chrome_reader_mode,
    Icons.code,
    Icons.desktop_windows,
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.favorite,
    Icons.directions_car,
    Icons.directions_subway,
    Icons.directions_walk,
    Icons.euro_symbol,
    Icons.face,
    Icons.flag,
    Icons.house,
    Icons.gamepad,
    Icons.headset_mic,
    Icons.hourglass_empty,
    Icons.language,
    Icons.laptop_mac,
    Icons.local_cafe,
    Icons.local_library,
    Icons.local_movies,
    Icons.mail_outline,
    Icons.mic,
    Icons.movie_creation,
    Icons.palette,
    Icons.pets,
    Icons.radio,
    Icons.restaurant_menu,
    Icons.shopping_cart,
    Icons.star,
    Icons.today,
  ];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              enableAlpha: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() {
    final listName = _textEditingController.text.trim();
    if (listName.isNotEmpty) {
      widget.onListInfoSaved(listName, selectedIcon, selectedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Create List',
                    style: TextStyle(
                      color: selectedColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected icon display
                    Center(
                      child: Icon(
                        selectedIcon,
                        color: selectedColor,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Text field
                    TextField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "List name",
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 18,
                      ),
                      maxLength: 16,
                      onSubmitted: (_) => _handleSave(),
                    ),
                    const SizedBox(height: 20),
                    // Color picker button
                    Text(
                      'Color',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Tap to change color',
                            style: TextStyle(
                              color: selectedColor.computeLuminance() > 0.5 
                                  ? Colors.black 
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Icon selection
                    Text(
                      'Icon',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: iconList.length,
                        itemBuilder: (context, index) {
                          final iconData = iconList[index];
                          final isSelected = selectedIcon == iconData;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIcon = iconData;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? selectedColor.withOpacity(0.2) 
                                    : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? Border.all(color: selectedColor, width: 2)
                                    : Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                              ),
                              child: Icon(
                                iconData,
                                size: 24,
                                color: isSelected 
                                    ? selectedColor 
                                    : colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}