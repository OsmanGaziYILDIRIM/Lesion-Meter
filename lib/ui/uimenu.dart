import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class MenuPage extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const MenuPage({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  TextEditingController _textEditingController = TextEditingController();
  Map<int, String> suggestionMap = {
    115552: 'armut',
    2225: 'xalma',
    444: 'xacuka',
    12100: 'bxıcırık',
    1512: 'xbamya',
    2252: 'xcuce',
    1155523: 'armuxt',
    22255: 'alaxma',
    44443: 'acuxka',
    121003: 'bıcıxrık',
    15122: 'baxmya',
    22521: 'cuxce',
  };
  List<String> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(filterSuggestions);
  }

  void filterSuggestions() {
    String filterText = _textEditingController.text.toLowerCase();
    setState(() {
      filteredSuggestions = suggestionMap.entries
          .where((entry) =>
      entry.key.toString().startsWith(filterText) ||
          entry.value.toLowerCase().startsWith(filterText))
          .map((entry) => '${entry.key} (${entry.value})')
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Lesion Meter',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type the id of the patient.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _textEditingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sayısal değer girin',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
              style: TextStyle(
                color: Colors.indigo,
              ),
              onChanged: (value) {
                filterSuggestions();
              },
              onSubmitted: (value) {
                widget.onSubmit(_textEditingController.text);
              },
            ),
            SizedBox(height: 10),
            Text('Öneriler:'),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: filteredSuggestions.length > 6 ? 6 : filteredSuggestions.length,
                  physics: BouncingScrollPhysics(), // veya ClampingScrollPhysics()
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(filteredSuggestions[index]),
                        onTap: () {
                          _textEditingController.text = filteredSuggestions[index].split(' ')[0];
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onSubmit("");
        },
        label: Text(
          'Continue as a guest.',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
