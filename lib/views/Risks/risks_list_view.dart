import 'package:flutter/material.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/utilities/dialogs/delete_dialog.dart';

typedef RiskCallback = void Function(Cloudrisk risk);

class RisksListView extends StatelessWidget {
  final Iterable<Cloudrisk> risks;
  final RiskCallback onDeleterisk;
  final RiskCallback onTap;

  const RisksListView({
    Key? key,
    required this.risks,
    required this.onDeleterisk,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: risks.length,
      itemBuilder: (context, index) {
        final risk = risks.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(risk);
          },
          title: Text(
            risk.type + ' -> ' + risk.subtype,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleterisk(risk);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
