// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'colors.dart';

class NewNote extends StatefulWidget {
  final Function _saveNote;
  const NewNote(this._saveNote);

  @override
  _NewNoteState createState() => _NewNoteState();
}

class _NewNoteState extends State<NewNote> {
  String _newNote = '', _writtenText = '';
  bool _autofocus = true;

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

  Widget _warningDialog() {
    return AlertDialog(
      title: const Text(
        'Note Not Saved',
        textAlign: TextAlign.center,
      ),
      //titleTextStyle: const TextStyle(color: MyColors.accent),
      content: const Text("You didn't save your note. Quit anyway?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              _autofocus = false;
            });
            Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
          },
          child: const Text(
            'QUIT',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        TextButton(
          style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => MyColors.accent)),
          onPressed: () {
            setState(() {
              _autofocus = false;
            });
            _newNote = _writtenText;
            widget._saveNote(_newNote);
            Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
          },
          child: const Text(
            'SAVE',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'CANCEL',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_writtenText != '') {
          _showMyDialog(_warningDialog);
        } else {
          Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: MyColors.dark,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: MyColors.medium,
          centerTitle: true,
          leadingWidth: 42.0,
          title: const Hero(
            tag: 'FAB',
            child: Text(
              'New Note',
              overflow: TextOverflow.visible,
              softWrap: false,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              if (_writtenText != '') {
                _showMyDialog(_warningDialog);
              } else {
                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
              }
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            AnimatedOpacity(
              opacity: ((_writtenText == '') ? 0.0 : 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: IconButton(
                onPressed: (_writtenText != '')
                    ? () {
                        _newNote = _writtenText;
                        widget._saveNote(_newNote);
                        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                      }
                    : null,
                icon: const Icon(
                  Icons.task_alt_rounded,
                  color: MyColors.accent,
                ),
              ),
            ),
          ],
        ),
        body: RawScrollbar(
          thickness: 3.0,
          thumbColor: MyColors.accent,
          scrollbarOrientation: ScrollbarOrientation.right,
          interactive: true,
          minThumbLength: 36.0,
          crossAxisMargin: 3.0,
          radius: const Radius.circular(24.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: TextField(
              onChanged: (String text) {
                if (_writtenText == '' || text == '') {
                  setState(() {
                    _writtenText = text;
                  });
                } else {
                  _writtenText = text;
                }
              },
              enabled: _autofocus,
              autofocus: true,
              cursorColor: MyColors.accent,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              maxLines: null,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: (MediaQuery.of(context).size.height - 150)),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: 'Enter new note.',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
