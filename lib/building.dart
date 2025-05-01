import 'package:bogsandmila/logo.dart';
import 'package:bogsandmila/tenant.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildingPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final uid;
  // ignore: prefer_typing_uninitialized_variables
  final type;
  const BuildingPage({super.key, required this.uid, required this.type});

  @override
  // ignore: library_private_types_in_public_api
  _BuildingPage createState() => _BuildingPage();
}

class _BuildingPage extends State<BuildingPage> {
  final List<Item> _items = List.generate(
    5,
    (index) => Item(
      index + 1,
      'Name $index',
      index % 2 == 0 ? 'Active' : 'Inactive',
    ),
  );

  final int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = (startIndex + _rowsPerPage < _items.length)
        ? startIndex + _rowsPerPage
        : _items.length;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => const Color.fromARGB(224, 17, 17, 17),
          ),
          dataRowColor: WidgetStateColor.resolveWith(
            (states) => Colors.white,
          ),
          headingTextStyle: const TextStyle(color: Colors.white),
          dataTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LogoPage(uid: widget.uid, type: widget.type),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            DataTable(
                              columns: [
                                DataColumn(
                                  label: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text(
                                      'Building',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text(
                                      'Action',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              rows: List.generate(
                                endIndex - startIndex,
                                (index) {
                                  final item = _items[startIndex + index];
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'Building ${item.id.toString()}',
                                              style: const TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              child:
                                                  FaIcon(FontAwesomeIcons.eye),
                                              onTap: () {
                                                Navigator.push(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TenantPage(
                                                            uid: widget.uid,
                                                            type: widget.type,
                                                            buildingnumber:
                                                                item.id),
                                                  ),
                                                );
                                              },
                                            )),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  (_items.length / _rowsPerPage).ceil(),
                                  (index) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentPage = index;
                                        });
                                      },
                                      // ignore: sort_child_properties_last
                                      child: Text((index + 1).toString()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _currentPage == index
                                            ? const Color(0xdd1E1E1E)
                                            : Colors.white,
                                        foregroundColor: _currentPage == index
                                            ? Colors.white
                                            : const Color(0xdd1E1E1E),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color.fromARGB(255, 30, 30, 30),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Center(
                  child: Text(
                    'Copyright © Bogs and Mila Apartment. All Rights Reserved.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  Item(this.id, this.name, this.status);

  final int id;
  final String name;
  final String status;
}
