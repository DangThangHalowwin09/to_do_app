import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/widgets/error_widget.dart';
import '../data/firestore.dart';


class Stream_global_note extends StatelessWidget {
  final bool done;
  Stream_global_note(this.done, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore_Datasource().stream_ErrorDone(done),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('22222222❌ Snapshot error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            print('2222222⚠️ Snapshot has no data');
            return CircularProgressIndicator();
          }
          final errorList = Firestore_Datasource().getError(snapshot);


          return ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final error = errorList[index];
              print('2222222 ✅ Number of notes: ${errorList.length}');
              return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    Firestore_Datasource().delete_Error(error.id);
                  },
                  child: Error_Widget(error));
            },
            itemCount: errorList.length,

          );

        });
  }
}
