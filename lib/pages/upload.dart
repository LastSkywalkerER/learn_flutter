import 'package:flutter/material.dart';
import 'package:learn_flutter/web3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web3dart/web3dart.dart';

class Upload extends StatefulWidget {
  const Upload({super.key, required this.user, required this.wallet});

  final User user;
  final Wallet wallet;

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String _inputValue = "";
  List items = [];
  double balance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    print("Address: ${widget.wallet.privateKey.address}");

    Web3.getEthBalance(widget.wallet.privateKey)
        .then((value) => {
              setState(() {
                balance = value;
              })
            })
        .whenComplete(() => Web3.getTodos(widget.wallet.privateKey)
            .then((value) => {
                  setState(() {
                    items.addAll(value);
                    print("Items: ${items.length} - ${items.toString()}");
                  })
                })
            .whenComplete(() => setState(() {
                  isLoading = false;
                })));
  }

  void _handleMenu() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Menu"),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                child: Text('Logout')),
            Padding(padding: EdgeInsets.only(left: 15)),
          ],
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO list"),
        centerTitle: true,
        actions: [IconButton(onPressed: _handleMenu, icon: Icon(Icons.menu))],
      ),
      body: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              ],
            )
          : Container(
              child: Column(
                children: [
                  Text(
                      "Address: ${widget.wallet.privateKey.address.toString()}"),
                  Text("Balance: ${balance.toString()} ETH"),
                  items.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                var item = items[index];

                                return Dismissible(
                                  key: Key(item),
                                  child:
                                      Card(child: ListTile(title: Text(item))),
                                  onDismissed: (direction) async {
                                    Web3.removeTodo(
                                        index, widget.wallet.privateKey);

                                    setState(() {
                                      items[index] = items.last;
                                      items.removeAt(items.length - 1);
                                    });
                                  },
                                );
                              }),
                        )
                      : Text("Empty todos")
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Add item"),
                  content: TextField(
                    onChanged: (String value) {
                      _inputValue = value;
                    },
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          Web3.addTodo(_inputValue, widget.wallet.privateKey);

                          setState(() {
                            items.add(_inputValue);
                            isLoading = false;
                          });
                          _inputValue = "";
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"))
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
