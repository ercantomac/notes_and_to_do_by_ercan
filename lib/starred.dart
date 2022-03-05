import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'package:salva/my_notes.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({Key? key}) : super(key: key);
  @override
  _StarredScreenState createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen> {
  int _numberOfNotes = 0;
  final List<String> _starredNotes = <String>[], _keys = <String>[], _dates = <String>[];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfNotes') != null) {
        _numberOfNotes = sp.getInt('numberOfNotes')!;
      }
      for (int i = (_numberOfNotes - 1); i >= 0; i--) {
        if (sp.getBool('isStarred_$i') == true) {
          _starredNotes.add(sp.getString('note_$i')!);
          _keys.add('note_$i');
          _dates.add(sp.getString('date_$i')!);
        }
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
    _starredNotes.clear();
    _keys.clear();
    _numberOfNotes = 0;
    _dates.clear();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      if (sp.getInt('numberOfNotes') != null) {
        _numberOfNotes = sp.getInt('numberOfNotes')!;
      }
      for (int i = (_numberOfNotes - 1); i >= 0; i--) {
        if (sp.getBool('isStarred_$i') == true) {
          _starredNotes.add(sp.getString('note_$i')!);
          _keys.add('note_$i');
          _dates.add(sp.getString('date_$i')!);
        }
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

  @override
  Widget build(BuildContext context) {
    return (_starredNotes.isEmpty)
        ? const Center(
            child: Text(
              'No starred notes yet.',
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
            child: SingleChildScrollView(
              restorationId: 'StarredScreen',
              key: const PageStorageKey<String>('StarredScreen'),
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  childAspectRatio: 16 / 9,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  crossAxisCount: 2,
                  children: <Widget>[
                    for (int i = 0; i < _starredNotes.length; i++) MyNotes(_starredNotes[i], _keys[i], true, _getNotes, _numberOfNotes, _dates[i])
                  ],
                ),
              ),
            ),
          );
  }
}
