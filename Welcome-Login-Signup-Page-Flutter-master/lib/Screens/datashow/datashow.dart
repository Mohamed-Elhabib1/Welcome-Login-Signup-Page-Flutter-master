import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A screen that displays and manages data.
class DataDisplay extends StatefulWidget {
  const DataDisplay({super.key});

  @override
    DataDisplayState createState() => DataDisplayState();
  }

  class DataDisplayState extends State<DataDisplay> {
    List<dynamic> data = [];
    List<dynamic> filteredData = [];
    TextEditingController searchController = TextEditingController();

    /// Fetches data from an API.
    Future<void> fetchData() async {
      var response =
          await http.get(Uri.parse('https://nokbaapi.nokba.ly/api/Getlocation'));

      if (response.statusCode == 200) {
        List<dynamic> fetchedData = jsonDecode(response.body);
        setState(() {
          data = fetchedData;
          filteredData = List.from(fetchedData);
        });
      } else {
        debugPrint(response.reasonPhrase);
      }
    }

    /// Filters the data based on the search text.
    void filterData() {
      String searchText = searchController.text.toLowerCase();

      setState(() {
        filteredData = data
            .where((item) => item.values
                .any((v) => v.toString().toLowerCase().contains(searchText)))
            .toList();
      });
    }

    /// Deletes data at the specified index.
    void deleteData(int index) {
      setState(() {
        data.removeAt(index);
        filterData();
      });
    }

    /// Inserts new data.
    void insertData(Map<String, dynamic> newData) {
      setState(() {
        data.add(newData);
        filterData();
      });
    }

    /// Updates data at the specified index.
    void updateData(int index, Map<String, dynamic> newData) {
      setState(() {
        data[index] = newData;
        filterData();
      });
    }

    @override
    void initState() {
      super.initState();
      fetchData();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'ALNOKBA Data Display',
            style: TextStyle(
              color: Color.fromARGB(255, 10, 0, 0),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 228, 180, 239),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                fetchData();
              },
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 137, 43, 142),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  fillColor: Color.fromARGB(255, 249, 249, 249),
                  filled: true,
                ),
                onChanged: (value) => filterData(),
              ),
            ),
            Expanded(
  child: Center(
    child: Container(
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.all(44.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 228, 158, 221), // set the background color
        border: Border.all(color: const Color.fromARGB(255, 10, 0, 0)),
        borderRadius: BorderRadius.circular(55.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 0, 7, 13)), // set the border color to blue
          borderRadius: BorderRadius.circular(33.0),
        ),
        child: ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) => _buildListItem(context, index),
        ),
                ),
    ),
              ),
            ),
          ],
        ),
        //زر الاضافة في اسفل الشاشة
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 179, 184, 237),
          foregroundColor: Colors.white,
          onPressed: () => _showAddDialog(context),
          tooltip: 'Add new data',
          elevation: 4.0,
          child: const Icon(Icons.add, size: 30.0),
        ),
      );
    }

    /// Builds a list item widget for the given index.
    Widget _buildListItem(BuildContext context, int index) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
           color: Color.fromARGB(255, 191, 95, 181), // set the background color البوردر متع الصف
          border: Border.all(color: const Color.fromARGB(255, 10, 0, 0)),
          borderRadius: BorderRadius.circular(33.0),
        ),
        child: Card(
  child: ListTile(
    shape: RoundedRectangleBorder(//تغيير شكل الليست الخلفية منحنية
      borderRadius: BorderRadius.circular(33.0), // adjust the value as needed
    ),
    tileColor: Color.fromARGB(255, 248, 233, 246),
    title: Center(
      child: Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(33.0),
        ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                          text: 'ID: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${filteredData[index]["\$id"]}-   '),
                      const TextSpan(
                          text: 'PKID: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${filteredData[index]['pkid']}-   '),
                      const TextSpan(
                          text: 'Location: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${filteredData[index]['location']}'),
                  ],
                ),
              ),
            ),
          ),
          //location widget delete and edit icon button 
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditDialog(context, index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteData(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a dialog to add new data.
  void _showAddDialog(BuildContext context) {
    TextEditingController idController = TextEditingController();
    TextEditingController pkidController = TextEditingController();
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add new data'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: idController,
                decoration: const InputDecoration(hintText: '\$id'),
              ),
              TextField(
                controller: pkidController,
                decoration: const InputDecoration(hintText: 'pkid'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(hintText: 'location'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                insertData({
                  '\$id': idController.text,
                  'pkid': pkidController.text,
                  'location': locationController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to edit data at the specified index.
  void _showEditDialog(BuildContext context, int index) {
    TextEditingController idController =
        TextEditingController(text: filteredData[index]['\$id']);
    TextEditingController pkidController =
        TextEditingController(text: filteredData[index]['pkid']);
    TextEditingController locationController =
        TextEditingController(text: filteredData[index]['location']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit data'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: idController,
                decoration: const InputDecoration(hintText: '\$id'),
              ),
              TextField(
                controller: pkidController,
                decoration: const InputDecoration(hintText: 'pkid'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(hintText: 'location'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                updateData(index, {
                  '\$id': idController.text,
                  'pkid': pkidController.text,
                  'location': locationController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
