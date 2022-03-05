import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salva/completed_todos.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({Key? key}) : super(key: key);
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _numberOfTodos = 0, _numberOfCompletedTodos = 0;
  final List<String> _todos = <String>[], _keys = <String>[], _dates = <String>[];
  final List<bool> _isChecked = <bool>[];
  String _newNote = '', _writtenText = '';
  final TextEditingController _myController = TextEditingController();
  bool _noTodosYet = false;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfTodos') != null) {
        _numberOfTodos = sp.getInt('numberOfTodos')!;
      }
      if (sp.getInt('numberOfCompletedTodos') != null) {
        _numberOfCompletedTodos = sp.getInt('numberOfCompletedTodos')!;
      }
      for (int i = 0; i < _numberOfTodos; i++) {
        if (sp.getString('todo_$i') != null && sp.getString('todoDate_$i') != null) {
          _todos.add(sp.getString('todo_$i')!);
          _dates.add(sp.getString('todoDate_$i')!);
          _keys.add('todo_$i');
          _isChecked.add(false);
        }
      }
      if (_todos.isEmpty == true) {
        _noTodosYet = true;
      } else {
        WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          _insertItems();
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _myController.dispose();
  }

  Future<Object?> _handleTap(bool _enabled, int index) {
    _newNote = '';
    _writtenText = '';
    return showGeneralDialog(
        barrierDismissible: !_enabled,
        pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              Future<Object?>.delayed(const Duration(milliseconds: 400), () {
                if (_writtenText != '') {
                  _newNote = _writtenText;
                  if (_enabled == false) {
                    _editTodo(_newNote, _keys[index]);
                  } else {
                    _saveTodo(_newNote);
                  }
                }
                return null;
              });
              return false;
            },
            child: AlertDialog(
              backgroundColor: MyColors.dark,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                side: BorderSide(color: MyColors.accent),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (_enabled == false)
                    Text(
                      _dates[index],
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  if (_enabled == false) const SizedBox(height: 16.0),
                  TextField(
                    controller: (_enabled == false) ? _myController : null,
                    onChanged: (String text) {
                      _writtenText = text;
                    },
                    enabled: true,
                    autofocus: _enabled,
                    cursorColor: MyColors.accent,
                    scrollPhysics: const BouncingScrollPhysics(),
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Add new task.',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future<Object?>.delayed(const Duration(milliseconds: 400), () {
                      if (_writtenText != '') {
                        _newNote = _writtenText;
                        if (_enabled == false) {
                          _editTodo(_newNote, _keys[index]);
                        } else {
                          _saveTodo(_newNote);
                        }
                      }
                      return null;
                    });
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    color: MyColors.accent,
                  ),
                ),
              ],
            ),
          );
        },
        context: context,
        useRootNavigator: true,
        barrierLabel: '',
        transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: anim1,
                //curve: Curves.easeInOutQuart,
                curve: Curves.easeOutCubic,
              ).drive(Tween<double>(begin: 0.0, end: 1.0)),
              child: SizeTransition(
                axis: Axis.horizontal,
                axisAlignment: -1.0,
                sizeFactor: CurvedAnimation(
                  parent: anim1,
                  //curve: Curves.easeInOut,
                  curve: Curves.linear,
                ).drive(Tween<double>(begin: 0.0, end: 1.0)),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400));
  }

  void _getTodos() {
    _todos.clear();
    _keys.clear();
    _numberOfTodos = 0;
    _numberOfCompletedTodos = 0;
    _isChecked.clear();
    _dates.clear();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfTodos') != null) {
        _numberOfTodos = sp.getInt('numberOfTodos')!;
      }
      if (sp.getInt('numberOfCompletedTodos') != null) {
        _numberOfCompletedTodos = sp.getInt('numberOfCompletedTodos')!;
      }
      for (int i = 0; i < _numberOfTodos; i++) {
        if (sp.getString('todo_$i') != null && sp.getString('todoDate_$i') != null) {
          _todos.add(sp.getString('todo_$i')!);
          _dates.add(sp.getString('todoDate_$i')!);
          _keys.add('todo_$i');
          _isChecked.add(false);
        }
      }
      if (_todos.isEmpty == true) {
        Future<Object?>.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            _noTodosYet = true;
          });
          return null;
        });
      } else {
        setState(() {
          _noTodosYet = false;
        });
      }
    });
  }

  void _insertItems() {
    Future<Object?>.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _numberOfTodos; i++) {
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 600));
      }
      return null;
    });
  }

  String _getDate() {
    DateTime now = DateTime.now();
    String _date = '';
    switch (now.weekday) {
      case 1:
        _date += 'Monday, ';
        break;
      case 2:
        _date += 'Tuesday, ';
        break;
      case 3:
        _date += 'Wednesday, ';
        break;
      case 4:
        _date += 'Thursday, ';
        break;
      case 5:
        _date += 'Friday, ';
        break;
      case 6:
        _date += 'Saturday, ';
        break;
      case 7:
        _date += 'Sunday, ';
        break;
    }
    switch (now.month) {
      case 1:
        _date += 'January ';
        break;
      case 2:
        _date += 'February ';
        break;
      case 3:
        _date += 'March ';
        break;
      case 4:
        _date += 'April ';
        break;
      case 5:
        _date += 'May ';
        break;
      case 6:
        _date += 'June ';
        break;
      case 7:
        _date += 'July ';
        break;
      case 8:
        _date += 'August ';
        break;
      case 9:
        _date += 'September ';
        break;
      case 10:
        _date += 'October ';
        break;
      case 11:
        _date += 'November ';
        break;
      case 12:
        _date += 'December ';
        break;
    }
    _date += '${now.day}, ${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return _date;
  }

  void _saveTodo(String newTodo) {
    String _date = _getDate();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sp.setString('todo_$_numberOfTodos', newTodo);
      sp.setInt('numberOfTodos', (_numberOfTodos + 1));
      sp.setString('todoDate_$_numberOfTodos', _date);
      _listKey.currentState?.insertItem((_numberOfTodos), duration: const Duration(milliseconds: 600));
      _getTodos();
    });
  }

  void _editTodo(String newNote, String a) {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sp.setString(a, newNote);
      _getTodos();
    });
  }

  void _removeTodo(int index) {
    String a = 'todo_$index';
    int i = 0;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfCompletedTodos') != null) {
        _numberOfCompletedTodos = sp.getInt('numberOfCompletedTodos')!;
      }
      for (int j = 0; j < _numberOfTodos; j++) {
        if ('todo_$j' == a) {
          i = j;
          break;
        }
      }
      sp.setString('completedTodos_$_numberOfCompletedTodos', sp.getString(a)!);
      sp.setString('completedTodosDates_$_numberOfCompletedTodos', sp.getString('todoDate_$i')!);
      sp.setString('completionDate_$_numberOfCompletedTodos', _getDate());
      sp.setInt('numberOfCompletedTodos', (_numberOfCompletedTodos + 1));
      sp.remove(a);
      sp.remove('todoDate_$i');
      for (int j = i + 1; j < _numberOfTodos; j++) {
        String _todo = sp.getString('todo_$j')!;
        sp.remove('todo_$j');
        sp.setString('todo_${j - 1}', _todo);
        String _date = sp.getString('todoDate_$j')!;
        sp.remove('todoDate_$j');
        sp.setString('todoDate_${j - 1}', _date);
      }
      sp.setInt('numberOfTodos', (_numberOfTodos - 1));
      _getTodos();
    });

    String removed = _todos[index], removedDate = _dates[index];
    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) => SizeTransition(
        sizeFactor: animation.drive(Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic.flipped))),
        axisAlignment: 1.0,
        child: Container(
          color: MyColors.dark,
          child: ListTile(
            minLeadingWidth: 0.0,
            leading: Checkbox(
              visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
              shape: const CircleBorder(),
              activeColor: MyColors.accent,
              checkColor: MyColors.dark,
              value: true,
              onChanged: (bool? a) {},
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            title: Text(
              '${index + 1}. $removed',
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              removedDate,
              style: const TextStyle(
                color: Colors.grey,
              ),
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
      backgroundColor: MyColors.medium,
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: MyColors.dark,
        elevation: 0.0,
        toolbarHeight: (kToolbarHeight + 2.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /*TextButton(
              onPressed: () {
                Navigator.of(context).push(MyRoute<dynamic>(builder: (_) => const CompletedTodos()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Icon(
                    Icons.check_circle,
                    color: MyColors.accent,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Completed\nTasks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),*/
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MyRoute<dynamic>(builder: (_) => const CompletedTodos())),
              icon: const Icon(
                Icons.check_circle,
                color: MyColors.accent,
              ),
              label: const Text(
                'Completed\nTasks',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
            const Text(
              'To-Do List',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            /*TextButton(
              onPressed: () => _handleTap(true, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Icon(
                    Icons.add_circle_rounded,
                    color: MyColors.accent,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Add\nNew Task',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),*/
            TextButton.icon(
              onPressed: () => _handleTap(true, 0),
              icon: const Icon(
                Icons.add_circle_rounded,
                color: MyColors.accent,
              ),
              label: const Text(
                'New\nTask',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: (_noTodosYet == true)
          ? const Center(
              child: Text(
                'No tasks yet.',
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
                physics: const BouncingScrollPhysics(),
                key: _listKey,
                initialItemCount: _todos.length,
                itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                  return SlideTransition(
                    position: animation.drive(
                        Tween<Offset>(begin: Offset(0.0, (2.0 * ((index + 1) * 3))), end: Offset.zero).chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))),
                    child: FadeTransition(
                      opacity: animation.drive(Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut))),
                      child: Container(
                        color: MyColors.dark,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                _myController.text = _todos[index];
                                _handleTap(false, index);
                              },
                              minLeadingWidth: 0.0,
                              leading: Checkbox(
                                visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
                                shape: const CircleBorder(),
                                activeColor: MyColors.accent,
                                checkColor: MyColors.dark,
                                value: _isChecked[index],
                                onChanged: (bool? value) {
                                  timeDilation = 2.0;
                                  setState(() {
                                    _isChecked[index] = value!;
                                  });
                                  Future<Object?>.delayed(const Duration(milliseconds: 700), () {
                                    timeDilation = 1.0;
                                    _removeTodo(index);
                                    return null;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                              title: Text(
                                '${index + 1}. ${_todos[index]}',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                _dates[index],
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const Divider(
                              height: 0.0,
                              thickness: 0.5,
                              color: MyColors.medium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class MyRoute<T> extends CupertinoPageRoute<T> {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
