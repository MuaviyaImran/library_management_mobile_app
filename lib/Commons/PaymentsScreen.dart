import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
      ),
      appBar: AppBar(
        title: const Text(
          "Payments",
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: fireStore.collection('payments').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No payments found"),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: CircleAvatar(
                              child: Text((index + 1).toString()),
                            ),
                            title: Text(snapshot.data!.docs[index]["paidby"]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data!.docs[index]["reason"] +
                                    " - " +
                                    snapshot.data!.docs[index]["amount"]
                                        .toString()),
                                Text(snapshot.data!.docs[index]["time"]
                                    .toDate()
                                    .toString()),
                              ],
                            ));
                      });
                }),
          ),
        ],
      ),
    );
  }
}
