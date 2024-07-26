import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/services/api_service.dart';

class LabelScreen extends StatefulWidget {
  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  List<Label> labels = [];
  final ApiService _apiService = ApiService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLabels();
  }

  void showStatusDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchLabels() async {
    try {
      List<Label> fetchedLabels = await _apiService.getLabels();
      setState(() {
        labels = fetchedLabels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showStatusDialog(context, 'Failed to load labels', false);
    }
  }

  Future<void> addLabel(String label, String fieldValue) async {
    setState(() {
      isLoading = true;
    });
    try {
      bool success = await _apiService.addLabel(label, fieldValue);
      if (success) {
        showAnimatedDialog(context, 'Label added successfully', true);
        fetchLabels();
      } else {
        setState(() {
          isLoading = false;
        });
        showAnimatedDialog(context, 'Failed to add label', false);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showAnimatedDialog(context, 'Error adding label', false);
    }
  }

  Future<void> updateLabel(
      Label label, String newLabel, String newFieldValue) async {
    setState(() {
      isLoading = true;
    });
    try {
      bool success =
          await _apiService.updateLabel(label.label, newLabel, newFieldValue);
      if (success) {
        showAnimatedDialog(context, 'Label updated successfully', true);
        fetchLabels();
      } else {
        setState(() {
          isLoading = false;
        });
        showAnimatedDialog(context, 'Failed to update label', false);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showAnimatedDialog(context, 'Error updating label', false);
    }
  }

  Future<void> deleteLabel(String label) async {
    setState(() {
      isLoading = true;
    });
    try {
      bool success = await _apiService.deleteLabel(label);
      if (success) {
        showAnimatedDialog(context, 'Label deleted successfully', true);
        fetchLabels();
      } else {
        setState(() {
          isLoading = false;
        });
        showAnimatedDialog(context, 'Failed to delete label', false);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showAnimatedDialog(context, 'Error deleting label', false);
    }
  }

  void showAnimatedDialog(
      BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddOrEditLabelDialog({Label? label}) {
    String labelName = label?.label ?? '';
    String fieldValue = label?.field ?? 'fundamentals';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Center(child: Text(label == null ? 'Add Label' : 'Edit Label')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: (value) {
                  labelName = value;
                },
                controller: TextEditingController(text: labelName),
              ),
              SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Field Value',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: fieldValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        fieldValue = newValue!;
                      });
                    },
                    items: <String>['fundamentals', 'fun', 'future you']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelName.isNotEmpty && fieldValue.isNotEmpty) {
                  if (label == null) {
                    addLabel(labelName, fieldValue);
                  } else {
                    updateLabel(label, labelName, fieldValue);
                  }
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Please enter label and field value',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: Text(label == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Label'),
          content: Text('Are you sure you want to delete this label?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteLabel(label);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labels'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Resetta tutti i provider e distruggi lo stato esistente
              // Aggiorna lo stato di autenticazione

              // Logout dell'utente e reindirizzamento alla schermata di login
              bool success = await ApiService().logoutUser();
              if (success) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logout fallito.')));
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: labels.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(labels[index].label),
                    subtitle: Text(labels[index].field),
                    trailing: Wrap(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showAddOrEditLabelDialog(label: labels[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(labels[index].label);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditLabelDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
