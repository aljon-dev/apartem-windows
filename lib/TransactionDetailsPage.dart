import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final String id;
  final String month;
  final String year;
  final String datetime;
  final String payerName;
  final String rentalCost;
  final String status;
  final String proofUrl;

  const TransactionDetailsPage({
    super.key,
    required this.id,
    required this.month,
    required this.year,
    required this.datetime,
    required this.payerName,
    required this.rentalCost,
    required this.status,
    required this.proofUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'under review':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "$month $year",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(statusIcon, color: statusColor, size: 60),
                  Text(
                    "Transaction ${status.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text("Date: $datetime"),
            const SizedBox(height: 10),
            Text("Payer Name: ${payerName.isEmpty ? 'N/A' : payerName}"),
            const SizedBox(height: 10),
            Text("Amount: ₱ $rentalCost"),
            const SizedBox(height: 10),
            Text("Status: $status"),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Proof of Payment:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            proofUrl.isNotEmpty && proofUrl != "N/A"
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageViewer(imageUrl: proofUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        proofUrl,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Text("Failed to load image."),
                      ),
                    ),
                  )
                : const Text("No proof of payment uploaded."),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => updateStatus(context, 'unpaid'),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Unpaid"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => updateStatus(context, 'paid'),
                    icon: const Icon(Icons.check),
                    label: const Text("Paid"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('sales_record').doc(id).update({'status': newStatus});
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to ${newStatus.toUpperCase()}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }
}

// ✅ Full-screen image viewer with zoom
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Proof of Payment", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) => const Text(
              "Failed to load image",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
