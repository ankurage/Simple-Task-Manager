import 'package:flutter/material.dart';

class TaskCardWidget extends StatelessWidget {
  TaskCardWidget(this.tasks, this.index, this.Changed);

  List tasks;
  int index;
  Function Changed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tasks[index]["name"] ?? "No Name", style: TextStyle(color: tasks[index]["value"] ? Colors.blueGrey : Colors.white),),
      subtitle: tasks[index]["value"] ? Text("Done!", style: TextStyle(color: Colors.green)) : Text("In Progress...", style: TextStyle(color: Colors.yellow)),
      trailing: Checkbox(
        value: tasks[index]["value"],
        onChanged: (value) => Changed(value, index),
      ),
    );
  }
}

class TaskAddWidget extends StatelessWidget {
  TaskAddWidget(this.visible, this._controller, this.taskAdd, this.taskFieldClear, this.taskFieldStateChange);

  bool visible;
  TextEditingController _controller;
  Function taskAdd;
  Function taskFieldClear;
  Function taskFieldStateChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          width: visible ? (MediaQuery.widthOf(context) / 3).toDouble() : 0,
          child: ClipRRect(child: TextField(controller: _controller, onTap: () => _controller.clear(),))
        ),
        Badge(
          backgroundColor: Colors.blueAccent,
          offset: Offset(-20, -5),
          padding: EdgeInsets.symmetric(horizontal: 0),
          isLabelVisible: visible,
          largeSize: 10,
          label: AnimatedContainer(
            duration: Duration(microseconds: 100),
            child: IconButton(icon: Icon(Icons.close), highlightColor: Colors.red, hoverColor: Colors.red, onPressed: () => taskFieldStateChange())
          ),
          child: visible ? FloatingActionButton(child: Icon(Icons.done), onPressed: () => taskAdd(false)) : FloatingActionButton(child: Icon(Icons.add), onPressed: () => taskFieldStateChange())
        ),
      ],
    );
  }
}
