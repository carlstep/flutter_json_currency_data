// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Currency>> fetchCurrencies(http.Client client) async {
  final response =
      await client.get(Uri.parse('https://floatrates.com/daily/usd.json'));

  return parseCurrencies(response.body);
}

// a function that converts a response body into a List<Currency>
List<Currency> parseCurrencies(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Currency>((json) => Currency.fromJson(json)).toList();
}

class Currency {
  final String code;
  final String alphaCode;
  final String numericCode;
  final String name;
  final double rate;
  final String? date;
  final double inverseRate;

  Currency({
    required this.code,
    required this.alphaCode,
    required this.numericCode,
    required this.name,
    required this.rate,
    required this.date,
    required this.inverseRate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json["code"] as String,
      alphaCode: json["alphaCode"] as String,
      numericCode: json["numericCode"] as String,
      name: json["name"] as String,
      rate: json["rate"].toDouble() as double,
      date: json["date"] as String?,
      inverseRate: json["inverseRate"].toDouble() as double,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "alphaCode": alphaCode,
        "numericCode": numericCode,
        "name": name,
        "rate": rate,
        "date": date,
        "inverseRate": inverseRate,
      };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String appTitle = 'JSON Currency Feed';

    return MaterialApp(
      home: PageOne(title: appTitle),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: FutureBuilder<List<Currency>>(
          future: fetchCurrencies(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('...has error'),
              );
            } else if (snapshot.hasData) {
              return CurrencyList(currencies: snapshot.data!);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class CurrencyList extends StatelessWidget {
  const CurrencyList({
    Key? key,
    required this.currencies,
  }) : super(key: key);

  final List<Currency> currencies;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(currencies[index].alphaCode),
          title: Text(currencies[index].name),
        );
      },
    );
  }
}
