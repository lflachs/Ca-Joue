import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class containing the typography styles for the Ça Joue application.
class CaJoueTypography {
  const CaJoueTypography._();

  /// Expression title — DM Serif Display 400, 28px / 34px.
  static final TextStyle expressionTitle = GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.214,
  );

  /// App title — DM Serif Display 400, 48px.
  static final TextStyle appTitle = GoogleFonts.dmSerifDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.167,
  );

  /// UI label — Inter 600, 11px.
  static final TextStyle uiLabel = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.273,
  );

  /// UI body text — Inter 400, 15px / 20px.
  static final TextStyle uiBody = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.333,
  );

  /// UI caption — Inter 500, 10px / 12px.
  static final TextStyle uiCaption = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// UI button text — Inter 500, 15px / 20px.
  static final TextStyle uiButton = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.333,
  );

  /// Cultural context text on discovery cards — Inter 400, 14px.
  static final TextStyle contextBody = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.429,
  );
}
