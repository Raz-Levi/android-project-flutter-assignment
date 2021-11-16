// ================= Saved Suggestions Screen =================
import 'package:flutter/material.dart';

import 'package:hello_me/global/utils.dart';
import 'package:hello_me/firebase_wrapper/storage_repository.dart';
import 'package:hello_me/global/resources.dart';
import 'package:hello_me/global/constants.dart' as gc; // GlobalConst

class SavedSuggestionsVM extends StatefulWidget {
  final SavedSuggestionsStore _savedSuggestions;
  SavedSuggestionsVM(this._savedSuggestions);

  @override
  _SavedSuggestionsVMState createState() => _SavedSuggestionsVMState();
}

class _SavedSuggestionsVMState extends State<SavedSuggestionsVM> {
  void deletePair(String pair) {
    widget._savedSuggestions.deletePair(pair);
    Navigator.pop(context);
  }

  Widget _buildSavedSuggestions(BuildContext context, String pair) {
    return Dismissible(
      child: ListTile(
        title: Text(
          pair,
          style: gc.biggerFont,
        ),
      ),
      key: ValueKey<String>(pair),
      background: Container(
          color: gc.primaryColor,
          child: Row(
            children: const <Widget>[
              Icon(
                gc.deleteIcon,
                color: gc.secondaryColor,
                size: gc.suggestionsFontSize + gc.iconSizeOffset,
              ),
              Text(
                strDELETE_SUGGESTION,
                style: TextStyle(
                  color: gc.secondaryColor,
                  fontSize: gc.suggestionsFontSize,
                ),
              ),
            ],
          )),
      confirmDismiss: (DismissDirection direction) async {
        var alertButtonStyle = ElevatedButton.styleFrom(
          primary: gc.primaryColor,
        );

        displayAlertDialog(context, strDELETE_SUGGESTION, strDELETE_SUGGESTION_ALERT.replaceFirst("%", pair),
          <Widget>[
            ElevatedButton(
              child: const Text(strYES),
              onPressed: () => setState(() {
                deletePair(pair);
              }),
                style: alertButtonStyle,
            ),
            ElevatedButton(
              child: const Text(strNO),
              onPressed: () => Navigator.pop(context),
                style: alertButtonStyle,
            ),
          ],
        );
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<String>? saved = widget._savedSuggestions.saved;
    if (saved == null) {
      return Container();
    }
    final tiles = saved.map(
          (pair) {
        return _buildSavedSuggestions(context, pair);
      },
    );
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList()
        : <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(strSAVED_SUGGESTIONS),
      ),
      body: ListView(children: divided),
    );
  }
}
