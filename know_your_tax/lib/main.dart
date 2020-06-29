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
        primarySwatch: Colors.blue,
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
  double taxExemption = 5000.0;
  final subsidyForOld = 2000;
  final subsidyForEachChild = 1000;
  int childNumber = 0;

  final double endowmentRate = 0.08;
  final double minEndowmentAmount = 4927;
  final double maxEndowmentAmount = 24633;
  final double medicalRate = 0.02;
  final double minMedicalAmount = 4927;
  final double maxMedicalAmount = 24633;
  final double unemploymentRate = 0.005;
  final double minUnemploymentAmount = 4927;
  final double maxUnemploymentAmount = 24633;
  final double houseAccumulationRate = 0.12;
  final double minHouseAccumulationAmount = 2415;
  final double maxHouseAccumulationAmount = 24629;


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

  double calculateIncomeTax(double totalIncome) {
    if (totalIncome <= 36000) {
      return totalIncome * 0.03;
    }

    if ( totalIncome <= 144000 ) {
      return (totalIncome - 36000) * 0.1 + 36000 * 0.03;
    }

    if ( totalIncome <= 300000) {
      return (totalIncome - 144000) * 0.2 + calculateIncomeTax(144000);
    }

    if ( totalIncome <= 420000) {
      return (totalIncome - 300000) * 0.24 + calculateIncomeTax(300000);
    }

    if (totalIncome <= 660000) {
      return (totalIncome - 420000) * 0.3 + calculateIncomeTax(420000);
    }

    if (totalIncome <= 960000) {
      return (totalIncome - 660000) * 0.35 + calculateIncomeTax(660000);
    }

    return (totalIncome - 960000) * 0.45 + calculateIncomeTax(960000);
  }

  double calculateInsurance(double minAmount, double maxAmount, double income, double rate) {

    double amount = maxAmount;

    if (income < maxAmount) {
      amount = income;
    }

    if (income < minAmount) {
      amount = minAmount;
    }

    print("insurance amount: $amount");

    return amount * rate;

  }

  @override
  void initState() {
    super.initState();

    incomeController.addListener(() {
      print("income text controller: ${incomeController.text}");

      final income = double.parse(incomeController.text);

      if (income <= 5000) {
        setState(() {
          this.taxes = [];
        });

        return;
      }

      final monthlyTaxes = <double>[];

      for(int i in months) {
        monthlyTaxes.add(calculateMonthTax(income, i));
      }



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

  double totalTaxExemption() {
    return taxExemption + subsidyForOld + subsidyForEachChild * childNumber;
  }

  double totalInsuranceAmount(double monthlyIncome) {

      double endowmentInsurance =
        calculateInsurance(minEndowmentAmount, maxEndowmentAmount, monthlyIncome, endowmentRate);
      print("endowment insurance: $endowmentInsurance");

      double medicalInsurance =
        calculateInsurance(minMedicalAmount, maxMedicalAmount, monthlyIncome, medicalRate);
      print("medical insurance: $medicalInsurance");

      double unemploymentInsurance =
        calculateInsurance(minUnemploymentAmount, maxUnemploymentAmount, monthlyIncome, unemploymentRate);
      print("unemployment insurance: $unemploymentInsurance");
      double houseAccumulationInsurance =
        calculateInsurance(minHouseAccumulationAmount, maxHouseAccumulationAmount, monthlyIncome, houseAccumulationRate);

      print("house insurance: $houseAccumulationInsurance");
      final totalInsurance = endowmentInsurance + medicalInsurance + unemploymentInsurance + houseAccumulationInsurance;

      print("total insurance: $totalInsurance");
      return totalInsurance;

  }

  double calculateMonthTax(double monthlyIncome, int currentMonth) {
    final totalIncome = (monthlyIncome - totalTaxExemption() - totalInsuranceAmount(monthlyIncome)) * currentMonth;

    print("income taxed: $totalIncome");

    // tax need to be paid till now
    double tax = this.calculateIncomeTax(totalIncome);

    if ( currentMonth > 1) {
      final lastTotalIncome = (monthlyIncome - totalTaxExemption() - totalInsuranceAmount(monthlyIncome)) * (currentMonth - 1);

      // subtract tax paid till last month
      tax = tax - calculateIncomeTax(lastTotalIncome);
    }

    tax = double.parse(tax.toStringAsFixed(2));

    return tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Know Your Tax'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingView()),
              );
            },
          ),
        ],
      ),
      body: _incomeInput(),
    );
  }



  Widget _incomeInput() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18.0),
          child: TextFormField(
            decoration: InputDecoration(
                labelText: 'Enter your income'
            ),
            keyboardType: TextInputType.number,
            controller: incomeController,
          )
        ),
        Text("你每月应缴纳的个人所得税是"),
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
        padding: const EdgeInsets.all(8.0),

        itemBuilder: (context, i) {
          return buildRow(i, widget.items[i]);
        },
      ),
    );
  }

  Widget buildRow(int i, double value) {
    return ListTile (
        title: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20.0,
                  child: Text("${1+i} 月"),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30.0),
                  child: Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                ),
              ]
            ),
            Divider(color: Colors.blue)
          ],
        )
    );
  }
}

class SettingView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            tooltip: "Done",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            this._buildInputField(8, "社保缴纳基数"),

            this._buildInputField(7, "公积金缴纳基数"),
            this._buildInputField(6, "医保缴纳基数"),
            this._buildInputField(0, "补充公积金缴纳基数"),
          ],
        ),
      )

//      Center(
//        child: RaisedButton(
//          onPressed: (){
//            Navigator.pop(context);
//          },
//          child: Text('Go back'),
//        )
//      )
    );
  }

  Widget _buildInputField(int defaultValue, String name) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(hintText: name),
            keyboardType: TextInputType.number,
          ),
        ),
        Expanded(
          flex: 1,
          child: TextField(
            decoration: InputDecoration(hintText: "比例"),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.numberWithOptions(),
          ),
        ),
        Text("%")
      ],
    );
  }
}