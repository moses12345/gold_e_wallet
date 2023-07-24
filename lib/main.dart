import 'dart:ffi';

import 'package:e_wallet/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void main() => runApp(const WalletApp());

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_)=>UserProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/amount_screen': (context) => AmountScreen(),
        '/wallet':(context)=>WalletScreen()
      },
      home:KeyboardDismissOnTap(
        child: LoginScreen(),
      ),
    ),);
  }
}




class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String username = _usernameController.text.trim();
                  String password = _passwordController.text.trim();


                  bool loginSuccess =
                  await Provider.of<UserProvider>(context, listen: false)
                      .login(username, password);

                  if (loginSuccess) {
                    Navigator.pushNamed(
                      context,
                      '/wallet',
                    );
                    // Navigate to the home screen or next screen
                  } else {
                    // Show error message or handle login failure
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class WalletScreen extends StatefulWidget  {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FocusNode _upiIdFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiIdFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              Expanded(
                child: Text(
                  'Gold Wallet',
                  textAlign: TextAlign.left,
                ),
              ),
              Text(
                'Gold Balance: ${"0.5 g"}', // Replace with actual balance
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),

        ),
        body: Column(
          children: [
            TabBar(
                controller: _tabController,
                tabs: [
                Tab(
                  child: Row(
                    children: [
                      Icon(Icons.attach_money),
                      SizedBox(width: 5),
                      Text('Buy/Sell Gold'),
                    ],
                  ),
                ),
                  Tab(
                    child: Row(
                      children: [
                        Icon( Icons.payment_outlined),
                        SizedBox(width: 5),
                        Text('Transactions'),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.black
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:  [
                  BuySellTab(),
                  TransactionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuySellTab extends StatefulWidget {

  @override
  _BuySellTabState createState() => _BuySellTabState();

}

class _BuySellTabState extends State<BuySellTab> {
  @override
  void initState() {
    
    Future.delayed(Duration.zero,(){
      context.read<UserProvider>().getTodayGoldValue(context);
    });

    // UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    //
    // userProvider.getTodayGoldValue();
    // print('this is jwt string in buy sell screen:$jwtToken');
    super.initState();

  }

  TextEditingController _upiIdController = TextEditingController();
  double goldPrice = 5000;
  TextEditingController gramsController = TextEditingController();
  TextEditingController rupeesController = TextEditingController();
  bool _isUpiIdValid = true;

  final List<Transaction> transactions = [
    Transaction('001', DateTime(2022, 1, 1), 100.0,"Buy"),
    Transaction('002', DateTime(2022, 1, 2), 200.0,"Buy"),
    Transaction('003', DateTime(2022, 1, 3), 300.0,"Buy"),
    Transaction('004', DateTime(2022, 1, 4), 400.0,"Buy"),
    Transaction('005', DateTime(2022, 1, 5), 500.0,"Buy"),
    Transaction('006', DateTime(2022, 1, 6), 600.0,"sell"),
    Transaction('007', DateTime(2022, 1, 7), 700.0,"Buy"),
    Transaction('008', DateTime(2022, 1, 8), 800.0,"Buy"),
    Transaction('009', DateTime(2022, 1, 9), 900.0,"Buy"),
    Transaction('010', DateTime(2022, 1, 10), 1000.0,"Buy"),
  ];

  void _validateUPIId() {
    setState(() {
      // Perform basic validation here
      String upiId = _upiIdController.text.trim();
      _isUpiIdValid = upiId.isNotEmpty;
    });
  }

  void calculateGoldValueInRupeeToGrams() {
    double rupees = double.tryParse(rupeesController.text) ?? 0;
    double grams = rupees / goldPrice;
    gramsController.text = grams.toStringAsFixed(2);
  }

  void calculateGoldValueGramToRupee() {
    double grams = double.tryParse(gramsController.text) ?? 0;
    double rupees = grams * goldPrice;
    rupeesController.text = rupees.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    gramsController.dispose();
    rupeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<UserProvider>(builder:(context,userProvider,_){
          return  Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Today Gold Price: ${userProvider.todayGoldValue}"),
          );
        } ),

        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Value In Grams',
                ),
                controller: gramsController,
                onChanged: (value) => calculateGoldValueGramToRupee(),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Value In Rupees',
                ),
                controller: rupeesController,
                onChanged: (value) => calculateGoldValueInRupeeToGrams(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _validateUPIId,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Buy/Sell History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200, // Set an explicit height for the SizedBox
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Buy/Sell Details')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: transactions.map((transaction) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text('${transaction.transactionId}\n${transaction.dateTime.toString()}'),
                      ),
                      DataCell(
                        Text('${transaction.type}'),
                      ),
                      DataCell(
                        Text(transaction.amount.toString()),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class TransactionTab extends StatefulWidget {
  @override
  _TransactionTabState createState() => _TransactionTabState();
}

class Transaction {
  final String transactionId;
  final DateTime dateTime;
  final double amount;
  final String type;

  Transaction(this.transactionId,this.dateTime,this.amount,this.type);
}

class _TransactionTabState extends State<TransactionTab> {
  TextEditingController _upiIdController = TextEditingController();
  bool _isUpiIdValid = true;

  final List<Transaction> transactions = [
    Transaction('001', DateTime(2022, 1, 1), 100.0,"Pay"),
    Transaction('002', DateTime(2022, 1, 2), 200.0,"Pay"),
    Transaction('003', DateTime(2022, 1, 3), 300.0,"Pay"),
    Transaction('004', DateTime(2022, 1, 4), 400.0,"Pay"),
    Transaction('005', DateTime(2022, 1, 5), 500.0,"Pay"),
    Transaction('006', DateTime(2022, 1, 6), 600.0,"Pay"),
    Transaction('007', DateTime(2022, 1, 7), 700.0,"Pay"),
    Transaction('008', DateTime(2022, 1, 8), 800.0,"Pay"),
    Transaction('009', DateTime(2022, 1, 9), 900.0,"Pay"),
    Transaction('010', DateTime(2022, 1, 10), 1000.0,"Pay"),
  ];

  void _validateUPIId() {
    String upiId = _upiIdController.text.trim();
    setState(() {
      // Perform basic validation here

      _isUpiIdValid =  RegExp(r'^\d{10}@[\w\s]+$').hasMatch(upiId);
    });
    if (_isUpiIdValid) {
      // Navigate to the new screen with the UPI ID and amount
      Navigator.pushNamed(
        context,
        '/amount_screen',
        arguments: {'upiId': upiId},
      );
    }
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter UPI ID',
                    errorText: _isUpiIdValid ? null : 'Invalid UPI ID',
                  ),
                  controller: _upiIdController,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _validateUPIId,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Expanded(child: Padding(padding:EdgeInsets.only(bottom: 20.0), child:  Container(
        decoration: BoxDecoration(
        border: Border.all(
        color: Colors.grey,
        width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        ),
        child:SingleChildScrollView(child:DataTable(
          columns: [
            DataColumn(label: Text('Transaction Details')),
            DataColumn(label: Text('Amount')),
          ],
          rows: transactions.map((transaction) {
            return DataRow(
              cells: [
                DataCell(
                  Text('${transaction.transactionId}\n${transaction.dateTime.toString()}'),
                ),
                DataCell(
                  Text(transaction.amount.toString()),
                ),
                  ],
                );
              }).toList(),
            )
        )
        )
        )
        )
        ],
      );
  }
}

class AmountScreen extends StatefulWidget{
  @override
  _AmountScreen createState()=>_AmountScreen();
}

class _AmountScreen extends State<AmountScreen> {

  TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from the previous screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // Extract the UPI ID from the arguments
    String upiId = args['upiId'];



    void submitAmount(){
      print('this is amount ${_amountController.text}');
      print("this is upi id :,${upiId}");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Amount'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('UPI ID: $upiId'),
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                ),
                controller: _amountController,
                // Add controller and logic to handle the entered amount
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  submitAmount();
                  // Add logic to handle the amount submission
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


