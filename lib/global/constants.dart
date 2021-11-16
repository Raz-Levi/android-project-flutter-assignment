// ================= Constants =================
import 'package:flutter/material.dart';

// Firebase
const String savedSuggestionsCollection = "saved_suggestions";
const String savedSuggestionsCollectionField = "Pair";
const String avatarsCollection = "avatars";
const String storageBucketPath = "gs://hellome-1a08e.appspot.com";

// Colors
const Color primaryColor = Colors.deepPurple;
const Color secondaryColor = Colors.white;
const Color specialButtonColor = Colors.blue;
Color welcomeColor = Colors.grey.shade300;
Color labelPasswordColor = Colors.black54;

// Size
const double suggestionsFontSize = 18;
const double iconSizeOffset = 8;
const double suggestionsPadding = 16;
const int generateMoreWords = 10;
const double edgeInsets = 16.0;
const TextStyle biggerFont = TextStyle(fontSize: suggestionsFontSize);
const double circularButton = 50;
const double grabbingHeight = 47;
const double confirmPasswordSheetSize = 250;

// Icons
const IconData favoriteIcon = Icons.star;
const IconData favoriteIconBorder = Icons.star_border;
const IconData unauthenticatedIcon = Icons.login;
const IconData authenticatedIcon = Icons.exit_to_app;
const IconData deleteIcon = Icons.delete;
const IconData expandIcon = Icons.expand_less;
const IconData minimizeIcon = Icons.expand_more;

// Snapping Sheet
const int snappingDuration = 100;
const double blurCapacity = 3.5;
const Curve snappingCurve = Curves.linear;
const double positionPixelsTop = 25;
const double positionPixelsBottom = 130;
