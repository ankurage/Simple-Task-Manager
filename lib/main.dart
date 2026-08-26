import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'widgets/widgets.dart';

class BoxProvider with ChangeNotifier {
  late Future<List<dynamic>> taskList;

  Future<List<dynamic>> GetTasks() async {
    var tasks = await Hive.openBox("tasks");
    return tasks.values.toList();
  }

  void UpdateTask() {
    taskList = GetTasks();
    notifyListeners();
  }

  void ChangeTask(name, index, value) async {
    var box = await Hive.openBox("tasks");
    var newDate = {
      "name": name,
      "value": value,
      "delete": true
    };
    box.putAt(index, newDate);
    taskList = GetTasks();
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var box = await Hive.openBox("tasks");
  var tasks = box.values.toList();
  for (var i = 0; i < tasks.length; i++) {
    if (tasks[i]["delete"] == true) {
      box.delete(i);
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => BoxProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Title",
      home: MainScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BoxProvider>().taskList = context.read<BoxProvider>().GetTasks();
  }

  void Changed(value, index) async {
    var box = await Hive.openBox("tasks");
    var tasks = await context.read<BoxProvider>().taskList;

    context.read<BoxProvider>().ChangeTask(tasks[index]["name"], index, value);

    setState(() {
      tasks[index]["value"] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<BoxProvider>(
            builder: (context, provider, child) {
              return FutureBuilder(
                future: provider.taskList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("${snapshot.error}"),);
                  }
                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return const Center(child: Text("Task list is empty"),);
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCardWidget(tasks, index, Changed);
                    },
                  );
                },
              );
            },
          ),
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: NavigationWidget(),
          ),
        ],
      ),
    );
  }
}

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  bool visible = false;
  TextEditingController _controller = TextEditingController();
  var buttonIcon = Icons.add;
  var borderColor = Colors.white70;

  void taskFieldClear() {
    setState(() {
      _controller.text = "";
    });
    
  }

  void taskFieldStateChange() {
    taskFieldClear();
    setState(() {
      visible = !visible;
    });
  }

  void taskAdd(bool closing) async {
    if (_controller.text.length >= 3) {
      var db = await Hive.openBox("tasks");

      await db.add({
        "name": _controller.text,
        "value": false,
        "delete": false
      });

      context.read<BoxProvider>().UpdateTask();
      setState(() {
        borderColor = Colors.white70;
      });
      taskFieldStateChange();
      taskFieldClear();
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("The Task Name Is Too Short", textAlign: TextAlign.center,),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20)
          ),
          margin: EdgeInsets.symmetric(horizontal: 550, vertical: 10),
        )
      );
      setState(() {
        borderColor = Colors.red;
        _controller.text = "The Task Name Is Too Short";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.widthOf(context) / 5,
      // height: 300,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blueAccent.withAlpha(20),
        border: BoxBorder.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TaskAddWidget(visible, _controller, taskAdd, taskFieldClear, taskFieldStateChange),
          ),
        ],
      ),
    );
  }
}
