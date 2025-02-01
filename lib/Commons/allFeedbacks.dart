import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class AllFeedbacks extends StatefulWidget {
  const AllFeedbacks({
    Key? key,
  }) : super(key: key);

  @override
  State<AllFeedbacks> createState() => _AllFeedbacksState();
}

class _AllFeedbacksState extends State<AllFeedbacks> {
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
          "Feedbacks",
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
              stream: fireStore.collection('feedbacks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final feedbacks = snapshot.data!.docs;
                List<Widget> feedbackWidgets = [];

                for (var feedback in feedbacks) {
                  final feedbackText = feedback['feedback'];
                  final feedbackUser = feedback['user'];

                  // Create UI for each feedback
                  final feedbackWidget = Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            feedbackUser,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: 'Itim-Regular',
                            ),
                          ),
                          subtitle: Text(
                            feedbackText,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: 'Itim-Regular',
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                      ],
                    ),
                  );
                  feedbackWidgets.add(feedbackWidget);
                }

                // Return a ListView to display the feedbacks
                return ListView(
                  children: feedbackWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
