import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_info/providers/entries_provider.dart';
import 'package:provider/provider.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  EntriesController? entriesProvider;

  @override
  void initState() {
    entriesProvider = Provider.of<EntriesController>(context, listen: false);
    entriesProvider?.fetchEntries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle entry history"),
      ),
      body: Center(
        child: Consumer<EntriesController>(
          builder: (context, entriesController, child) {
            return ListView.builder(
              itemCount: entriesController.entries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    DateFormat.yMd().add_Hms().format(
                          entriesController.entries[index].entryTimestamp,
                        ),
                    style: const TextStyle(fontSize: 18),
                  ),
                  leading: const Icon(Icons.local_parking),
                  iconColor: entriesController.entries[index].paid
                      ? entriesController.entries[index].exitTimestamp ==
                              DateTime.fromMicrosecondsSinceEpoch(0)
                          ? Colors.green
                          : Colors.grey
                      : Colors.red,
                  subtitle: Text(
                    entriesController.entries[index].exitTimestamp ==
                            DateTime.fromMicrosecondsSinceEpoch(0)
                        ? ""
                        : DateFormat.yMd().add_Hms().format(
                              entriesController.entries[index].exitTimestamp,
                            ),
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: Text(entriesController.entries[index].licensePlate),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
