import 'package:flutter/material.dart';
import 'package:todo/util/myButton.dart';

class CreateListBox extends StatefulWidget {
  final Function(String, IconData) onListInfoSaved;
  final Function(IconData) onIconSelected; // Callback for icon selection

  CreateListBox({Key? key, required this.onListInfoSaved, required this.onIconSelected})
      : super(key: key);

  @override
  _CreateListBoxState createState() => _CreateListBoxState();
}

class _CreateListBoxState extends State<CreateListBox> {
  IconData selectedIcon = Icons.list;
  late TextEditingController _textEditingController;

  final List<IconData> iconList = [
    Icons.list,
    Icons.mood,
    Icons.music_note,
    Icons.key,
    Icons.card_giftcard, //row 1
    Icons.sunny,
    Icons.videogame_asset_rounded,
    Icons.cake,
    Icons.smart_toy_rounded,
    Icons.school_rounded, //row 2
    Icons.attach_file,
    Icons.attach_money,
    Icons.audiotrack,
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
    Icons.directions_railway,
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
    return AlertDialog(backgroundColor: Theme.of(context).colorScheme.background,
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
              "Create List",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Icon(
              selectedIcon,
              size: 45,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                        widget.onIconSelected(selectedIcon); // Pass the selected icon to the callback
                      },
                      child: Icon(
                        iconData,
                        size: 30,
                        color: selectedIcon == iconData
                            ? Theme.of(context).colorScheme.primary
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
                  text: "Create",
                  onPressed: () {
                    final listName = _textEditingController.text;
                    final iconData = selectedIcon;

                    if (listName.isNotEmpty && iconData != null) {
                      widget.onListInfoSaved(listName, iconData);
                      print(iconData);
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
