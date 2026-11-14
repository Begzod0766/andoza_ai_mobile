import 'package:shared_preferences/shared_preferences.dart';

/// Set once the user finishes or skips the home tour. An interrupted tour
/// never writes it, so the tour is offered again on the next launch.
const homeTourDoneKey = 'tour.home.v1.done';

bool isHomeTourDone(SharedPreferences prefs) =>
    prefs.getBool(homeTourDoneKey) ?? false;

Future<void> markHomeTourDone(SharedPreferences prefs) =>
    prefs.setBool(homeTourDoneKey, true);
