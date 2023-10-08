import 'package:flutter/material.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';

class MyAppBar extends StatelessWidget {
  final Stream<String?> titleStream;
  final Stream<int> iconStream;
  final List<Map<String, dynamic>> todos;

  MyAppBar({required this.titleStream,required this.iconStream, required this.todos});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      toolbarHeight: 60.0,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      title: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 45,
                    child: CircleProgressBar(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      value: todos.isEmpty
                          ? 0.0
                          : todos.where((task) => task['taskCompleted']).length /
                          todos.length,
                      animationDuration: const Duration(seconds: 1),
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: iconStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        print('[Error] StreamBuilder: ${snapshot.error}');
                        return const Icon(
                          Icons.error,
                          size: 20,
                        );
                      } else if (snapshot.hasData) {
                        return Icon(
                          IconData(snapshot.data!,
                              fontFamily: 'MaterialIcons'),
                          size: 20,
                        );
                      } else {
                        return const Icon(
                          Icons.view_list_rounded,
                          size: 20,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 10,),
              StreamBuilder<String?>(
                stream: titleStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  } else {
                    return Text(
                      "Todo Listo",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
