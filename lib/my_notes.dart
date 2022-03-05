// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'package:salva/display_note.dart';

class MyNotes extends StatefulWidget {
  final String _a, _key, _date;
  final bool _starred;
  final Function _getNotes;
  final int _numberOfNotes;
  const MyNotes(this._a, this._key, this._starred, this._getNotes, this._numberOfNotes, this._date);
  @override
  _MyNotesState createState() => _MyNotesState();
}

class _MyNotesState extends State<MyNotes> with TickerProviderStateMixin {
  late AnimationController _controllerA;
  Color _noteColor = MyColors.dark, _noteTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _controllerA = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    _controllerA.dispose();
  }

  void _animateDelete(int _duration) {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    Future<Object?>.delayed(Duration(milliseconds: _duration), () {
      _controllerA.reset();
      _controllerA.forward();
      return null;
    });
    Future<Object?>.delayed(Duration(milliseconds: (_duration + 100)), () {
      _reverseColorTransition();
      return null;
    });
    Future<Object?>.delayed(Duration(milliseconds: (_duration + 550)), () {
      _deleteNote(widget._key);
      _controllerA.reset();
      return null;
    });
  }

  void _reverseColorTransition() {
    setState(() {
      _noteColor = MyColors.dark;
      _noteTextColor = Colors.white;
    });
  }

  Widget _deleteWarningDialog() {
    return WillPopScope(
      onWillPop: () async {
        _reverseColorTransition();
        Navigator.of(context).pop();
        return false;
      },
      child: AlertDialog(
        title: const Text(
          'Delete Note',
          textAlign: TextAlign.center,
        ),
        //titleTextStyle: TextStyle(color: Colors.redAccent.shade400),
        content: const Text('Are you sure you want to delete this note?'),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => Colors.redAccent.shade400)),
            onPressed: () {
              _animateDelete(300);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          TextButton(
            onPressed: () {
              _reverseColorTransition();
              Navigator.of(context).pop();
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
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
    _date += '${now.day}, ${now.year}\n${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return _date;
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 24.0),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _deleteNote(String a) {
    int i = 0;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      for (int j = 0; j < widget._numberOfNotes; j++) {
        if ('note_$j' == a) {
          i = j;
          break;
        }
      }
      sp.remove(a);
      sp.remove('isStarred_$i');
      sp.remove('date_$i');
      for (int j = i + 1; j < widget._numberOfNotes; j++) {
        String note = sp.getString('note_$j')!;
        sp.remove('note_$j');
        sp.setString('note_${j - 1}', note);
        bool starred = sp.getBool('isStarred_$j')!;
        sp.remove('isStarred_$j');
        sp.setBool('isStarred_${j - 1}', starred);
        String date = sp.getString('date_$j')!;
        sp.remove('date_$j');
        sp.setString('date_${j - 1}', date);
      }
      sp.setInt('numberOfNotes', (widget._numberOfNotes - 1));
      widget._getNotes();
    });
    _showSnackBar('Note deleted.');
  }

  void _starNote(String a) {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      for (int j = 0; j < widget._numberOfNotes; j++) {
        if ('note_$j' == a) {
          sp.setBool('isStarred_$j', true);
          break;
        }
      }
      widget._getNotes();
    });
    _showSnackBar('Note starred.');
  }

  void _unStarNote(String a) {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      for (int j = 0; j < widget._numberOfNotes; j++) {
        if ('note_$j' == a) {
          sp.setBool('isStarred_$j', false);
          break;
        }
      }
      widget._getNotes();
    });
    _showSnackBar('Note unstarred.');
  }

  void _editNote(String newNote, String a) {
    String index = a.substring(a.length - 1);
    String _date = _getDate();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sp.setString(a, newNote);
      sp.setString('date_$index', _date);
      widget._getNotes();
    });
    _showSnackBar('Note edited.');
  }

  Future<Object?> _showMyDialog(Widget Function() dialog) {
    return showGeneralDialog(
        context: context,
        useRootNavigator: true,
        pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
          return dialog();
        },
        barrierDismissible: true,
        barrierLabel: '',
        transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOutCubic).drive(Tween<double>(begin: 0.0, end: 1.0)),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOutCubicEmphasized).drive(Tween<double>(begin: 0.0, end: 1.0)),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        setState(() {
          _noteColor = MyColors.accent;
          _noteTextColor = MyColors.dark;
        });
        showModalBottomSheet<void>(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          ),
          enableDrag: false,
          backgroundColor: MyColors.medium,
          transitionAnimationController: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 400),
          ),
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                _reverseColorTransition();
                Navigator.of(context).pop();
                return false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    horizontalTitleGap: 8.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
                    ),
                    leading: Icon(
                      ((widget._starred == true) ? Icons.star : Icons.star_outline_outlined),
                      size: 32.0,
                      color: Colors.yellowAccent.shade400,
                    ),
                    title: Text(
                      ((widget._starred == true) ? 'Unstar Note' : 'Star Note'),
                      style: TextStyle(
                        color: Colors.yellowAccent.shade400,
                        fontSize: 18.0,
                      ),
                    ),
                    onTap: () {
                      if (widget._starred == true) {
                        _unStarNote(widget._key);
                      } else {
                        _starNote(widget._key);
                      }
                      _reverseColorTransition();
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(
                    height: 0.0,
                    thickness: 0.5,
                    color: MyColors.dark,
                  ),
                  ListTile(
                    horizontalTitleGap: 8.0,
                    leading: Icon(
                      Icons.delete_rounded,
                      size: 32.0,
                      color: Colors.redAccent.shade400,
                    ),
                    title: Text(
                      'Delete Note',
                      style: TextStyle(
                        color: Colors.redAccent.shade400,
                        fontSize: 18.0,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showMyDialog(_deleteWarningDialog);
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ],
              ),
            );
          },
        );
      },
      onTap: () {
        MyRoute<dynamic> route = MyRoute<dynamic>(
            builder: (_) =>
                DisplayNote(widget._a, widget._key, widget._starred, _showMyDialog, _starNote, _unStarNote, _editNote, _animateDelete, widget._date));
        Navigator.of(context).push(route);
      },
      child: Hero(
        tag: widget._key,
        createRectTween: (Rect? begin, Rect? end) {
          return MaterialRectCenterArcTween(begin: begin, end: end);
        },
        child: AnimatedBuilder(
          animation: _controllerA,
          builder: (BuildContext context, _) {
            return Transform.scale(
              scale: Tween<double>(begin: 1.0, end: 0.3)
                  .animate(CurvedAnimation(
                    parent: _controllerA,
                    curve: Curves.easeInOutCubic,
                  ))
                  .value,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                  parent: _controllerA,
                  curve: Curves.easeInOutCubic,
                )),
                child: AnimatedContainer(
                  padding: const EdgeInsets.all(8.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white24,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    shadows: const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0.0, 3.0),
                        blurRadius: 5.0,
                      ),
                    ],
                    color: _noteColor,
                  ),
                  child: Stack(
                    children: <Widget>[
                      if (widget._starred == true)
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.star,
                            color: Colors.yellowAccent.shade400,
                            size: 20.0,
                          ),
                        ),
                      Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          style: TextStyle(
                            color: _noteTextColor,
                            fontSize: 16.0,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                          child: Text(widget._a),
                        ),
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

class MyRoute<T> extends MaterialPageRoute<T> {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);
}
