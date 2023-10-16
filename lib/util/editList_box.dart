import 'package:flutter/material.dart';

import 'myButton.dart';

class EditListBox extends StatefulWidget {
  final String listId;
  final String initialListName;
  final IconData initialIconData;
  final Function(String, IconData,Color) onListInfoUpdated;
  final Color initialListColor;

  EditListBox({
    Key? key,
    required this.listId,
    required this.initialListName,
    required this.initialIconData,
    required this.onListInfoUpdated,
    required this.initialListColor,
  }) : super(key: key);

  @override
  _EditListBoxState createState() => _EditListBoxState();
}

class _EditListBoxState extends State<EditListBox> {
  TextEditingController? _textEditingController;
  IconData? selectedIcon;
  Color selectedColor = Colors.blue;

  final List<IconData> iconList = [
    Icons.list,
    Icons.mood,
    Icons.music_note,
    Icons.key,
    Icons.check,
    Icons.card_giftcard, //row 1
    Icons.sunny,
    Icons.videogame_asset_rounded,
    Icons.cake,
    Icons.smart_toy_rounded,
    Icons.school_rounded, //row 2
    Icons.attach_file,
    Icons.attach_money,
    Icons.camera_alt,
    Icons.book,
    Icons.border_all, // row 3
    Icons.business,
    Icons.check_circle,
    Icons.child_friendly,
    Icons.chrome_reader_mode,
    Icons.code, // Row 4
    Icons.desktop_windows,
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.favorite,
    Icons.directions_car, // Row 5
    Icons.directions_subway,
    Icons.directions_walk,
    Icons.euro_symbol,
    Icons.face, // Row 6
    Icons.flag,
    Icons.house,
    Icons.gamepad,
    Icons.headset_mic,
    Icons.hourglass_empty, // Row 7
    Icons.language,
    Icons.laptop_mac,
    Icons.local_cafe,
    Icons.local_library,
    Icons.local_movies, // Row 8
    Icons.mail_outline,
    Icons.mic,
    Icons.movie_creation,
    Icons.palette,
    Icons.pets, // Row 9
    Icons.radio,
    Icons.restaurant_menu,
    Icons.shopping_cart,
    Icons.star,
    Icons.today, // Row 10
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
    _textEditingController =
        TextEditingController(text: widget.initialListName);
    selectedIcon = widget.initialIconData;
    selectedColor = widget.initialListColor;
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  void handleBackButtonPressed() {
    Navigator.of(context).pop();
    _textEditingController?.clear();
  }
  void updateListInfo(String listName, IconData iconData,Color color) {
    // Pass the correct iconData as the second argument
    widget.onListInfoUpdated(listName, iconData, color);
  }




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: 250,
        height: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Edit List",
              style: TextStyle(
                color: selectedColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Icon(
              selectedIcon,
              color: selectedColor,
              size: 45,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
              ),
              cursorColor: Theme.of(context).colorScheme.primary,
              maxLines: 1,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 10,),
            SizedBox(
              height: 40,  // Set a fixed height to ensure only one row is visible.
              child: ListView.builder(
                scrollDirection: Axis.horizontal,  // Set the scroll direction to horizontal.
                itemCount: colorList.length,
                itemBuilder: (context, index) {
                  final color = colorList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color; // Setze die ausgewählte Farbe
                      });
                    },
                    child: Container(
                      width: 34,  // Set a fixed width for the color boxes.
                      margin: const EdgeInsets.symmetric(horizontal: 4), // Optional, add some space between the boxes.
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
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8.0,
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
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                  text: "Back",
                  onPressed: handleBackButtonPressed,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.secondary,
                  borderRadius: 15,
                ),
                const SizedBox(width: 70),
                MyButton(
                  text: "Save",
                  onPressed: () {
                    final listName = _textEditingController?.text;
                    final iconData = selectedIcon;
                    final listColor = selectedColor;

                    if (listName!.isNotEmpty) {
                      // Call the function to update the list information
                      updateListInfo(listName, iconData!,listColor);

                      // Close the dialog
                      Navigator.of(context).pop();
                    }
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
