import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/provider/provider.dart';

class LabelScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final labels = ref.watch(labelProvider);
    final isLoading = ref.watch(labelProvider.notifier).isLoading;

    Future<void> _fetchInitialData() async {
      if (user != null) {
        await ref.read(labelProvider.notifier).fetchLabels();
      }
    }

    Future<void> _showAddOrEditLabelDialog({Label? label}) async {
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
                        fieldValue = newValue!;
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
                onPressed: () async {
                  if (labelName.isNotEmpty && fieldValue.isNotEmpty) {
                    if (label == null) {
                      EasyLoading.show(status: 'Loading...');
                      try {
                        final result = await ref
                            .read(labelProvider.notifier)
                            .addLabel(labelName, fieldValue);
                        if (result) {
                          EasyLoading.showSuccess('Label added successfully');
                        } else {
                          EasyLoading.showError('Failed to add label');
                        }
                      } catch (error) {
                        EasyLoading.showError('Failed to add label');
                      }
                    } else {
                      EasyLoading.show(status: 'Loading...');
                      try {
                        final result = await ref
                            .read(labelProvider.notifier)
                            .updateLabel(label!, labelName, fieldValue);
                        if (result) {
                          EasyLoading.showSuccess(
                              'Label modified successfully');
                        } else {
                          EasyLoading.showError('Failed to modify label');
                        }
                      } catch (error) {
                        EasyLoading.showError('Failed to modify label');
                      }
                    }
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter label and field value'),
                      ),
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
                onPressed: () async {
                  EasyLoading.show(status: 'Loading...');
                  try {
                    final result = await ref
                        .read(labelProvider.notifier)
                        .deleteLabel(label);
                    if (result) {
                      EasyLoading.showSuccess('Label deleted succesfully');
                    } else {
                      EasyLoading.showError('Failed to delete label');
                    }
                    Navigator.of(context).pop();
                  } catch (error) {
                    EasyLoading.showError('Failed to delete label');
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Labels'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ref.read(userProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('Please log in to see labels'))
          : isLoading
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
                                _showDeleteConfirmationDialog(
                                    labels[index].label);
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
