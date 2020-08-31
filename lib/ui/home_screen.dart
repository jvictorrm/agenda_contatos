import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum SortOptions { SORTAZ, SORTZA }

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ContactHelper contactHelper = ContactHelper();

  List<Contact> _contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          PopupMenuButton<SortOptions>(
            itemBuilder: (context) => <PopupMenuEntry<SortOptions>>[
              const PopupMenuItem<SortOptions>(
                child: Text("Ordenar de A a Z"),
                value: SortOptions.SORTAZ,
              ),
              const PopupMenuItem<SortOptions>(
                child: Text("Ordenar de Z a A"),
                value: SortOptions.SORTZA,
              ),
            ],
            onSelected: _sortContacts,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            return _buildContactCard(context, index);
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
          ),
          backgroundColor: Colors.deepOrangeAccent,
          onPressed: () {
            _showContactScreen();
          }),
    );
  }

  Widget _buildContactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _contacts[index].img != null
                              ? FileImage(File(_contacts[index].img))
                              : AssetImage("images/person.png"))),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _contacts[index].name ?? "", // AQUI
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      Text(
                        _contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(_contacts[index].phone ?? "",
                          style: TextStyle(fontSize: 18.0)), // AQUI
                    ],
                  ),
                )
              ],
            )),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text(
                              "Ligar",
                              style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 20.0),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              launch("tel:${_contacts[index].phone}");
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text(
                              "Editar",
                              style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 20.0),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactScreen(contact: _contacts[index]);
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text(
                              "Excluir",
                              style: TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontSize: 20.0),
                            ),
                            onPressed: () {
                              contactHelper.deleteContact(_contacts[index].id);
                              setState(() {
                                _contacts.removeAt(index);
                                Navigator.pop(context);
                              });
                            }),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactScreen({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactScreen(
                  contact: contact,
                )));

    if (recContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }

      _getAllContacts();
    }
  }

  void _getAllContacts() {
    contactHelper.getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  void _sortContacts(SortOptions selectedSort) {
    switch (selectedSort) {
      case SortOptions.SORTAZ:
        _contacts.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case SortOptions.SORTZA:
        _contacts.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    setState(() {});
  }
}
