/// The Studio's first-run tour runs in the web page, but the screen's Back
/// button is native and would stay sharp and tappable over the tour's blur.
///
/// The page posts `open` / `closed` to the [studioTourChannel] JavaScript
/// channel (frontend `notifyAppTour`); the screen hides its Back button while
/// the tour is open, and its system Back runs [studioTourSkipJs], which ends
/// the tour like Skip instead of leaving the Studio.
library;

/// Name of the JavaScript channel the page posts the tour state to.
const studioTourChannel = 'AndozaStudioTour';

/// Page script that skips a running tour (frontend `TOUR_SKIP_EVENT`).
const studioTourSkipJs = "window.dispatchEvent(new Event('andoza:tour-skip'));";

/// True for `open`, false for `closed`, null for anything else.
bool? studioTourOpenFromMessage(String message) => switch (message) {
      'open' => true,
      'closed' => false,
      _ => null,
    };
