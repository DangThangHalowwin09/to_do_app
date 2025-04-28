import 'package:cloud_firestore/cloud_firestore.dart';

class Error {
  String id;
  String errorTitle;
  String clarifyTitle;
  String name;
  String address;
  Timestamp timeErrorStart;
  List<int>  idStaff;
  bool isTakeOver;
  Timestamp timeTakeOver;
  bool isDone;
  Timestamp timeDone;
  String note;

  Error(this.id, this.errorTitle, this.clarifyTitle,
      this.name, this.address, this.timeErrorStart, this.idStaff,
      this.isTakeOver, this.timeTakeOver, this.isDone, this.timeDone, this.note);
}