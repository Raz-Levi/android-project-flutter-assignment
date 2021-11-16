// ================= Sign Up Widget =================
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

class ConfirmPasswordBottomSheet extends StatefulWidget {
  final AuthRepository _authRepository;
  final TextEditingController _userEmail;
  final TextEditingController _originalPassword;
  final AsyncCallback _signUpCallback;

  const ConfirmPasswordBottomSheet(this._authRepository, this._userEmail, this._originalPassword, this._signUpCallback);

  @override
  _ConfirmPasswordBottomSheetState createState() => _ConfirmPasswordBottomSheetState();
}

class _ConfirmPasswordBottomSheetState extends State<ConfirmPasswordBottomSheet> {
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _showErrorPasswordNotMatch = false;

  @override
  void initState() {
    super.initState();
    _confirmPasswordController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _matchPassword() {
    return widget._originalPassword.text.toString() == _confirmPasswordController.text.toString();
  }

  void _confirmPassword() async {
    if (_matchPassword()) {
      await widget._authRepository.signUp(widget._userEmail.text.toString(), widget._originalPassword.text.toString());
      await widget._signUpCallback.call();
      Navigator.pop(context);
    } else {
      _showErrorPasswordNotMatch = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: gc.confirmPasswordSheetSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(0, 17, 0, 0),
              child: const Text(
                strCONFIRM_DESCRIPTION,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(gc.edgeInsets),
              child: Stack(
                children: [
                  Text(
                    strPASSWORD,
                    style: TextStyle(color: gc.labelPasswordColor, height: 0.6),
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      errorText: _showErrorPasswordNotMatch
                          ? strPASSWORD_NOT_MATCH
                          : null,
                    ),
                    onChanged: (_) => {
                      setState(() => {_showErrorPasswordNotMatch = false})
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            widget._authRepository.status == Status.Unauthenticated
                ? ElevatedButton(
                    child: const Text(
                      strCONFIRM,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      setState(() => {_confirmPassword()});
                    },
                    style: ElevatedButton.styleFrom(
                      primary: gc.specialButtonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      minimumSize: const Size(10, 40),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      ),
    );
  }
}

class SignUpWidget extends StatefulWidget {
  final AuthRepository _authRepository;
  final TextEditingController _userEmail;
  final TextEditingController _originalPassword;
  final AsyncCallback _signUpCallback;

  SignUpWidget(this._authRepository, this._userEmail, this._originalPassword, this._signUpCallback);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  void _openConfirmPasswordSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => ConfirmPasswordBottomSheet(
            widget._authRepository,
            widget._userEmail,
            widget._originalPassword,
            widget._signUpCallback));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text(strSIGN_UP),
      onPressed: () {
        _openConfirmPasswordSheet();
      },
      style: ElevatedButton.styleFrom(
        primary: gc.specialButtonColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(gc.circularButton)),
        padding: const EdgeInsets.symmetric(horizontal: 95, vertical: 12),
      ),
    );
  }
}
