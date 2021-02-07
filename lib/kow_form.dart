library kow_form;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A wrapper for all of [KowForm]'s functionality.
class KowForm extends StatelessWidget {
  /// Defines if [KowForm] should start with any initial data. Useful for editing existing data.
  final Map<String, dynamic> initialData;

  /// Defines what will be fired through the [KowSubmitButton] onSubmit builder argument.
  final void Function(Map<String, dynamic> formData) onSubmit;

  /// What will be rendered below the [KowForm] wrapper.
  final Widget child;

  const KowForm({
    Key key,
    this.initialData = const <String, dynamic>{},
    @required this.onSubmit,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (context) => _KowFormState(
        formData: initialData,
        onSubmit: onSubmit,
      ),
      builder: (context, _) => child,
    );
  }
}

/// Stores the form data, on submit methods and set/get functions of [KowForm].
class _KowFormState extends ChangeNotifier {
  /// The initial data passed through [KowForm].
  final Map<String, dynamic> _formData;

  /// The onSubmit callback passed through [KowForm].
  final void Function(Map<String, dynamic> formData) onSubmit;

  _KowFormState({
    @required Map<String, dynamic> formData,
    @required this.onSubmit,
  }) : this._formData = _Flattener.flatten(formData);

  /// Sets a value inside the current form data.
  void setValue({
    @required String key,
    @required dynamic value,
  }) {
    this._formData[key] = value;
    notifyListeners();
  }

  /// Gets a value of the current form data.
  dynamic getValue(String key) {
    return this._formData[key];
  }

  /// Parses the flattened form data map to its unflattened version.
  Map<String, dynamic> get formData => _Flattener.unflatten(_formData);
}

/// An input that can be used to manipulate any key inside [KowForm]'s form data.
class KowInput extends StatefulWidget {
  /// Path to the key related to this input's value.
  final String path;

  /// This builder function takes [context], [onChanged] and [initialValue] as its arguments.
  ///
  /// [onChanged] can be called anytime to set the value related to this input's path inside the form data.
  ///
  /// [initialValue] can be used to set your widget's initial value.
  final Widget Function(
    BuildContext context,
    void Function(dynamic value) onChanged,
    dynamic initialValue,
  ) builder;

  const KowInput({
    Key key,
    @required this.path,
    @required this.builder,
  }) : super(key: key);

  @override
  _KowInputState createState() => _KowInputState();
}

class _KowInputState extends State<KowInput> {
  @override
  Widget build(BuildContext context) {
    var formState = Provider.of<_KowFormState>(context, listen: false);
    var onChanged = (dynamic value) {
      formState.setValue(
        key: widget.path,
        value: value,
      );
    };
    var initialValue = formState.getValue(widget.path);

    return widget.builder(
      context,
      onChanged,
      initialValue,
    );
  }
}

/// A widget that can be used to access the onSubmit callback of [KowForm].
class KowSubmitButton extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    void Function() onSubmit,
  ) builder;

  const KowSubmitButton({
    Key key,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formState = Provider.of<_KowFormState>(context, listen: false);
    var onSubmit = () {
      formState.onSubmit(formState.formData);
    };

    return builder(context, onSubmit);
  }
}

abstract class _Flattener {
  static Map<String, dynamic> flatten(Map<String, dynamic> target,
      [String prefix = '']) {
    if (target.isEmpty) return {};

    final Map<String, dynamic> result = {};

    target.forEach((key, value) {
      if (value is List) {
        final Map<String, dynamic> tmp = {};

        value.asMap().forEach((index, value) {
          tmp['$key.$index'] = value;
        });

        result.addAll(flatten(tmp, prefix));
      } else if (value is Map) {
        dynamic newPrefix = '';
        newPrefix = '$prefix$key$newPrefix.';

        result.addAll(flatten(value, newPrefix));
      } else {
        result['$prefix$key'] = value;
      }
    });

    return result;
  }

  static Map<String, dynamic> unflatten(Map<String, dynamic> target) {
    if (target.isEmpty) return {};

    dynamic result = {};
    dynamic cur, prop, idx, last, temp;

    target.forEach((key, value) {
      cur = result;
      prop = '';
      last = 0;
      do {
        idx = key.indexOf('.', last);
        temp = key.substring(last, idx != -1 ? idx : null);
        if (cur is List) {
          if (cur.length <= int.parse(prop)) {
            cur.add(null);
          }
          cur = cur[int.parse(prop)] ??
              (cur[int.parse(prop)] = (int.tryParse(temp) != null ? [] : {}));
        } else {
          cur =
              cur[prop] ?? (cur[prop] = (int.tryParse(temp) != null ? [] : {}));
        }
        prop = temp;
        last = idx + 1;
      } while (idx >= 0);
      if (cur is List) {
        if (cur.length <= int.parse(prop)) {
          cur.add(null);
        }
        cur[int.parse(prop)] = value;
      } else {
        cur[prop] = value;
      }
    });

    return Map<String, dynamic>.from(result['']);
  }
}
