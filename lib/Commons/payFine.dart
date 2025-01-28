import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class PayFee extends StatefulWidget {
  const PayFee({Key? key}) : super(key: key);

  @override
  State<PayFee> createState() => _PayFeeState();
}

class _PayFeeState extends State<PayFee> {
  var generalAppUser;

  @override
  void initState() {
    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    MyAppSize.config(MediaQuery.of(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pending Payments",
          style: TextStyle(
              fontSize: 19, color: Colors.white, fontFamily: 'Itim-Regular'),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashBoard()),
              );
            },
            icon: const Icon(Icons.home),
          )
        ],
        elevation: 0,
        backgroundColor: MyColors.MATERIAL_LIGHT_GREEN,
      ),
      drawer: drawer(context, generalAppUser),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: fireStore
            .collection('Users')
            .doc(generalAppUser['UID'])
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            // Handle the case where the document does not exist
            return const Center(child: Text('User data not found.'));
          } else {
            // Safely access the document data
            var userData = snapshot.data!.data();
            var fine = userData?['fine'] ?? 0; // Ensure 'fine' is not null

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  fine > 0
                      ? Text(
                          "Fine to be paid: Rs.$fine",
                          style: const TextStyle(fontSize: 20),
                        )
                      : const Text(
                          "No Fine Pending",
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                  const SizedBox(height: 20),
                  if (fine > 0)
                    ElevatedButton(
                      onPressed: () {
                        // Update the user's fine to 0 and log the payment
                        fireStore
                            .collection('Users')
                            .doc(generalAppUser['UID'])
                            .update({'fine': 0});
                        fireStore.collection('payments').add({
                          'UID': generalAppUser['UID'],
                          'paidby': generalAppUser['email'],
                          'amount': fine,
                          'reason': 'Fine Payment',
                          'time': DateTime.now(),
                        });
                      },
                      child: const Text("Pay Fine"),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
