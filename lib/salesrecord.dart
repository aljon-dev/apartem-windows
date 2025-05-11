import 'package:bogsandmila/saleRecordingInfoPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TenantList {
  final String id;
  final String buildingnumber;
  final String contactnumber;
  final String firstname;
  final String lastname;
  final String middlename;
  final String unitnumber;

  TenantList({
    required this.id,
    required this.buildingnumber,
    required this.contactnumber,
    required this.firstname,
    required this.lastname,
    required this.middlename,
    required this.unitnumber,
  });

  factory TenantList.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> tenant = doc.data() as Map<String, dynamic>;

    return TenantList(
      id: doc.id,
      buildingnumber: tenant['buildingnumber'] ?? '',
      contactnumber: tenant['contactnumber'] ?? '',
      firstname: tenant['firstname'] ?? '',
      lastname: tenant['lastname'] ?? '',
      middlename: tenant['middlename'] ?? '',
      unitnumber: tenant['unitnumber'] ?? '',
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'buildingnumber': buildingnumber,
      'contactnumber': contactnumber,
      'firstname': firstname,
      'lastname': lastname,
      'middlename': middlename,
      'unitnumber': unitnumber,
    };
  }

  String get fullName =>
      '$firstname ${middlename.isNotEmpty ? '$middlename ' : ''}$lastname';
}

class SalesRecordPage extends StatefulWidget {
  const SalesRecordPage({
    Key? key,
  }) : super(key: key);

  @override
  _SalesRecordPageState createState() => _SalesRecordPageState();
}

class _SalesRecordPageState extends State<SalesRecordPage> {
  final _firestore = FirebaseFirestore.instance;

  // Filter variables
  String? selectedBuilding;
  String? selectedUnit;
  String? selectedMonth;
  String? selectedYear;
  bool isFilterExpanded = false;

  // Building and unit options
  final List<String> buildings = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];
  final List<String> units = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15'
  ];

  // Month and year options
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  final List<String> years = ['2023', '2024', '2025', '2026', '2027', '2028'];

  // Stream to get filtered tenants
  Stream<List<TenantList>> getTenants() {
    Query<Map<String, dynamic>> query = _firestore.collection('tenant');

    if (selectedBuilding != null) {
      query = query.where('buildingnumber', isEqualTo: selectedBuilding);
    }

    if (selectedUnit != null) {
      query = query.where('unitnumber', isEqualTo: selectedUnit);
    }

    return query.snapshots().map((snapshots) {
      return snapshots.docs
          .map((doc) => TenantList.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Records'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
                isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                isFilterExpanded = !isFilterExpanded;
              });
            },
            tooltip: 'Toggle Filters',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Section
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isFilterExpanded ? null : 0,
              child: Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // First Row of Filters (Building and Unit)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            // Wider screen - show side by side
                            return Row(
                              children: [
                                Expanded(child: _buildBuildingFilter()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildUnitFilter()),
                              ],
                            );
                          } else {
                            // Narrower screen - stack vertically
                            return Column(
                              children: [
                                _buildBuildingFilter(),
                                const SizedBox(height: 12),
                                _buildUnitFilter(),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Second Row of Filters (Month and Year)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            // Wider screen - show side by side
                            return Row(
                              children: [
                                Expanded(child: _buildMonthFilter()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildYearFilter()),
                              ],
                            );
                          } else {
                            // Narrower screen - stack vertically
                            return Column(
                              children: [
                                _buildMonthFilter(),
                                const SizedBox(height: 12),
                                _buildYearFilter(),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Clear Filters Button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedBuilding = null;
                            selectedUnit = null;
                            selectedMonth = null;
                            selectedYear = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All Filters'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter Summary (when filter is collapsed but has values)
            if (!isFilterExpanded && _hasActiveFilters())
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_getActiveFiltersText())),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          selectedBuilding = null;
                          selectedUnit = null;
                          selectedMonth = null;
                          selectedYear = null;
                        });
                      },
                      tooltip: 'Clear Filters',
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),

            // Tenant List Section
            Expanded(
              child: StreamBuilder<List<TenantList>>(
                stream: getTenants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No tenants found with current filters',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final tenants = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: tenants.length,
                    itemBuilder: (context, index) {
                      final tenant = tenants[index];
                      return _buildTenantCard(tenant);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedBuilding != null ||
        selectedUnit != null ||
        selectedMonth != null ||
        selectedYear != null;
  }

  String _getActiveFiltersText() {
    List<String> filters = [];

    if (selectedBuilding != null) filters.add('Building: $selectedBuilding');
    if (selectedUnit != null) filters.add('Unit: $selectedUnit');
    if (selectedMonth != null) filters.add('Month: $selectedMonth');
    if (selectedYear != null) filters.add('Year: $selectedYear');

    return filters.join(' | ');
  }

  Widget _buildBuildingFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Building',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.apartment),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: selectedBuilding,
      items: buildings.map((building) {
        return DropdownMenuItem(
          value: building,
          child: Text('Building $building'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedBuilding = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildUnitFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Unit',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.door_front_door),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: selectedUnit,
      items: units.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text('Unit $unit'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedUnit = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildMonthFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.calendar_month),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: selectedMonth,
      items: months.map((month) {
        return DropdownMenuItem(
          value: month,
          child: Text(month),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedMonth = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildYearFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.date_range),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      value: selectedYear,
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(year),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedYear = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildTenantCard(TenantList tenant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => saleRecordingInfoPage(
                uid: tenant.id,
                firstname: tenant.firstname,
                lastname: tenant.lastname,
                buildnumber: tenant.buildingnumber,
                unitnumber: tenant.unitnumber,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar or Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    tenant.firstname.isNotEmpty && tenant.lastname.isNotEmpty
                        ? '${tenant.firstname[0]}${tenant.lastname[0]}'
                        : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Tenant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.apartment,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Building ${tenant.buildingnumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.door_front_door,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Unit ${tenant.unitnumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          tenant.contactnumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => saleRecordingInfoPage(
                            uid: tenant.id,
                            firstname: tenant.firstname,
                            lastname: tenant.lastname,
                            buildnumber: tenant.buildingnumber,
                            unitnumber: tenant.unitnumber,
                          ),
                        ),
                      );
                    },
                    tooltip: 'View Details',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
