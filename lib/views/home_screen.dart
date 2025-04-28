import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.question_answer_sharp, color: Colors.black),
            onPressed: () {
            },
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications, color: Colors.black)),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services,
                    color: Colors.redAccent.shade700, size: 40),
                SizedBox(
                  width: 20,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  'Gaziantep Nöbetçi \n Eczaneler',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
         HomeContainer(icon: Icons.menu, title: "İLÇELERE GÖRE") ,
         HomeContainer(icon: Icons.not_listed_location_sharp, title: "YAKINIMDAKİLER") ,
        ],
      ),
    );
  }
}
 

 class HomeContainer extends StatelessWidget {
  final IconData icon;
  
  final String title; 
  const HomeContainer({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return  Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade700,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(icon,
                                      color: Colors.white, size: 20),
                                )),
                            const SizedBox(width: 20),
                             Text(
                              title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(Icons.navigate_next_outlined,
                                  color: Colors.white, size: 20),
                            )),
                      ),
                    ],
                  ),
                )),
          );
  }
}