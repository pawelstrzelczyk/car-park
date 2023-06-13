import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_info/pages/gas_page.dart';
import 'package:parking_info/pages/vehicle_page.dart';
import 'package:parking_info/providers/entries_provider.dart';
import 'package:parking_info/providers/gas_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GasController? gasController;
  EntriesController? entriesController;
  @override
  void initState() {
    gasController = Provider.of<GasController>(context, listen: false);
    gasController?.fetchLastGas();

    entriesController = Provider.of<EntriesController>(context, listen: false);
    entriesController?.fetchAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parking Info")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await entriesController?.fetchAll();
            await gasController?.fetchLastGas();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Consumer2<GasController, EntriesController>(
              builder: (context, gas, entries, child) {
                return Column(
                  children: [
                    const Text(
                      "Last gas level alert:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      DateFormat.Hms().format(gas.lastGasTimestamp),
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GasPage(),
                          ),
                        );
                      },
                      child: const Text("Logs history"),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Free slots:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      "${100 - entries.currentVehicleNumber}/100",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Number of entries since opening:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      "${entries.totalVehicleNumber}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Number of unique cars since opening:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      "${entries.uniqueLicensePlates}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VehiclePage(),
                          ),
                        );
                      },
                      child: const Text("Parking history"),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Total fees paid:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      "${entries.feesSum} PLN",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Average fee paid:",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Divider(),
                    Text(
                      "${entries.feesSum} PLN",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
