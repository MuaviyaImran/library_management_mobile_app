import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class GiveFeedback extends StatefulWidget {
  const GiveFeedback({Key? key}) : super(key: key);

  @override
  State<GiveFeedback> createState() => _GiveFeedbackState();
}

class _GiveFeedbackState extends State<GiveFeedback> {
  var generalAppUser;
  TextEditingController feedbackController = TextEditingController();

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
            "Your Feedbacks",
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
                icon: const Icon(Icons.home))
          ],
          elevation: 0,
          backgroundColor: MyColors.MATERIAL_LIGHT_GREEN,
        ),
        drawer: drawer(context, generalAppUser),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: "Write your feedback here",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    fireStore.collection("feedbacks").add({
                      "feedback": feedbackController.text,
                      "user": generalAppUser["email"],
                      "UID": generalAppUser["UID"],
                      "time": DateTime.now()
                    });
                    feedbackController.clear();
                    showSnackBarMsg(context, "Feedback submitted successfully");
                  },
                  child: const Text("Submit")),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: fireStore
                      .collection("feedbacks")
                      .where("user", isEqualTo: generalAppUser["email"])
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No feedbacks given yet"),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              leading: CircleAvatar(
                                child: Text((index + 1).toString()),
                              ),
                              title:
                                  Text(snapshot.data!.docs[index]["feedback"]),
                              subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(snapshot.data!.docs[index]["time"]
                                      .toDate()
                                      .toString()
                                      .split(' ')[0])));
                        });
                  }),
            )
          ],
        ));
  }
}
