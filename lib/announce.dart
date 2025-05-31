import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class announcementPage extends StatefulWidget {
  const announcementPage({super.key});

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<announcementPage> {
  final TextEditingController _announcementController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendAnnouncement() async {
    if (_announcementController.text.trim().isEmpty) return;

    await _firestore.collection('announcement').add({
      "announce": _announcementController.text.trim(),
    });
    _announcementController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully Added Announcement")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(" Announcements")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left Column: Input and Button
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Announcement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Note: Fill in the text field and press "Send". All tenants will receive this announcement.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _announcementController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: "Enter announcement here",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sendAnnouncement,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text("Send"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            // Right Column: Announcements List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'List of Announcements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: _firestore.collection('announcement').orderBy('announce', descending: true).snapshots().map((snapshot) => snapshot.docs),
                      builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final announcements = snapshot.data!;
                        if (announcements.isEmpty) {
                          return const Center(child: Text('No announcements available.'));
                        }

                        return ListView.builder(
                          itemCount: announcements.length,
                          itemBuilder: (context, index) {
                            final doc = announcements[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(doc.get('announce')),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _firestore.collection('announcement').doc(doc.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Announcement deleted')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
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
