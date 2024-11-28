import 'package:flutter/material.dart';
import 'package:sqlite_databse/services/database_services.dart';

import 'models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  String? _task = null;
  bool check = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(title:  const Text("SQ Task",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),centerTitle: true,backgroundColor: const Color(0xff083654),),
      body: _taskList(),
      floatingActionButton: _addTaskButton(context),
    );
  }

  Widget _addTaskButton(
    BuildContext context,
  ) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                title:  const Text("Add Task",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      onChanged: (value) {
                        setState(() {
                          _task = value;
                        });
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: "message...",hintStyle: TextStyle(color: Colors.grey,fontSize: 12))),
                  const SizedBox(height: 15),
                  MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        if (_task == null || _task == "") return;
                        _databaseService.addTask(_task!);
                        setState(() {
                          _task = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"))
                ])));
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _taskList() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0,bottom: 20.0),
      child: FutureBuilder(
        future: _databaseService.getTasks(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.tealAccent.withOpacity(0.3)),
                  child: ListTile(
                    onLongPress: (){
                      _databaseService.deleteTask(task.id);
                      setState(() {

                      });
                    },
                    title: Text(task.content,style: const TextStyle(fontSize: 15),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                          value: task.status == 1,
                          onChanged: (value){
                            _databaseService.updateTaskStatus(task.id, value == true ? 1: 0);
                            setState(() {
                            });
                          }),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
