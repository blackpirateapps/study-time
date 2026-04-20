import 'package:flutter/cupertino.dart';

import '../../feed/presentation/feed_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../study/presentation/study_log_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: const CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.timer_fill),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2_fill),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar_alt_fill),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        late final Widget child;

        switch (index) {
          case 0:
            child = const StudyLogScreen();
            break;
          case 1:
            child = const FeedScreen();
            break;
          case 2:
            child = const ProfileScreen();
            break;
          default:
            child = const StudyLogScreen();
            break;
        }

        return CupertinoTabView(builder: (_) => child);
      },
    );
  }
}
