import 'package:flutter/material.dart';
import 'package:my_app/services/cloud/cloud_risk.dart';
import 'package:my_app/utilities/dialogs/delete_dialog.dart';

typedef riskCallback = void Function(Cloudrisk risk);

class risksListView extends StatelessWidget {
  final Iterable<Cloudrisk> risks;
  final riskCallback onDeleterisk;
  final riskCallback onTap;

  const risksListView({
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
            risk.text,
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
