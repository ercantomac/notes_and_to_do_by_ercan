import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salva/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'package:salva/notes.dart';
import 'package:salva/starred.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      /*if (sp.getInt('firstTime') == null) {
        sp.clear();
        sp.setInt('firstTime', 1);
      }*/
      if (sp.getBool('isLaunchedBefore') != true) {
        sp.clear();
        sp.setBool('isLaunchedBefore', true);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: MyColors.dark,
      title: 'SALVA: Notes & To-Do',
      darkTheme: ThemeData(
        fontFamily: 'Manrope',
        brightness: Brightness.dark,
        primaryColor: MyColors.dark,
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: MyColors.accent,
        ),
        snackBarTheme: const SnackBarThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(64.0)),
            side: BorderSide(
              color: MyColors.accent,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: MyColors.dark,
          elevation: 0.0,
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          actionTextColor: Colors.white,
        ),
        dialogTheme: const DialogTheme(
          elevation: 12.0,
          backgroundColor: Color(0xFF424242),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
          titleTextStyle: TextStyle(
            fontSize: 22.0,
            fontFamily: 'Manrope',
          ),
          contentTextStyle: TextStyle(
            fontSize: 18.0,
            fontFamily: 'Manrope',
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => MyColors.medium),
            foregroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => Colors.white),
          ),
        ),
        textTheme: const TextTheme().apply(
          fontFamily: 'Manrope',
        ),
      ),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        appBar: null,
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: const <Widget>[
                Notes(),
                ToDoScreen(),
              ],
            ),
            Positioned(
              bottom: 8.0,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: const WormEffect(
                  activeDotColor: MyColors.accent,
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  radius: 8.0,
                  type: WormType.thin,
                ),
                /*effect: JumpingDotEffect(
                  activeDotColor: MyColors.accent,
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  radius: 8.0,
                ),
                effect: ScrollingDotsEffect(
                  activeDotScale: 1.75,
                  fixedCenter: true,
                  activeDotColor: MyColors.accent,
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  radius: 8.0,
                ),*/
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.sticky_note_2_outlined),
              label: 'Notes',
              backgroundColor: MyColors.dark,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              label: 'To-Do List',
              backgroundColor: MyColors.dark,
            ),
          ],
          elevation: 0.0,
          unselectedItemColor: MyColors.accent,
          selectedItemColor: MyColors.accent,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
          },
        ),
      ),
    );
  }
}

class Notes extends StatelessWidget {
  const Notes({Key? key}) : super(key: key);
  final TabBar _tabBar = const TabBar(
    indicatorColor: MyColors.accent,
    indicatorSize: TabBarIndicatorSize.label,
    labelColor: MyColors.accent,
    unselectedLabelColor: MyColors.light,
    padding: EdgeInsets.zero,
    labelPadding: EdgeInsets.zero,
    unselectedLabelStyle: TextStyle(fontSize: 0.0),
    tabs: <Widget>[
      SizedBox(
        height: kToolbarHeight,
        child: Tab(
          key: Key('All Notes'),
          icon: Icon(Icons.sticky_note_2_outlined),
          iconMargin: EdgeInsets.zero,
          text: 'All Notes',
        ),
      ),
      SizedBox(
        height: kToolbarHeight,
        child: Tab(
          key: Key('Starred'),
          icon: Icon(Icons.star_outline_outlined),
          iconMargin: EdgeInsets.zero,
          text: 'Starred',
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: MyColors.medium,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 2.0),
            child: AppBar(
              elevation: 0.0,
              backgroundColor: MyColors.dark,
              bottom: _tabBar,
              systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
              ),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: const TabBarView(
              children: <Widget>[
                NotesScreen(),
                StarredScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
