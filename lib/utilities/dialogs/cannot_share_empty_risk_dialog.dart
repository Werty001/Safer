import 'package:flutter/material.dart';
import 'package:my_app/extensions/buildcontext/loc.dart';
import 'package:my_app/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyriskDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_risk_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}

Future<void> showCannotShareEmptyJobDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_risk_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
