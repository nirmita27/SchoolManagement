import 'package:flutter/material.dart';

class DocumentationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Documentation'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('About the Project'),
            _buildFeatureDescription(
              'The School Management System is a comprehensive tool designed to streamline the operations of a school. It provides an integrated platform for managing student records, staff information, finances, and daily activities. The system supports multiple user roles including admin, teacher, and accountant, each with specific permissions and capabilities to perform their respective tasks efficiently.',
              Icons.info,
              'assets/about_project.png',
            ),
            _buildSectionTitle('Login and Sign Up'),
            _buildFeatureDescription(
              'Secure and user-friendly login and sign-up processes ensure that only authorized users can access the system. Teachers and accountants need to be approved by the admin before their accounts become active, adding an extra layer of security.',
              Icons.login,
              'assets/login_signup.png',
            ),
            _buildSectionTitle('Admin Dashboard'),
            _buildFeatureDescription(
              'The admin dashboard provides a high-level overview of the school\'s operations. It includes summary cards displaying the total number of students, staff, and classes. Interactive charts show the distribution of students across different classes and the distribution of staff by department. Recent expenditures and fee records are also displayed for quick access.',
              Icons.dashboard,
              'assets/admin_dashboard.png',
            ),
            _buildSectionTitle('Admissions'),
            _buildFeatureDescription(
              'The admissions module allows admins to manage the entire student enrollment process. This includes tracking application statuses, approving or rejecting applications, and enrolling new students. It ensures that the admissions process is organized and efficient.',
              Icons.how_to_reg,
              'assets/admissions.png',
            ),
            _buildSectionTitle('Fees Management'),
            _buildFeatureDescription(
              'The fees management module helps track all student fee payments. Admins and accountants can generate invoices, record payments, and manage outstanding balances. This module ensures transparency and accuracy in fee collection and management.',
              Icons.attach_money,
              'assets/fees_management.png',
            ),
            _buildSectionTitle('Expenditures'),
            _buildFeatureDescription(
              'Tracking school expenditures is crucial for financial management. This module records all expenses incurred by the school, categorizes them, and provides detailed reports. It helps in budgeting and financial planning by providing insights into spending patterns.',
              Icons.money_off,
              'assets/expenditures.png',
            ),
            _buildSectionTitle('Academic Calendar'),
            _buildFeatureDescription(
              'The academic calendar module allows admins and teachers to plan and schedule important events, holidays, and academic activities for the school year. It ensures that everyone is aware of the schedule and can plan accordingly.',
              Icons.calendar_today,
              'assets/academic_calendar.png',
            ),
            _buildSectionTitle('Approval Screen'),
            _buildFeatureDescription(
              'This screen is used by admins to approve or reject login requests from teachers and accountants. It ensures that only verified users can access the system, maintaining the security and integrity of the school\'s data.',
              Icons.approval,
              'assets/approval_screen.png',
            ),
            _buildSectionTitle('Notifications'),
            _buildFeatureDescription(
              'The notifications module allows admins to send important announcements and updates to teachers, accountants, or specific users. Notifications are categorized by date for easy tracking and retrieval.',
              Icons.notifications,
              'assets/notifications.png',
            ),
            _buildSectionTitle('Library Management'),
            _buildFeatureDescription(
              'The library management module helps in organizing and managing the school library. It tracks book inventories, checkouts, and returns, ensuring that the library operates smoothly and efficiently.',
              Icons.library_books,
              'assets/library_management.png',
            ),
            _buildSectionTitle('Student List'),
            _buildFeatureDescription(
              'This module provides a comprehensive list of all students. It includes detailed information such as student names, classes, and contact details. The list can be sorted and filtered for easy navigation.',
              Icons.people,
              'assets/student_list.png',
            ),
            _buildSectionTitle('Transport Management'),
            _buildFeatureDescription(
              'Managing student transportation is made easy with this module. It includes details about bus routes, stops, and vehicle assignments. It ensures that students are transported safely and efficiently.',
              Icons.directions_bus,
              'assets/transport_management.png',
            ),
            _buildSectionTitle('I-Card Management'),
            _buildFeatureDescription(
              'The I-Card management module generates and manages student ID cards. These cards are crucial for identifying students and ensuring security within the school premises.',
              Icons.badge,
              'assets/icard_management.png',
            ),
            _buildSectionTitle('Stock Management'),
            _buildFeatureDescription(
              'This module helps in tracking and managing school inventories such as stationery, books, and other supplies. It ensures that the school has the necessary resources available at all times.',
              Icons.store,
              'assets/stock_management.png',
            ),
            _buildSectionTitle('Subject Management'),
            _buildFeatureDescription(
              'Admins and teachers can manage subjects, assign teachers to classes, and organize the curriculum. This module ensures that the academic structure is well-organized and aligned with the school\'s educational goals.',
              Icons.subject,
              'assets/subject_management.png',
            ),
            _buildSectionTitle('Class Management'),
            _buildFeatureDescription(
              'Class management involves creating and managing class schedules, assigning teachers, and ensuring that classrooms are utilized effectively. This module helps in maintaining an organized and efficient academic environment.',
              Icons.class_,
              'assets/class_management.png',
            ),
            _buildSectionTitle('Staff Management'),
            _buildFeatureDescription(
              'This module manages staff details including their roles, schedules, and contact information. It ensures that the school\'s administrative and teaching staff are well-organized and their information is easily accessible.',
              Icons.work,
              'assets/staff_management.png',
            ),
            _buildSectionTitle('Reception Management'),
            _buildFeatureDescription(
              'The reception management module oversees all activities related to the school\'s reception area. This includes managing visitor logs, scheduling appointments, and ensuring a smooth flow of information.',
              Icons.room_service,
              'assets/reception_management.png',
            ),
            _buildSectionTitle('Leave Management'),
            _buildFeatureDescription(
              'Managing leave requests from staff is crucial for maintaining productivity. This module allows staff to request leave and ensures that all leave requests are properly approved and recorded.',
              Icons.calendar_today,
              'assets/leave_management.png',
            ),
            _buildSectionTitle('Appointments & Messaging'),
            _buildFeatureDescription(
              'This module facilitates the scheduling of appointments and internal messaging between staff members. It ensures effective communication and coordination within the school.',
              Icons.schedule,
              'assets/appointments_messaging.png',
            ),
            _buildSectionTitle('Examination And Results'),
            _buildFeatureDescription(
              'Managing examinations and recording student results are key functions of any school. This module allows admins and teachers to schedule exams, record results, and generate report cards.',
              Icons.assignment,
              'assets/examination_results.png',
            ),
            _buildSectionTitle('Teacher Dashboard'),
            _buildFeatureDescription(
              'The teacher dashboard provides an overview of the teacher\'s responsibilities. It includes access to student lists, class schedules, academic calendars, and subject management. Teachers can also view and manage their own schedules and communicate with other staff members.',
              Icons.dashboard,
              'assets/teacher_dashboard.png',
            ),
            _buildSectionTitle('Accountant Dashboard'),
            _buildFeatureDescription(
              'The accountant dashboard offers tools for managing the school\'s finances. This includes tracking fees, expenditures, and generating financial reports. Accountants can ensure that all financial transactions are accurately recorded and managed.',
              Icons.dashboard,
              'assets/accountant_dashboard.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildFeatureDescription(String description, IconData icon, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.blueAccent),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Image.asset(imagePath),
          ],
        ),
      ),
    );
  }
}
