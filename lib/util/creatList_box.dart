import 'package:flutter/material.dart';

import 'myButton.dart';

class CreateListBox extends StatefulWidget {
  final Function(String, IconData, Color) onListInfoSaved;

  const CreateListBox({
    super.key,
    required this.onListInfoSaved,
  });

  @override
  _CreateListBoxState createState() => _CreateListBoxState();
}

class _CreateListBoxState extends State<CreateListBox> {
  IconData selectedIcon = Icons.list;
  late TextEditingController _textEditingController;
  Color selectedColor = Colors.blue;

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

  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow[600]!,
    Colors.green[900]!,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void handleBackButtonPressed() {
    Navigator.of(context).pop();
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: Theme.of(context).colorScheme.secondary, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 460,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Create List",
              style: TextStyle(
                color: selectedColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              selectedIcon,
              color: selectedColor,
              size: 45,
            ),
            const SizedBox(height: 5),
            TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.none,
                decorationThickness: 0,
              ),
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                hintText: "Name of the list",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              maxLines: 1,
              maxLength: 16,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorList.length,
                    itemBuilder: (context, index) {
                      final color = colorList[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 34,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Right edge gradient to indicate more items
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.0),
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  Scrollbar(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: iconList.length,
                      itemBuilder: (context, index) {
                        final iconData = iconList[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIcon = iconData;
                            });
                          },
                          child: Icon(
                            iconData,
                            size: 30,
                            color: selectedIcon == iconData
                                ? selectedColor
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.0),
                            Theme.of(context).colorScheme.surface,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton(
                  text: "Back",
                  onPressed: handleBackButtonPressed,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.secondary,
                  borderRadius: 15,
                ),
                MyButton(
                  text: "Create",
                  onPressed: () {
                    final listName = _textEditingController.text;
                    final iconData = selectedIcon;
                    final color = selectedColor;

                    if (listName.isNotEmpty) {
                      widget.onListInfoSaved(listName, iconData, color);
                    }
                    Navigator.of(context).pop();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  textColor: Theme.of(context).colorScheme.primary,
                  borderRadius: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
