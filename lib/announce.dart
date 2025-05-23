import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class announcementPage extends StatefulWidget {
  const announcementPage({super.key});

  @override
  _announcementPageState createState() => _announcementPageState();
}

class _announcementPageState extends State<announcementPage> {
  final TextEditingController _AnnouncementController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendAnnouncement() async {
    _firestore.collection('announcement').add({
      "announce": _AnnouncementController.text,
    });
    _AnnouncementController.text = "";
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Added Announcement")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Note: Fill in the text field of the announcement and press “send”. All tenants will receive this general announcement. '),
            const SizedBox(height: 20),
            TextFormField(
              controller: _AnnouncementController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: "Enter an announcement here",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: sendAnnouncement,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black),
                  )),
                  child: const Text("Send")),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'List of Announcements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder<List<QueryDocumentSnapshot>>(
                    stream: _firestore.collection('announcement').snapshots().map((snapshot) => snapshot.docs),
                    builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final announcement = snapshot.data;

                      return ListView.builder(
                          itemCount: announcement!.length,
                          itemBuilder: (context, index) {
                            final announcementList = announcement[index];

                            return Card(
                              child: ListTile(
                                title: Text(announcementList.get('announce')),
                                trailing: ElevatedButton(
                                    onPressed: () {
                                      _firestore.collection('announcement').doc(announcementList.id).delete();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement deleted')));
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    child: const Text('Delete')),
                              ),
                            );
                          });
                    }))
          ],
        ),
      ),
    );
  }
}
