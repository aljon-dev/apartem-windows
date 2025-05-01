import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  double totalAmount = 0.0;
  double computeTotalBuilding(List<Map<String, dynamic>> buildingRecords) {
    double total = 0.0;

    for (var record in buildingRecords) {
      // Make sure to safely handle potential null or non-numeric values
      var availableValue = record['available'];
      if (availableValue is num) {
        total += availableValue.toDouble();
      } else if (availableValue is String) {
        // Optionally handle string representations of numbers
        total += double.tryParse(availableValue) ?? 0.0;
      }
    }

    return total;
  }

  Future<void> fetchAndComputeTotal() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('building').get();

      List<Map<String, dynamic>> buildingRecords = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print(
          'Fetched records: $buildingRecords'); // Add this line to see the fetched data

      setState(() {
        totalAmount = computeTotalBuilding(buildingRecords);
        print('Computed Total: $totalAmount'); // Print the computed total
      });
    } catch (e) {
      print(
          'Error fetching or computing total: $e'); // Catch and print any errors
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndComputeTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 900, // Adjust the height
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bghomepage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Logo on the left
                        Image.asset(
                          'assets/logoweb.png', // Replace with your logo asset
                          height: 50,
                        ),

                        // Center menu items
                        Row(
                          children: [
                            _navItem(
                              'Home',
                            ),
                            const SizedBox(width: 30),
                            _navItem('Our Units'),
                            const SizedBox(width: 30),
                            _navItem('Our Location'),
                          ],
                        ),

                        // Contact on the right
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                Text(
                                  '0917-467-5856',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: 800,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centers the content vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Centers the content horizontally
                        children: [
                          const Text(
                            'Bogs and Mila:\nAffordable Rentals, Convenient Location.',
                            textAlign: TextAlign
                                .center, // Ensures text is centered within its own box
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Find your perfect home at Bogs and Mila Living.',
                            textAlign: TextAlign
                                .center, // Ensures text is centered within its own box
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xdd4D82D2),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                      0x661E1E1E), // Shadow color (#1E1E1E66)
                                  offset: Offset(
                                      0, 2), // Horizontal and vertical offsets
                                  blurRadius: 10.0, // Softness of the shadow
                                  spreadRadius: 1.0, // Spread of the shadow
                                ),
                              ],
                            ),
                            child: TextButton(
                                onPressed: () {},
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Explore Units',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(Icons.subdirectory_arrow_right,
                                        color: Colors.white)
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Stack(
            children: [
              Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centers the content vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Centers the content horizontally
                        children: [
                          const Text(
                            'Discover Our Apartment Buildings',
                            textAlign: TextAlign
                                .center, // Ensures text is centered within its own box
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xdd1E1E1E),
                            ),
                          ),
                          const Text(
                            'Choose the building you like.',
                            textAlign: TextAlign
                                .center, // Ensures text is centered within its own box
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xdd1E1E1E),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xdd1E1E1E),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                      0x661E1E1E), // Shadow color (#1E1E1E66)
                                  offset: Offset(
                                      0, 2), // Horizontal and vertical offsets
                                  blurRadius: 10.0, // Softness of the shadow
                                  spreadRadius: 1.0, // Spread of the shadow
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'See All',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _apartmentBuilding('5,000/unit', 'Building 1'),
                            _apartmentBuilding('4,000/unit', 'Building 2'),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _apartmentBuilding('3,000/unit', 'Building 3'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  SizedBox(
                      height: 2500,
                      child: Stack(
                        children: [
                          Container(
                            height: 1000,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3D3D3D), // Hex color for #3D3D3D
                                  Color(0xFF1E1E1E), // Hex color for #1E1E1E
                                ],
                                stops: [
                                  0.0,
                                  1.0
                                ], // Defines where each color stops
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 80),
                                    width: double.infinity,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Centers the content vertically
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Centers the content horizontally
                                      children: [
                                        Text(
                                          'Why You Have To Choose Us',
                                          textAlign: TextAlign
                                              .center, // Ensures text is centered within its own box
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'We are committed to providing you with the best living experience possible.',
                                          textAlign: TextAlign
                                              .center, // Ensures text is centered within its own box
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _apartmentBuilding(
                                        '5,000/unit', 'Building 1'),
                                    _apartmentBuilding(
                                        '4,000/unit', 'Building 2'),
                                    _apartmentBuilding(
                                        '3,000/unit', 'Building 3'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1500,
                            margin: const EdgeInsets.only(top: 1000),
                            padding: const EdgeInsets.only(top: 500),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 80),
                                    width: double.infinity,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Centers the content vertically
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Centers the content horizontally
                                      children: [
                                        Text(
                                          'Our Next Vacancy',
                                          textAlign: TextAlign
                                              .center, // Ensures text is centered within its own box
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Discover when our next available unit will be ready for you.',
                                          textAlign: TextAlign
                                              .center, // Ensures text is centered within its own box
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Image(
                                        image: AssetImage('assets/cloud1.png')),
                                    Container(
                                      margin: const EdgeInsets.only(top: 100),
                                      child: const Image(
                                          image:
                                              AssetImage('assets/cloud2.png')),
                                    ),
                                    Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Image(
                                            image:
                                                AssetImage('assets/house2.png'),
                                            fit: BoxFit
                                                .cover, // Optional: adjust how the image fits
                                            width:
                                                200, // Optional: set a specific width for the image
                                            height:
                                                200, // Optional: set a specific height for the image
                                          ),
                                          Text(
                                            totalAmount.toString(),
                                            style: const TextStyle(
                                              color: Colors
                                                  .white, // Adjust text color for visibility
                                              fontSize: 50, // Adjust font size
                                              fontWeight: FontWeight
                                                  .bold, // Make text bold
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 80),
                                            child: Text(
                                              'Available Units',
                                              style: const TextStyle(
                                                color: Colors
                                                    .white, // Adjust text color for visibility
                                                fontSize:
                                                    18, // Adjust font size
                                                fontWeight: FontWeight
                                                    .bold, // Make text bold
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 100),
                                      child: const Image(
                                          image:
                                              AssetImage('assets/cloud4.png')),
                                    ),
                                    const Image(
                                        image: AssetImage('assets/cloud3.png')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Image(
                                    image: AssetImage('assets/banner.png')),
                              ],
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height / 1.5,
                            left: MediaQuery.of(context).size.width / 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 80, horizontal: 100),
                              height: 800,
                              width: MediaQuery.of(context).size.width / 1.5,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(26, 72, 72,
                                        72), // Shadow color (#1E1E1E66)
                                    offset: Offset(0,
                                        2), // Horizontal and vertical offsets
                                    blurRadius: 10.0, // Softness of the shadow
                                    spreadRadius: 5.0, // Spread of the shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Centers the content vertically
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Centers the content horizontally
                                children: [
                                  const Text(
                                    'Discover Our Location',
                                    textAlign: TextAlign
                                        .center, // Ensures text is centered within its own box
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xdd1E1E1E),
                                    ),
                                  ),
                                  const Text(
                                    'Discover where we are, and let us answer all of your personal inquiries.',
                                    textAlign: TextAlign
                                        .center, // Ensures text is centered within its own box
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xdd1E1E1E),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xdd1E1E1E),
                                      ),
                                      child: const Image(
                                          image: AssetImage('assets/map.png'))),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    width: 200,
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xdd1E1E1E),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                              0x661E1E1E), // Shadow color (#1E1E1E66)
                                          offset: Offset(0,
                                              2), // Horizontal and vertical offsets
                                          blurRadius:
                                              10.0, // Softness of the shadow
                                          spreadRadius:
                                              1.0, // Spread of the shadow
                                        ),
                                      ],
                                    ),
                                    child: TextButton(
                                        onPressed: () {},
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View Google Map',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Icon(Icons.subdirectory_arrow_right,
                                                color: Colors.white)
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              )
            ],
          ),
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3D3D3D), // Hex color for #3D3D3D
                    Color(0xFF1E1E1E), // Hex color for #1E1E1E
                  ],
                  stops: [0.0, 1.0], // Defines where each color stops
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/logoweb.png', // Replace with your logo asset
                            height: 50,
                          ),
                          const SizedBox(height: 10),
                          _footerText(
                              'Affordable Rentals, Convenient Location.'),
                          const SizedBox(height: 10),
                          _footerText(''),
                          const SizedBox(height: 10),
                          _footerText('')
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _footerTextTitle('Our Links'),
                          const SizedBox(height: 10),
                          _footerText('Home'),
                          const SizedBox(height: 10),
                          _footerText('Our Units'),
                          const SizedBox(height: 10),
                          _footerText('Our Location')
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _footerTextTitle('Our Contact'),
                          const SizedBox(height: 10),
                          _footerText('0917-467-5856'),
                          const SizedBox(height: 10),
                          _footerText(''),
                          const SizedBox(height: 10),
                          _footerText('')
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _footerTextTitle('Google Map'),
                          const SizedBox(height: 10),
                          _footerText('Bogs and Mila’s Address'),
                          const SizedBox(height: 10),
                          _footerText(''),
                          const SizedBox(height: 10),
                          _footerText('')
                        ],
                      )
                    ],
                  ),
                ],
              )),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3D3D3D), // Hex color for #3D3D3D
                  Color(0xFF1E1E1E), // Hex color for #1E1E1E
                ],
                stops: [0.0, 1.0], // Defines where each color stops
              ),
              border: Border(
                  top: BorderSide(
                color: Colors.white, // White border at the top
                width: 1, // Border thickness
              )),
            ),
            child: const Text(
              'Copyright © Bogs and Mila Apartment. All Rights Reserved.',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  // Function to create navigation items
  Widget _navItem(String title) {
    return GestureDetector(
      onTap: () {
        // Handle navigation here
      },
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _apartmentBuilding(String price, String name) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width / 3.2,
      color: const Color.fromARGB(255, 221, 221, 221),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(236, 173, 173, 173),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x661E1E1E), // Shadow color (#1E1E1E66)
                      offset: Offset(0, 2), // Horizontal and vertical offsets
                      blurRadius: 4.0, // Softness of the shadow
                      spreadRadius: 1.0, // Spread of the shadow
                    ),
                  ],
                ),
                child: Text(
                  price,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width / 3.2,
            height: 50,
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(236, 173, 173, 173),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x661E1E1E), // Shadow color (#1E1E1E66)
                    offset: Offset(0, 2), // Horizontal and vertical offsets
                    blurRadius: 4.0, // Softness of the shadow
                    spreadRadius: 1.0, // Spread of the shadow
                  ),
                ],
              ),
              child: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _footerTextTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
    );
  }

  _footerText(String label) {
    return Text(
      label,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}
