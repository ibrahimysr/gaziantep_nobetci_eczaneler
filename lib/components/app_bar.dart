// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String city;
//   final VoidCallback onBack;

//   const CustomAppBar({
//     super.key,
//     required this.city,
//     required this.onBack,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//         onPressed: onBack,
//       ),
//       title: Text(
//         '$city ilçesine göre',
//         style: const TextStyle(
//           color: Colors.black,
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: false,
//       backgroundColor: Colors.white,
//       elevation: 0,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }


import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar( 

      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red,Colors.red.withValues(alpha:0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(Icons.medical_services,color: Colors.white,size: 30,),
          // child: CircleAvatar(
          //   backgroundColor: Colors.white,
          //   radius: 18,
          //   child: Lottie.asset(
          //     AppAssets.loginAnimation,
          //     width: 30,
          //     height: 30,
          //   ),
          // ),
        ),
      ],
      centerTitle: true,
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          widget.title,
          style:TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 




