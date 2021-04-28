import 'package:sqlite_app/helper/const.dart';

class UserModel{
  int id;
  String name,phone;
  UserModel({this.id,this.name,this.phone});


  toJson(){
    return{
      columnName:name,
      columnPhone:phone,
    };
  }
  UserModel.fromJson(Map<String,dynamic> map){
    id = map[columnId];
    name = map[columnName];
    phone = map[columnPhone];
  }
}