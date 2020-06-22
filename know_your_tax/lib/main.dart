import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Know Your Tax',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaxInputForm(),
    );
  }
}

class TaxInputForm extends StatefulWidget {
  @override
  TaxInputFormState createState() => TaxInputFormState();
}


class TaxInputFormState extends State<TaxInputForm> {

  final months = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  var taxes = <double>[];

  final incomeController = TextEditingController(text: '30000');

  double income = 30000.0;
  String taxText = "0.0";


  double taxRate(double incomeTillMonth) {

    if (incomeTillMonth <= 36000) {
      return 0.03;
    }

    if (incomeTillMonth <= 144000) {
      return 0.1;
    }

    if (incomeTillMonth <= 300000) {
      return 0.2;
    }

    if (incomeTillMonth <= 420000) {
      return 0.24;
    }

    if ( incomeTillMonth <= 660000) {
      return 0.3;
    }

    if (incomeTillMonth <= 960000) {
      return 0.35;
    }

    return 0.45;
  }

  double calculateTax(double totalIncome) {
    if (totalIncome <= 36000) {
      return totalIncome * 0.03;
    }

    if ( totalIncome <= 144000 ) {
      return (totalIncome - 36000) * 0.1 + 36000 * 0.03;
    }

    if ( totalIncome <= 300000) {
      return (totalIncome - 144000) * 0.2 + calculateTax(144000);
    }

    if ( totalIncome <= 420000) {
      return (totalIncome - 300000) * 0.24 + calculateTax(300000);
    }

    if (totalIncome <= 660000) {
      return (totalIncome - 420000) * 0.3 + calculateTax(420000);
    }

    if (totalIncome <= 960000) {
      return (totalIncome - 660000) * 0.35 + calculateTax(660000);
    }

    return (totalIncome - 960000) * 0.45 + calculateTax(960000);
  }

  @override
  void initState() {
    super.initState();

    incomeController.addListener(() {
      print("income text controller: ${incomeController.text}");

      final income = double.parse(incomeController.text);

      if (income <= 5000) {
        return;
      }

      final monthlyTaxes = <double>[];

      for(int i in months) {
        monthlyTaxes.add(calculateMonthTax(this.income, i));
      }

      setState(() {
        this.taxes = [];
      });

      setState(() {
        this.taxes = monthlyTaxes;
      });
    });
  }

  @override
  void dispose() {
    incomeController.dispose();
    super.dispose();
  }

  double calculateMonthTax(double monthlyIncome, int currentMonth) {
    final totalIncome = (this.income - 5000-4500-2000) * currentMonth;

    double tax = this.calculateTax(totalIncome);

    if ( currentMonth > 1) {
      final lastTotalIncome = (this.income - 5000 - 4500 - 2000) * (currentMonth - 1);

      tax = tax - calculateTax(lastTotalIncome);
    }

    return tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Know Your Tax'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list)),
        ],
      ),
      body: _incomeInput(),
    );
  }



  Widget _incomeInput() {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Enter your income'
          ),
          keyboardType: TextInputType.number,
          controller: incomeController,
        ),
        Text("Your tax is: "),
        Text(taxText),
        new TaxResultList(items: this.taxes),
      ],
    );
  }
}



class TaxResultList extends StatefulWidget {

  final List<double> items;

  TaxResultList({@required this.items});

  @override
  TaxResultListState createState() => TaxResultListState();
}


class TaxResultListState extends State<TaxResultList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: ListView.builder(
        itemCount: widget.items.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          return buildRow(i, widget.items[i]);
        },
      ),
    );
  }

  Widget buildRow(int i, double value) {
    return ListTile (
        title: Text("${i + 1} 月份:  $value")
    );
  }
}