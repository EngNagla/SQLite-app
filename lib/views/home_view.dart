
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_app/helper/database_helper.dart';
import 'package:sqlite_app/model/user_model.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List <UserModel> usersList = [];
  String name , phone;
  bool flag=false;
  GlobalKey<FormState> _key=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts",textAlign:TextAlign.center,style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.blueGrey,),
      body: getAllUser(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          return createListView(context, snapshot);
        });
  }

  Future<List<UserModel>> _getData() async {
    var dbHelper = DatabaseHelper.db;
    await dbHelper.getAllUsers().then((value) {
      print(value);
      usersList = value;
    });
    return usersList;
  }

  createListView(BuildContext context, AsyncSnapshot snapshot) {
    usersList = snapshot.data;
    if (usersList != null) {
      return ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color:Colors.deepPurpleAccent,
                ),
                onDismissed: (direction){
                  DatabaseHelper.db.deleteUser(usersList[index].id);
                },
                child:  _buildItem(usersList[index], index));
          });
    } else {
      return Container();
    }
  }

  _buildFloatingActionButton() {
     return FloatingActionButton(onPressed: ()=> openAlertBox(null),
        backgroundColor: Colors.blueGrey,
         child: Icon (Icons.add),
     );
  }

  openAlertBox(UserModel model) {
    if(model != null){
      name=model.name;
      phone=model.phone;
      flag=true;
    }else{
      name='';
      phone='';
      flag=false;
    }
    showDialog(context: context ,builder:  (context){
      return AlertDialog(
        content: Container(width: 100,
         height: 150,
         child: Form(
           key: _key,
           child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  hintText: 'Add Name',
                  fillColor: Colors.grey[300],
                  border:InputBorder.none,
                ),
                validator: (value){
                  return null;
                } ,
                onSaved: (String value){
                  name = value;
                },
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(
                  hintText: 'Add Phone',
                  fillColor: Colors.grey[300],
                  border:InputBorder.none,
                ),
                validator: (value){
                  return null;
                } ,
                onSaved: (String value){
                  phone = value;
                },
              ),
              FlatButton(
                onPressed: (){
                flag ? editUser(model.id) : addUser();
              },
               child: Text(flag ? "Edit User" : "Add User"),
              )
            ],
        ),
         ),
        ),
      );
    });
  }

  addUser() async{
    _key.currentState.save();
    var dbHelper = DatabaseHelper.db;
    dbHelper.insertUser(UserModel(name : name, phone: phone)).then((value){
      Navigator.pop(context);
      setState(() {

      });
    });
  }
  editUser(int id) async{
    _key.currentState.save();
    var dbHelper = DatabaseHelper.db;
    UserModel user = UserModel(
      id:id,
      name:name,
      phone: phone,);
    dbHelper.updateUser(user).then((value){
      Navigator.pop(context);
      setState(() {
        flag=false;
       });
    });
  }

  _buildItem(UserModel model, int index) {
    return Card(
      child: ListTile(
        title:Row(
          children: [
            Column(
              children: [
                Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 30,
                    child: Text(model.name.substring(0,1).toLowerCase(),
                      style: TextStyle(fontSize: 30,
                      color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(width: 30,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle),
                    Padding(padding: EdgeInsets.only(right: 10),),
                    Text(
                      model.name,
                      style: TextStyle(fontSize: 20,color:Colors.black,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Icon(Icons.phone),
                    Padding(padding: EdgeInsets.only(right: 10),),
                    Text(
                      model.phone,
                      style: TextStyle(fontSize: 20,color:Colors.black,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: ()=>_onEdit(model,index),
            icon: Icon(Icons.edit),
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  _onEdit(UserModel model, int index) {
    openAlertBox(model);
  }
}
