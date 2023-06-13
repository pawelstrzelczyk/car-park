import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_info/providers/gas_provider.dart';
import 'package:provider/provider.dart';

class GasPage extends StatefulWidget {
  const GasPage({super.key});

  @override
  State<GasPage> createState() => _GasPageState();
}

class _GasPageState extends State<GasPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gas alerts history")),
      body: Center(
        child: Consumer<GasController>(
          builder: (context, gasProvider, child) {
            gasProvider.fetchGas();
            return ListView.builder(
              itemCount: gasProvider.gas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    DateFormat.yMd().add_Hms().format(
                          gasProvider.gas[index].timestamp,
                        ),
                    style: const TextStyle(fontSize: 18),
                  ),
                  leading: const Icon(Icons.warning),
                  iconColor: Colors.red,
                  subtitle: const Text('CO level exceeded'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
