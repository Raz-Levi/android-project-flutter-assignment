// ================= Welcome Widget =================
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/global/utils.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

class WelcomeWidget extends StatefulWidget {
  final Widget _behindSheetWidget;
  final AuthRepository _authRepository;
  bool _initialized = false;

  WelcomeWidget(this._behindSheetWidget, this._authRepository);

  @override
  _WelcomeWidgetState createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  final SnappingSheetController _snappingController = SnappingSheetController();
  IconData _arrowIcon = gc.expandIcon;
  double _blurCapacity = 0;
  final SnappingPosition _topPosition = const SnappingPosition.pixels(
      positionPixels: gc.positionPixelsBottom,
      snappingCurve: gc.snappingCurve,
      snappingDuration: Duration(milliseconds: gc.snappingDuration));
  final SnappingPosition _bottomPosition = const SnappingPosition.pixels(
      positionPixels: gc.positionPixelsTop,
      snappingCurve: gc.snappingCurve,
      snappingDuration: Duration(milliseconds: gc.snappingDuration));

  void _toggleSnappingSheet() {
    _snappingController.snapToPosition((_snappingController.currentSnappingPosition == _bottomPosition)? _topPosition : _bottomPosition);
  }

  void _updateState() {
    if (_snappingController.currentSnappingPosition == _bottomPosition) {
      // Minimize Sheet
      _arrowIcon = gc.expandIcon;
      _blurCapacity = 0;
    } else {
      // Expand Sheet
      _arrowIcon = gc.minimizeIcon;
      _blurCapacity = gc.blurCapacity;
    }
  }

  void _changeAvatar() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? avatarImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (avatarImage != null) {
      widget._authRepository.uploadAvatar(avatarImage);
    } else {
      displaySnackBar(context, strNO_IMAGE_SELECTED);
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus(); // Remove the keyboard
    return (widget._authRepository.user == null)
        ? Container()
        : SnappingSheet(
            controller: _snappingController,
            lockOverflowDrag: true,
            grabbingHeight: gc.grabbingHeight,
            child: Stack(
              children: [
                widget._behindSheetWidget,
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurCapacity,
                      sigmaY: _blurCapacity,
                    ),
                    child: Container(
                      width: _blurCapacity * 1000,
                      height: _blurCapacity * 1000,
                      color: Colors.grey.withOpacity(0),
                    ),
                  ),
                ),
              ],
            ),
            grabbing: Container(
              color: gc.welcomeColor,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    strWELCOME_BACK.replaceFirst(
                        "%", widget._authRepository.user!.email.toString()),
                  )),
                  InkWell(
                    child: Icon(_arrowIcon),
                    onTap: () {
                      setState(() => {_toggleSnappingSheet()});
                    },
                  ),
                ],
              ),
            ),
            sheetBelow: SnappingSheetContent(
              draggable: true,
              child: Container(
                color: gc.secondaryColor,
                child: Container(
                  margin: const EdgeInsets.all(14.0),
                  child: Wrap(
                    spacing: 14,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: (widget._authRepository.avatarUrl != null)
                            ? NetworkImage(widget._authRepository.avatarUrl!)
                            : null,
                        radius: 32,
                        backgroundColor: Colors.transparent,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget._authRepository.user!.email.toString(),
                            style: const TextStyle(fontSize: 22),
                          ),
                          ElevatedButton(
                            child: const Text(
                              strCHANGE_AVATAR,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            onPressed: () {
                              setState(() => {_changeAvatar()});
                            },
                            style: ElevatedButton.styleFrom(
                              primary: gc.specialButtonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              minimumSize: const Size(10, 25),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            onSheetMoved: (_) {
              setState(() {
                if (widget._initialized) {
                  _blurCapacity = gc.blurCapacity;
                }
                widget._initialized = true;
              });
            },
            onSnapCompleted: (_, __) {
              setState(() {
                _updateState();
              });
            },
            initialSnappingPosition: _bottomPosition,
            snappingPositions: [_bottomPosition, _topPosition],
          );
  }
}
