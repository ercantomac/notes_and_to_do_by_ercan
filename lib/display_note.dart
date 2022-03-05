// ignore_for_file: use_key_in_widget_constructors
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class DisplayNote extends StatefulWidget {
  final String _a, _key, _date;
  final bool _starred;
  final Function _showMyDialog, _starNote, _unStarNote, _editNote, _animateDelete;
  const DisplayNote(this._a, this._key, this._starred, this._showMyDialog, this._starNote, this._unStarNote, this._editNote, this._animateDelete, this._date);
  @override
  _DisplayNoteState createState() => _DisplayNoteState();
}

class _DisplayNoteState extends State<DisplayNote> with SingleTickerProviderStateMixin {
  String writtenText = '';
  bool _autofocus = true;
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    writtenText = widget._a;
    _autofocus = true;
    myController.text = widget._a;
    myController.selection = TextSelection.fromPosition(TextPosition(offset: myController.text.length));
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }

  Widget _deleteWarningDialog() {
    return AlertDialog(
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
            setState(() {
              _autofocus = false;
            });
            widget._animateDelete(400);
          },
          child: const Text(
            'DELETE',
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
            widget._editNote(writtenText, widget._key);
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
        if (writtenText != widget._a) {
          widget._showMyDialog(_warningDialog);
        } else {
          Navigator.of(context).pop();
        }
        return false;
      },
      child: Hero(
        tag: widget._key,
        createRectTween: (Rect? begin, Rect? end) {
          return MaterialRectCenterArcTween(begin: begin, end: end);
        },
        child: Scaffold(
          backgroundColor: MyColors.dark,
          appBar: AppBar(
            backgroundColor: MyColors.medium,
            elevation: 0.0,
            leadingWidth: 42.0,
            titleTextStyle: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
            title: Text(
              widget._date,
              overflow: TextOverflow.visible,
            ),
            leading: IconButton(
              onPressed: () {
                if (writtenText != widget._a) {
                  widget._showMyDialog(_warningDialog);
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              AnimatedOpacity(
                opacity: ((writtenText == widget._a) ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: IconButton(
                  onPressed: (writtenText == widget._a)
                      ? () {
                          if (widget._starred == true) {
                            widget._unStarNote(widget._key);
                          } else {
                            widget._starNote(widget._key);
                          }
                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: Icon(
                    ((widget._starred == true) ? Icons.star : Icons.star_outline_outlined),
                    color: Colors.yellowAccent.shade400,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: ((writtenText == widget._a) ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: IconButton(
                  onPressed: (writtenText == widget._a)
                      ? () async {
                          AndroidIntent _intent = AndroidIntent(
                            action: 'android.intent.action.SEND',
                            type: 'text/plain',
                            arguments: <String, String>{'android.intent.extra.TEXT': widget._a},
                          );
                          await _intent.launchChooser('Choose an app');
                        }
                      : null,
                  icon: const Icon(
                    Icons.share_rounded,
                    color: MyColors.accent,
                  ),
                ),
              ),
              AnimatedContainer(
                curve: Curves.easeInOutCubic,
                duration: const Duration(milliseconds: 400),
                width: ((writtenText == widget._a) ? 0.0 : 46.0),
                child: IconButton(
                  onPressed: (writtenText != widget._a)
                      ? () {
                          setState(() {
                            _autofocus = false;
                          });
                          widget._editNote(writtenText, widget._key);
                          Navigator.of(context).pop();
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
          floatingActionButton: ((writtenText == widget._a)
              ? FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    widget._showMyDialog(_deleteWarningDialog);
                  },
                  backgroundColor: Colors.redAccent.shade400,
                  child: const Icon(
                    Icons.delete_rounded,
                    color: MyColors.dark,
                    size: 32.0,
                  ),
                )
              : null),
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
                controller: myController,
                onChanged: (String text) {
                  if (writtenText == widget._a || text == widget._a) {
                    setState(() {
                      writtenText = text;
                    });
                  } else {
                    writtenText = text;
                  }
                },
                enabled: _autofocus,
                autofocus: false,
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
                ),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: MyColors.light,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
