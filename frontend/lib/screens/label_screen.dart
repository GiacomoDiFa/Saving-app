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
      TextEditingController labelController =
          TextEditingController(text: labelName);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Center(
                    child: Text(label == null ? 'Add Label' : 'Edit Label')),
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
                      controller: labelController,
                      onChanged: (value) {
                        labelName = value;
                      },
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
                    onPressed: () async {
                      if (labelName.isNotEmpty && fieldValue.isNotEmpty) {
                        EasyLoading.show(status: 'Loading...');
                        try {
                          bool result;
                          if (label == null) {
                            result = await ref
                                .read(labelProvider.notifier)
                                .addLabel(labelName, fieldValue);
                          } else {
                            result = await ref
                                .read(labelProvider.notifier)
                                .updateLabel(label!, labelName, fieldValue);
                          }
                          await ref
                              .watch(statisticalProvider.notifier)
                              .fetchStatistical(
                                  ref.watch(selectedMonthProvider),
                                  ref.watch(selectedYearProvider));
                          await ref
                              .watch(labelexpencesProvider.notifier)
                              .fetchLabelExpences(
                                  ref.watch(selectedMonthProvider),
                                  ref.watch(selectedYearProvider));
                          if (result) {
                            EasyLoading.showSuccess(label == null
                                ? 'Label added successfully'
                                : 'Label modified successfully');
                          } else {
                            EasyLoading.showError(label == null
                                ? 'Failed to add label'
                                : 'Failed to modify label');
                          }
                        } catch (error) {
                          EasyLoading.showError(label == null
                              ? 'Failed to add label'
                              : 'Failed to modify label');
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
                    await ref
                        .watch(statisticalProvider.notifier)
                        .fetchStatistical(ref.watch(selectedMonthProvider),
                            ref.watch(selectedYearProvider));
                    await ref
                        .watch(labelexpencesProvider.notifier)
                        .fetchLabelExpences(ref.watch(selectedMonthProvider),
                            ref.watch(selectedYearProvider));
                    if (result) {
                      EasyLoading.showSuccess('Label deleted successfully');
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

    // Sort labels to have "Other" first
    final sortedLabels = [...labels];
    sortedLabels.sort((a, b) {
      if (a.label == "Other") return -1;
      if (b.label == "Other") return 1;
      return 0;
    });

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
                  itemCount: sortedLabels.length,
                  itemBuilder: (context, index) {
                    final label = sortedLabels[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(label.label),
                        subtitle: Text(label.field),
                        trailing: label.label == "Other"
                            ? null
                            : Wrap(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showAddOrEditLabelDialog(label: label);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          label.label);
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
