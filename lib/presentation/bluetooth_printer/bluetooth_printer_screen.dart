import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class PrinterScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {'title': 'Cadbury Dairy Milk', 'price': 15, 'qty': 2},
    {'title': 'Parle-G Gluco Biscut', 'price': 5, 'qty': 5},
    {'title': 'Fresh Onion - 1KG', 'price': 20, 'qty': 1},
    {'title': 'Fresh Sweet Lime', 'price': 20, 'qty': 5},
    {'title': 'Maggi', 'price': 10, 'qty': 5},
  ];

  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  Widget build(BuildContext context) {
    int _total = 0;
    _total = data.map((e) => e['price'] * e['qty']).reduce(
          (value, element) => value + element,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter - Thermal Printer'),
        // backgroundColor: AppColors.bgClr,
        // backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (c, i) {
                  return ListTile(
                    title: Text(
                      data[i]['title'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${f.format(data[i]['price'])} x ${data[i]['qty']}",
                    ),
                    trailing: Text(
                      f.format(
                        data[i]['price'] * data[i]['qty'],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    "Total: ${f.format(_total)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrintPage(data),
                          ),
                        );
                      },
                      icon: Icon(Icons.print),
                      label: Text('Print'),
                      style: TextButton.styleFrom(
                          iconColor: Colors.white, backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class PrintPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  PrintPage(this.data);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";
  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initPrinter()});
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
          (val) {
        if (!mounted) return;
        setState(() => {_devices = val});
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "No Devices";
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
        backgroundColor: Colors.redAccent,
      ),
      body: _devices.isEmpty
          ? Center(
        child: Text(_devicesMsg ?? ''),
      )
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c, i) {
          return ListTile(
            leading: Icon(Icons.print),
            title: Text(_devices[i].name ?? "N/A"),
            subtitle: Text(_devices[i].address ?? "N/A"),
            onTap: () {
              _startPrint(_devices[i]);
            },
          );
        },
      ),
    );
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: "Grocery App",
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1,
        ),
      );

      for (var i = 0; i < widget.data.length; i++) {
        list.add(
          LineText(
            type: LineText.TYPE_TEXT,
            content: widget.data[i]['title'],
            weight: 0,
            align: LineText.ALIGN_LEFT,
            linefeed: 1,
          ),
        );

        list.add(
          LineText(
            type: LineText.TYPE_TEXT,
            content:
            "${f.format(this.widget.data[i]['price'])} x ${this.widget.data[i]['qty']}",
            align: LineText.ALIGN_LEFT,
            linefeed: 1,
          ),
        );
      }
    }
  }
}
