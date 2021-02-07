import 'package:flutter/material.dart';
import 'package:kow_form/kow_form.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KowFormExample',
      home: FormPage(),
    );
  }
}

class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: KowForm(
          initialData: {
            'name': 'KowForm',
          },
          onSubmit: print,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KowInput(
                path: 'name',
                builder: (context, onChanged, initialValue) => TextField(
                  onChanged: onChanged,
                  controller: TextEditingController(text: initialValue),
                ),
              ),
              KowSubmitButton(
                builder: (context, onSubmit) => RaisedButton(
                  color: Colors.blue,
                  onPressed: onSubmit,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
