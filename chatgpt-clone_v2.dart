import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     /// backgroundGradient: LinearGradient(
        ///begin: Alignment.topCenter,
        ///end: Alignment.bottomCenter,
        ///colors: [Colors.pink[200], Colors.orange[300]],
     /// ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Mon assistant virtuel',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 20,
        ),
        ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _completions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(_completions[index]);
                  },
                ),
              ),
             Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Quel est votre question ?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      hintText: 'Entrez un modèle (facultatif): text-davinci-003',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: _keyController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre clé API',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Entrez votre question'),
                onPressed: () {
                  _getCompletion(_promptController.text, _modelController.text, _keyController.text);
                },
                ///shape: RoundedRectangleBorder(
                  ///borderRadius: BorderRadius.circular(10),
                  ///side: BorderSide(
                    ///color: Colors.pink[200],
                  ///),
                ///),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _completions = [];

  void _getCompletion(String prompt, String model, String key) {
    _completions.add(prompt);
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _promptController.clear();
    setState(() {});

    _fetchCompletion(prompt, model, key).then((response) {
      setState(() {
        _completions.add(response);
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  Future<String> _fetchCompletion(String prompt, String model, String key) async {
    String apiKey = key;
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'model': model.isEmpty ? 'text-davinci-003' : model,
        "temperature": 0.9,
        "max_tokens": 150,
        "top_p": 1,
        "frequency_penalty": 0.6,
        "presence_penalty": 0
      }),
    );

    final responseJson = json.decode(utf8.decode(response.bodyBytes));
    return responseJson['choices'][0]['text'];
  }
}
