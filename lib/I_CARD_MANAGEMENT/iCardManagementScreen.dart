import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'StudentICardScreen.dart';

class ICardManagementScreen extends StatefulWidget {

  final String schoolRange;

  ICardManagementScreen({required this.schoolRange});

  @override
  State<ICardManagementScreen> createState() => _ICardManagementScreenState();
}

class _ICardManagementScreenState extends State<ICardManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I-CARD MANAGEMENT'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MODULES',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black26,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ModuleButton(
                title: 'Student I-Card',
                icon: Icons.school,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentICardScreen(schoolRange: widget.schoolRange,)),
                ), schoolRange: widget.schoolRange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModuleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final String schoolRange;

  const ModuleButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.schoolRange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => StudentICardScreen(schoolRange: schoolRange,),
      closedElevation: 10,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      closedColor: Colors.white,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
          width: 300,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.blueAccent),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
