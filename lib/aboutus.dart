import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: _animation,
              child: _buildHeader(),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: _buildPrincipalSection(),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: _buildSchoolDetailsSection(),
            ),
            // SizedBox(height: 20),
            // Text(
            //   'Our Mission',
            //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 10),
            // _buildFeatureCard(
            //   icon: Icons.school,
            //   title: 'Our Mission',
            //   description:
            //   'Welcome to महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०), we are dedicated to fostering a nurturing and stimulating environment where every student can thrive academically, socially, and emotionally. Our mission is to cultivate a love of learning and empower our students to become confident, responsible, and compassionate members of society.',
            // ),
            SizedBox(height: 20),
            _buildTeamSection(),
            SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'schoolLogo',
            child: Image.asset(
              'assets/school_logo.jpeg',
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipalSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/principal.jpg'),
        ),
        SizedBox(height: 20),
        Text(
          'Principal\'s Message',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Our Principal, [Name], is dedicated to creating an environment where students excel and grow. With a vision for holistic education and a passion for teaching, our principal leads the school towards academic and personal excellence.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSchoolDetailsSection() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.school,
          title: 'Our Mission',
          description:
          'Welcome to महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०)! Here, we are committed to creating a nurturing and stimulating environment where every student can flourish academically, socially, and emotionally. Our mission is to inspire a love for learning and empower our students to grow into confident, responsible, and compassionate individuals.',
        ),
        SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.star,
          title: 'Our Vision',
          description:
          'Thoughts and ideas have the power to change the world. We believe that every student brings unique insights and perspectives. At our school, students have the freedom to express their thoughts creatively and share knowledge openly with one another. We aim to be a community that inspires students to reach their full potential and become lifelong learners. Our approach to education balances academic excellence with personal growth, ensuring a well-rounded and fulfilling learning experience for all.',
        ),
        SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.group,
          title: 'Our Values',
          description:
          'We promote honesty and strong moral principles to ensure integrity among the students. We encourage respect for self, others, and our environment. We believe in the power of working together to achieve common goals and ensure collaboration. Teamwork also encourages coordination between students. We celebrate diversity and ensure an inclusive environment for all.',
        ),
        SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.location_on,
          title: 'Our Programs',
          description:
          'Our school also offers a variety of extra-curricular activities. We encourage students to explore their interests in art and music, participate in physical education and sports, and get involved in social and environmental initiatives. From creative arts to sports and community projects like plantation drives, there is something for everyone to enjoy and learn from.',
        ),
        SizedBox(height: 20),
        _buildFeatureCard(
          icon: Icons.location_on,
          title: 'Join Us',
          description:
          'We warmly invite you to explore our school and meet our dedicated educators. See for yourself the incredible opportunities we provide. Whether you are a prospective student, parent, or educator, we welcome you to become a part of the महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०) family.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.deepPurpleAccent),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Column(
      children: [
        // Text(
        //   'Our Team',
        //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        // ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTeamMemberCard(
              name: 'Jacke Masito',
              role: 'Principal',
              imagePath: 'assets/teacher1.jpg',
              socialLinks: ['facebook', 'twitter', 'google', 'linkedin'],
            ),
            _buildTeamMemberCard(
              name: 'Clark Malik',
              role: 'Teacher',
              imagePath: 'assets/teacher2.jpg',
              socialLinks: ['facebook', 'twitter', 'google', 'linkedin'],
            ),
            _buildTeamMemberCard(
              name: 'John Doe',
              role: 'Teacher',
              imagePath: 'assets/teacher3.jpg',
              socialLinks: ['facebook', 'twitter', 'google', 'linkedin'],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard({required String name, required String role, required String imagePath, required List<String> socialLinks}) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                role,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: socialLinks.map((link) {
                  IconData icon;
                  switch (link) {
                    case 'facebook':
                      icon = Icons.facebook;
                      break;
                    default:
                      icon = Icons.error;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(icon, color: Colors.deepPurpleAccent, size: 20),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.blueGrey[900],
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterSection(
                title: 'महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०)',
                items: [' '],
              ),
              _buildFooterSection(
                title: 'COMPANY',
                items: ['About Us', 'Our Teacher', 'Contact', 'Blog'],
              ),
              _buildFooterSection(
                title: 'SUPPORT',
                items: ['Forums', 'Documentation', 'Language', 'Release Status'],
              ),
              _buildFooterSection(
                title: 'CONTACT US',
                items: ['Phone: +1234567890', 'info@ourschool.com', '123 School Avenue, City, Country'],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '© 2024 | All Rights Reserved.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection({required String title, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            item,
            style: TextStyle(color: Colors.white70),
          ),
        )),
      ],
    );
  }
}