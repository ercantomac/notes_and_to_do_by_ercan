import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salva/new_note.dart';
import 'package:salva/my_notes.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with TickerProviderStateMixin {
  int _numberOfNotes = 0;
  final List<String> _notes = <String>[], _keys = <String>[], _dates = <String>[];
  final List<bool> _isStarred = <bool>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfNotes') != null) {
        _numberOfNotes = sp.getInt('numberOfNotes')!;
      }
      for (int i = (_numberOfNotes - 1); i >= 0; i--) {
        _notes.add(sp.getString('note_$i')!);
        _isStarred.add(sp.getBool('isStarred_$i')!);
        _keys.add('note_$i');
        _dates.add(sp.getString('date_$i')!);
      }
      setState(() {});
    });
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

  void _getNotes() {
    _notes.clear();
    _isStarred.clear();
    _keys.clear();
    _numberOfNotes = 0;
    _dates.clear();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfNotes') != null) {
        _numberOfNotes = sp.getInt('numberOfNotes')!;
      }
      for (int i = (_numberOfNotes - 1); i >= 0; i--) {
        _notes.add(sp.getString('note_$i')!);
        _isStarred.add(sp.getBool('isStarred_$i')!);
        _keys.add('note_$i');
        _dates.add(sp.getString('date_$i')!);
      }
      setState(() {});
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
    _date += '${now.day}, ${now.year}\n${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return _date;
  }

  void _saveNote(String newNote) {
    String _date = _getDate();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sp.setString('note_$_numberOfNotes', newNote);
      sp.setBool('isStarred_$_numberOfNotes', false);
      sp.setInt('numberOfNotes', (_numberOfNotes + 1));
      sp.setString('date_$_numberOfNotes', _date);
      _getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thickness: 3.0,
      thumbColor: MyColors.accent,
      scrollbarOrientation: ScrollbarOrientation.right,
      interactive: true,
      minThumbLength: 36.0,
      crossAxisMargin: 3.0,
      radius: const Radius.circular(24.0),
      child: SingleChildScrollView(
        restorationId: 'NotesScreen',
        key: const PageStorageKey<String>('NotesScreen'),
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OutlinedButton.icon(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(64.0)),
                    ),
                  ),
                  side: MaterialStateProperty.all(
                    BorderSide.none,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    MyColors.dark,
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    MyColors.accent,
                  ),
                ),
                onPressed: () {
                  MyRoute<dynamic> route = MyRoute<dynamic>(builder: (_) => NewNote(_saveNote));
                  Navigator.of(context).push(route);
                },
                icon: const Icon(
                  Icons.add_rounded,
                  size: 32.0,
                ),
                label: const Hero(
                  tag: 'FAB',
                  child: Text(
                    'New Note',
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: TextStyle(
                      color: MyColors.dark,
                      fontSize: 18.0,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              (_numberOfNotes == 0)
                  ? const SizedBox(
                      height: 192.0,
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'No notes yet.',
                            style: TextStyle(
                              color: MyColors.light,
                            ),
                          )))
                  : GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      childAspectRatio: 16 / 9,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      crossAxisCount: 2,
                      children: <Widget>[
                          for (int i = 0; i < _notes.length; i++) MyNotes(_notes[i], _keys[i], _isStarred[i], _getNotes, _numberOfNotes, _dates[i])
                        ]),
            ],
          ),
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
