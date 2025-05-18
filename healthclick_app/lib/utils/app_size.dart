import 'package:flutter/material.dart';

// Classe utilitária para gerenciar dimensões responsivas
class AppSize {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;

  static bool _initialized = false;

  static void init(BuildContext context) {
    if (_initialized) return; // Prevent multiple initializations

    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    textScaleFactor = _mediaQueryData.textScaleFactor;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    _initialized = true;
  }

  // Verify initialization status
  static bool get isInitialized => _initialized;

  // For elements that should be proportional to screen size
  static double hp(double percentage) {
    if (!_initialized) {
      print('WARNING: AppSize not initialized, using default values');
      return percentage * 5; // Default fallback value
    }
    return blockSizeVertical * percentage;
  }

  static double wp(double percentage) {
    if (!_initialized) {
      print('WARNING: AppSize not initialized, using default values');
      return percentage * 3; // Default fallback value
    }
    return blockSizeHorizontal * percentage;
  }

  // For responsive text
  static double sp(double size) {
    if (!_initialized) {
      print('WARNING: AppSize not initialized, using default values');
      return size; // Default fallback value
    }
    return size * textScaleFactor;
  }
}
