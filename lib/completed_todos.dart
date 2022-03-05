import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

class CompletedTodos extends StatefulWidget {
  const CompletedTodos({Key? key}) : super(key: key);

  @override
  _CompletedTodosState createState() => _CompletedTodosState();
}

class _CompletedTodosState extends State<CompletedTodos> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _numberOfCompletedTodos = 0;
  bool _noCompletedTasksYet = false;
  final List<String> _completedTodos = <String>[], _completedTodosDates = <String>[], _completionDates = <String>[];
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfCompletedTodos') != null) {
        _numberOfCompletedTodos = sp.getInt('numberOfCompletedTodos')!;
      }
      for (int i = 0; i < _numberOfCompletedTodos; i++) {
        if (sp.getString('completedTodos_$i') != null) {
          _completedTodos.add(sp.getString('completedTodos_$i')!);
        }
        if (sp.getString('completedTodosDates_$i') != null) {
          _completedTodosDates.add(sp.getString('completedTodosDates_$i')!);
        }
        if (sp.getString('completionDate_$i') != null) {
          _completionDates.add(sp.getString('completionDate_$i')!);
        }
      }
      if (_completedTodos.isEmpty == true) {
        _noCompletedTasksYet = true;
      } else {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _insertItems();
        });
      }
      setState(() {});
    });
  }

  void _getTodos() {
    _numberOfCompletedTodos = 0;
    _completedTodos.clear();
    _completedTodosDates.clear();
    _completionDates.clear();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfCompletedTodos') != null) {
        _numberOfCompletedTodos = sp.getInt('numberOfCompletedTodos')!;
      }
      for (int i = 0; i < _numberOfCompletedTodos; i++) {
        if (sp.getString('completedTodos_$i') != null) {
          _completedTodos.add(sp.getString('completedTodos_$i')!);
        }
        if (sp.getString('completedTodosDates_$i') != null) {
          _completedTodosDates.add(sp.getString('completedTodosDates_$i')!);
        }
        if (sp.getString('completionDate_$i') != null) {
          _completionDates.add(sp.getString('completionDate_$i')!);
        }
      }
      if (_completedTodos.isEmpty == true) {
        Future<Object?>.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            _noCompletedTasksYet = true;
          });
          return null;
        });
      } else {
        setState(() {
          _noCompletedTasksYet = false;
        });
      }
    });
  }

  void _insertItems() {
    Future<Object?>.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _numberOfCompletedTodos; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 600));
      }
      return null;
    });
  }

  void _deleteCompletedTask(int index) {
    String a = 'completedTodos_$index';
    int i = 0;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      for (int j = 0; j < _numberOfCompletedTodos; j++) {
        if ('completedTodos_$j' == a) {
          i = j;
          break;
        }
      }
      sp.remove(a);
      sp.remove('completedTodosDates_$i');
      sp.remove('completionDate_$i');
      for (int j = i + 1; j < _numberOfCompletedTodos; j++) {
        String _todo = sp.getString('completedTodos_$j')!;
        sp.remove('completedTodos_$j');
        sp.setString('completedTodos_${j - 1}', _todo);
        String _date = sp.getString('completedTodosDates_$j')!;
        sp.remove('completedTodosDates_$j');
        sp.setString('completedTodosDates_${j - 1}', _date);
        String _completionDate = sp.getString('completionDate_$j')!;
        sp.remove('completionDate_$j');
        sp.setString('completionDate_${j - 1}', _completionDate);
      }
      sp.setInt('numberOfCompletedTodos', (_numberOfCompletedTodos - 1));
      _getTodos();
    });

    String removed = _completedTodos[index], removedDate = _completionDates[index];
    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) => SizeTransition(
        sizeFactor: animation.drive(Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic.flipped))),
        axisAlignment: 1.0,
        child: Container(
          color: MyColors.medium,
          child: ListTile(
            title: Text(
              '${index + 1}. $removed',
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Completed on $removedDate',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            minLeadingWidth: 0.0,
            leading: const Icon(
              Icons.check_circle,
              color: MyColors.accent,
            ),
            trailing: Icon(
              Icons.clear,
              color: Colors.redAccent.shade400,
            ),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.dark,
      appBar: AppBar(
        backgroundColor: MyColors.medium,
        elevation: 0.0,
        centerTitle: true,
        leadingWidth: 42.0,
        toolbarHeight: (kToolbarHeight + 2.0),
        title: const Text('Completed Tasks'),
      ),
      body: (_noCompletedTasksYet == true)
          ? const Center(
              child: Text(
                'No completed tasks yet.',
                style: TextStyle(
                  color: MyColors.light,
                ),
              ),
            )
          : RawScrollbar(
              thickness: 3.0,
              thumbColor: MyColors.accent,
              scrollbarOrientation: ScrollbarOrientation.right,
              interactive: true,
              minThumbLength: 36.0,
              crossAxisMargin: 3.0,
              radius: const Radius.circular(24.0),
              child: AnimatedList(
                  key: _listKey,
                  physics: const BouncingScrollPhysics(),
                  initialItemCount: _completedTodos.length,
                  itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                    return SlideTransition(
                      position: animation.drive(Tween<Offset>(begin: Offset(0.0, (2.0 * ((index + 1) * 3))), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))),
                      child: FadeTransition(
                        opacity: animation.drive(Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut))),
                        child: Container(
                          color: MyColors.medium,
                          child: Column(
                            children: <Widget>[
                              Tooltip(
                                message: 'Created on ${_completedTodosDates[index]}',
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                child: ListTile(
                                  title: Text(
                                    '${index + 1}. ${_completedTodos[index]}',
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Completed on ${_completionDates[index]}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  minLeadingWidth: 0.0,
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: MyColors.accent,
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      _deleteCompletedTask(index);
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.redAccent.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0.0,
                                thickness: 0.5,
                                color: MyColors.dark,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
