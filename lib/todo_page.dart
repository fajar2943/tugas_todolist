import 'package:flutter/material.dart';
import 'package:tugas_todolist/database_helper.dart';
import 'package:tugas_todolist/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList> {
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _deskripsiCtrl = TextEditingController();
  TextEditingController _nameEditCtrl = TextEditingController();
  TextEditingController _deskripsiEditCtrl = TextEditingController();
  TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = Todo.dummyData;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todoList = todos;
    });
  }

  void addItem() async {
    // todoList.add(Todo(_nameCtrl.text, _deskripsiCtrl.text));
    await dbHelper.addTodo(Todo(_nameCtrl.text, _deskripsiCtrl.text));
    refreshList();
    _nameCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void updateItem(int index, bool done) async {
    todoList[index].done = done;
    await dbHelper.updateTodo(todoList[index]);
    refreshList();
  }

  void updateData(int index) async {
    todoList[index].nama = _nameEditCtrl.text;
    todoList[index].deskripsi = _deskripsiEditCtrl.text;
    await dbHelper.updateTodo(todoList[index]);
    refreshList();
  }

  void deleteItem(int id) async {
    // todoList.removeAt(index);
    await dbHelper.deleteTodo(id);
    refreshList();
  }

  void deleteAll() async {
    await dbHelper.deleteAllTodo();
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty) {
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos;
    });
  }

  void tampilForm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Tambah Todo"),
              content: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(hintText: "Nama todo"),
                    ),
                    TextField(
                      controller: _deskripsiCtrl,
                      decoration:
                          InputDecoration(hintText: "Deskripsi pekerjaan"),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      addItem();
                      Navigator.pop(context);
                    },
                    child: Text("Tambah")),
              ],
            ));
  }

  void editForm(int index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Edit Todo"),
              content: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _nameEditCtrl,
                      decoration: InputDecoration(hintText: "Nama todo"),
                    ),
                    TextField(
                      controller: _deskripsiEditCtrl,
                      decoration:
                          InputDecoration(hintText: "Deskripsi pekerjaan"),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      updateData(index);
                      Navigator.pop(context);
                    },
                    child: Text("Update")),
              ],
            ));
  }

  void deleteAllForm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Hapus semua todo selesai."),
              content: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                        "Apakah anda yakin untuk menghapus semua todo yang selesai?"),
                  )),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      deleteAll();
                      Navigator.pop(context);
                    },
                    child: Text("Hapus")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aplikasi Todo List"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilForm();
        },
        child: Icon(Icons.add_box),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) {
                cariTodo();
              },
              decoration: InputDecoration(
                  hintText: 'Cari',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: todoList[index].done
                      ? IconButton(
                          icon: Icon(Icons.check_circle),
                          onPressed: () {
                            updateItem(index, !todoList[index].done);
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.radio_button_unchecked),
                          onPressed: () {
                            updateItem(index, !todoList[index].done);
                          },
                        ),
                  title: Text(todoList[index].nama),
                  subtitle: Text(todoList[index].deskripsi),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _nameEditCtrl.text = todoList[index].nama;
                          _deskripsiEditCtrl.text = todoList[index].deskripsi;
                          editForm(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteItem(todoList[index].id ?? 0);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
          height: 110,
          child: Center(
            child: ElevatedButton(
                onPressed: () {
                  deleteAllForm();
                },
                child: Text("Hapus yang selesai")),
          )),
    );
  }
}
