import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../feed/presentation/feed_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../study/presentation/study_log_screen.dart';
import '../../sync/application/sync_provider.dart';
import '../../sync/domain/sync_status.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(syncProvider.notifier).syncNow(trigger: SyncTrigger.foreground),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
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
