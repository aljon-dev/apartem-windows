import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Services {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ignore: non_constant_identifier_names
  Future<UserCredential?> Signin(String email, String password) async {
    try {
      // Perform sign-in and return the UserCredential
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; // Return the UserCredential object
    } catch (e) {
      // Log the error for debugging
      return null; // Return null if there is an error
    }
  }

  // ignore: non_constant_identifier_names
  CreateAnnounce(String announce) {
    FirebaseFirestore.instance.collection('announcement').doc().set({
      'announce': announce,
    });
  }

  // ignore: non_constant_identifier_names
  CreateMessage(String adminId, String tenantId, String message) {
    FirebaseFirestore.instance.collection('message').doc().set({
      'message': message,
      'adminId': adminId,
      'tenantId': tenantId,
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> ActionVacancy(String label) async {
    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('available_units')
        .doc('c6EnJE8SuwsbVnwnluZf');
    try {
      DocumentSnapshot documentSnapshot = await documentRef.get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          int currentQty = data['qty'] ?? 0;
          int amountToSubtract = 1;
          int newQty = 0;

          if (label == 'plus') {
            newQty = currentQty + amountToSubtract;
          } else if (label == 'minus') {
            if (currentQty <= 0) {
            } else {
              newQty = currentQty - amountToSubtract;
            }
          }

          await documentRef.update({
            'qty': newQty,
          });
        } else {}
      } else {}
    } catch (e) {
      // Handle errors
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> MaintenanceRequestAction(String docId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('maintenance_request')
          .doc(docId)
          .update({'status': status});
      // ignore: empty_catches
    } catch (e) {}
  }

  // ignore: non_constant_identifier_names
  CreateManageUser(
    String firstname,
    String middlename,
    String lastname,
    String contactnumber,
    String buildingnumber,
    String unitnumber,
    String username,
    String password,
  ) {
    FirebaseFirestore.instance.collection('tenant').doc().set({
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'contactnumber': contactnumber,
      'buildingnumber': buildingnumber,
      'unitnumber': unitnumber,
      'username': username,
      'password': password,
      'archive': '0',
      'vacant': 'No'
    });
  }

  AdminAccount(String username, String password) {
    FirebaseFirestore.instance.collection('users').doc().set({
      'username': username,
      'password': password,
    });
  }
}
