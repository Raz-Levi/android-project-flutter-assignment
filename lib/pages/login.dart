// ================= Login Screen =================
import 'package:flutter/material.dart';

import 'package:hello_me/widgets/sign_up_button.dart';
import 'package:hello_me/firebase_wrapper/auth_repository.dart';
import 'package:hello_me/firebase_wrapper/storage_repository.dart';
import 'package:hello_me/global/utils.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

class LoginVM extends StatefulWidget {
  final AuthRepository _authRepository;
  final SavedSuggestionsStore _savedSuggestions;

  LoginVM(this._authRepository, this._savedSuggestions);

  @override
  _LoginVMState createState() => _LoginVMState();
}

class _LoginVMState extends State<LoginVM> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> pullUserStorage() async {
    await widget._savedSuggestions.pullSaved();
    await widget._savedSuggestions.pushSaved();
    Navigator.pop(context);
  }

  void _loginApp() async {
    if (await widget._authRepository.signIn(_emailController.text.toString(), _passwordController.text.toString())) {
      // successful login
      pullUserStorage();
    } else {
      // unsuccessful login
      setState(() {
        displaySnackBar(context, strLOGIN_ERROR);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(strLOGIN),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(children: <Widget>[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(gc.edgeInsets),
              child: Text(strLOGIN_BODY),
            ),
            Padding(
              padding: const EdgeInsets.all(gc.edgeInsets),
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: strEMAIL,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(gc.edgeInsets),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: strPASSWORD),
              ),
            ),
            widget._authRepository.status == Status.Unauthenticated
                ? ElevatedButton(
                    child: const Text(strLOG_IN),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // Remove the keyboard
                      setState(() => {_loginApp()});
                    },
                    style: ElevatedButton.styleFrom(
                      primary: gc.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(gc.circularButton)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 155, vertical: 12),
                    ),
                  )
            : const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 5),
            SignUpWidget(widget._authRepository, _emailController, _passwordController, pullUserStorage),
          ])),
    );
  }
}
