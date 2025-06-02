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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('sales_record').doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Transaction not found.')));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final paymentType = data['payment_type'] ?? 'N/A';
        final paymentMode = data['payment_mode'] ?? 'N/A';
        final amountPaid = data['amount_paid'] ?? '0';
        final balance = data['balance'] ?? '0';

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
          appBar: AppBar(title: const Text("Transaction Details")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        "$month $year",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Icon(statusIcon, color: statusColor, size: 60),
                      Text(
                        "Transaction ${status.toUpperCase()}",
                        style: TextStyle(fontSize: 16, color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text("Date: $datetime"),
                const SizedBox(height: 10),
                Text("Payer Name: ${payerName.isEmpty ? 'N/A' : payerName}"),
                const SizedBox(height: 10),
                Text("Rental Cost: ₱ $rentalCost"),
                const SizedBox(height: 10),
                Text("Amount Paid: ₱ $amountPaid"),
                const SizedBox(height: 10),
                Text("Remaining Balance: ₱ $balance"),
                const SizedBox(height: 10),
                const Text("Payment Mode:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: paymentMode != 'N/A' ? paymentMode : null,
                  items: ['GCash', 'Cash'].map((mode) {
                    return DropdownMenuItem(value: mode, child: Text(mode));
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (String? newMode) async {
                    if (newMode != null) {
                      await FirebaseFirestore.instance.collection('sales_record').doc(id).update({'payment_mode': newMode});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Payment mode updated to $newMode")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                Text("Payment Type: $paymentType"),
                const SizedBox(height: 10),
                Text("Status: $status"),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text("Proof of Payment:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Divider(),
                const Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('sales_record').doc(id).collection('payments').orderBy('timestamp', descending: true).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No payments made yet.");
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final payment = doc.data() as Map<String, dynamic>;
                        final timestamp = payment['timestamp'] != null ? (payment['timestamp'] as Timestamp).toDate() : null;
                        final String paymentStatus = (payment['status'] ?? '').toLowerCase();
                        final String status = (payment['status'] ?? 'unpaid').toLowerCase();
                        final String type = (payment['payment_type'] ?? '').toLowerCase();
                        final String label = type == 'partial' ? 'Partial - ${status[0].toUpperCase()}${status.substring(1)}' : '${status[0].toUpperCase()}${status.substring(1)}';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text("₱ ${payment['amount'] ?? '0.00'}"),
                            subtitle: Text(
                              "${payment['payer_name'] ?? 'Unknown'} • ${timestamp != null ? timestamp.toString().split('.')[0] : 'No date'}",
                            ),
                            trailing: Text(
                              label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final updated = await showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (_) => PaymentStatusEditor(
                                  salesId: id,
                                  paymentId: doc.id,
                                  currentStatus: payment['status'] ?? 'partial',
                                ),
                              );

                              if (updated == true) {
                                // Force rebuild after modal is closed
                                (context as Element).markNeedsBuild();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: status.toLowerCase() == 'paid' ? null : () => updateStatus(context, 'unpaid'),
                        icon: const Icon(Icons.cancel),
                        label: const Text("Unpaid"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          disabledBackgroundColor: Colors.red.shade200,
                          disabledForegroundColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: status.toLowerCase() == 'paid' ? null : () => updateStatus(context, 'paid'),
                        icon: const Icon(Icons.check),
                        label: const Text("Paid"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          disabledBackgroundColor: Colors.green.shade200,
                          disabledForegroundColor: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

class PaymentStatusEditor extends StatefulWidget {
  final String salesId;
  final String paymentId;
  final String currentStatus;

  const PaymentStatusEditor({
    super.key,
    required this.salesId,
    required this.paymentId,
    required this.currentStatus,
  });

  @override
  State<PaymentStatusEditor> createState() => _PaymentStatusEditorState();
}

class _PaymentStatusEditorState extends State<PaymentStatusEditor> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.currentStatus.toLowerCase();
  }

  Future<void> updatePaymentStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('sales_record').doc(widget.salesId).collection('payments').doc(widget.paymentId).update({'status': newStatus});
    setState(() {
      currentStatus = newStatus;
    });

    // Return true to trigger UI refresh in parent
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaid = currentStatus == 'paid';
    final bool isUnpaid = currentStatus == 'unpaid';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Update Payment Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isPaid ? null : () => updatePaymentStatus('paid'),
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUnpaid ? null : () => updatePaymentStatus('unpaid'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Mark as Unpaid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.red.shade200,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
