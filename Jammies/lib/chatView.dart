import 'package:Jammies/profileJamView.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'globals.dart';

class chatView extends StatefulWidget {
    @override
    _ChatView createState() => _ChatView();
}

class _ChatView extends State<chatView>{
    Future<List<String>> futureNames;

    List<String> names;


    @override
    void initState() {
        // TODO: implement initState
        super.initState();

        futureNames = _getMatches();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Chat"),
                actions: <Widget>[
                    IconButton(
                        icon: globals.profilePhoto == null
                            ? FadeInImage(
                                image: NetworkImage(globals.server + '/static/images/' + globals.id), placeholder: AssetImage("assets/icon/icon.png")
                            )
                            : Image.file(globals.profilePhoto),
                        iconSize: 50,
                        onPressed: () {
                            Navigator.pushNamed(context, '/myProfileView');
                        },
                    ),
                ],
            ),
            body: Center(
                child: FutureBuilder<List<String>>(
                    future: futureNames,
                    builder: (context, snapshot) {
                        if (snapshot.hasData) {
                            names = snapshot.data;
                            return ListView.separated(
                                itemCount: names.length,
                                itemBuilder: (context, index) {
                                    return ListTile(
                                        title: Text(names[index]),
                                    );
                                },
                                separatorBuilder: (context, index) {
                                    return Divider();
                                },
                            );
                        }
                        return Center(child: CircularProgressIndicator());
                    }
                )
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        icon: Icon(
                            Icons.mail_outline,
                            color: Colors.purpleAccent,
                        ),
                        title: Text(
                            'Chat',
                            style: TextStyle(color: Colors.purpleAccent),
                        ),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(
                            Icons.music_note,
                            color: Colors.indigo,
                        ),
                        title: Text(
                            'Jam',
                            style: TextStyle(color: Colors.indigo),
                        ),
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(
                            Icons.map,
                            color: Colors.indigo,
                        ),
                        title: Text(
                            'Discover',
                            style: TextStyle(color: Colors.indigo),
                        ),
                    ),
                ],
                onTap: _onItemTapped,
            ),
        );
    }

    void _onItemTapped(int index) {
        if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/chat', (_) => false);
        } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(context, '/jam', (_) => false);
        } else if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/discover', (_) => false);
        }
    }

    Future<List<String>> _getMatches() async {
        final prefs = await SharedPreferences.getInstance();
        String email = prefs.getString('email');
        String password = prefs.getString('password');
        List<String> matchedNames = new List<String>();

        Map<String, String> header = {'email': email, 'password': password};
        print(header);
        final response = await http.get(globals.server + '/getMatches', headers: header,);

        var idList = (jsonDecode(response.body) as List);

        for (int i = 0; i < idList.length; i++) {
            Map<String, String> header = {
                'email': email,
                'password': password,
                'userid': idList[i].toString()
            };
            var response = await http.get(globals.server + '/getProfile', headers: header);

            Map<String, dynamic> jsonResponse = jsonDecode(response.body);
            matchedNames.add(jsonResponse['name']);
        }
        print(matchedNames);
        return matchedNames;

    }

}
