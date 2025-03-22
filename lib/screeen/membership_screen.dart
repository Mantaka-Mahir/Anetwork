import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MembershipScreen(),
    );
  }
}

class MembershipScreen extends StatelessWidget {
  final List<MembershipPlan> plans = [
    MembershipPlan(
      name: 'DAY PASS',
      icon: Icons.wb_sunny_outlined,
      timeRange: '10am - 4pm',
      price: 460,
      backgroundImage: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
      amenities: [
        '6 hours of access to the open coworking space',
        'Dedicated prayer corner',
        'Access to Cafe for non-fasting people',
        'Access to stationery, whiteboards & up to 5 prints',
        'Productivity tracking monitored by the AN team',
      ],
    ),
    MembershipPlan(
      name: 'IFTAR CIRCLE',
      icon: Icons.restaurant_menu,
      timeRange: '4pm - 10pm',
      price: 1000,
      backgroundImage: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8',
      amenities: [
        'Life-Sized Board Games',
        'Fun, conversational activities',
        'Iftar-themed challenges',
        'Homecooked Gourmet Food',
        'Open, inclusive community experience',
        'Dedicated prayer corner',
      ],
    ),
    MembershipPlan(
      name: 'MONTHLY PASS',
      icon: Icons.calendar_today,
      timeRange: 'Unlimited access',
      price: 12000,
      backgroundImage: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c',
      amenities: [
        'Access to coworking space all month',
        'High-speed internet',
        'Dedicated workspace',
        'Meeting room access',
        'Unlimited coffee & tea',
        'Exclusive events & networking',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Membership Plans',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembershipDetailScreen(plan: plans[index]),
                  ),
                );
              },
              child: MembershipCard(plan: plans[index]),
            );
          },
        ),
      ),
    );
  }
}

class MembershipCard extends StatelessWidget {
  final MembershipPlan plan;

  const MembershipCard({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'membership-${plan.name}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  plan.backgroundImage,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(plan.icon, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plan.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          plan.timeRange,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '৳ ${plan.price}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MembershipDetailScreen extends StatelessWidget {
  final MembershipPlan plan;

  const MembershipDetailScreen({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(plan.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'membership-${plan.name}',
              child: Image.network(
                plan.backgroundImage,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    plan.timeRange,
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '৳ ${plan.price}',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Amenities:', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ...plan.amenities.map((amenity) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $amenity', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MembershipPlan {
  final String name;
  final IconData icon;
  final String timeRange;
  final int price;
  final String backgroundImage;
  final List<String> amenities;

  MembershipPlan({
    required this.name,
    required this.icon,
    required this.timeRange,
    required this.price,
    required this.backgroundImage,
    required this.amenities,
  });
}
