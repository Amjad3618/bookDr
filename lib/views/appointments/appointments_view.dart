import 'package:flutter/material.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  String selectedTab = 'Upcoming';

  final List<Map<String, dynamic>> appointments = [
    {
      'doctorName': 'Dr. Anastasia Moreno',
      'specialty': 'Cardiologist',
      'date': 'March 25, 2025',
      'time': '10:30 AM',
      'status': 'Confirmed',
      'type': 'In-clinic',
      'image': 'assets/dr1.jpg',
      'location': 'Medical Center, Suite 105',
      'notes': 'Regular checkup',
    },
    {
      'doctorName': 'Dr. James Wilson',
      'specialty': 'Neurologist',
      'date': 'March 28, 2025',
      'time': '2:00 PM',
      'status': 'Pending',
      'type': 'Video Call',
      'image': 'assets/dr1.jpg',
      'location': 'Virtual Consultation',
      'notes': 'Headache consultation',
    },
    {
      'doctorName': 'Dr. Sarah Johnson',
      'specialty': 'Dermatologist',
      'date': 'April 5, 2025',
      'time': '4:15 PM',
      'status': 'Confirmed',
      'type': 'In-clinic',
      'image': 'assets/dr3.jfif',
      'location': 'Skin Care Clinic, Floor 2',
      'notes': 'Skin treatment follow-up',
    },
  ];

  final List<Map<String, dynamic>> completedAppointments = [
    {
      'doctorName': 'Dr. Michael Chen',
      'specialty': 'Orthopedist',
      'date': 'March 10, 2025',
      'time': '11:00 AM',
      'status': 'Completed',
      'type': 'In-clinic',
      'image': 'assets/dr1.jpg',
      'location': 'Orthopedic Center',
      'notes': 'Knee examination',
    },
    {
      'doctorName': 'Dr. Emily Davis',
      'specialty': 'Pediatrician',
      'date': 'February 28, 2025',
      'time': '9:30 AM',
      'status': 'Completed',
      'type': 'In-clinic',
      'image': 'assets/dr1.jpg',
      'location': 'Children\'s Hospital',
      'notes': 'Vaccination appointment',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Appointments',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your medical consultations',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabButton('Upcoming', 'Upcoming'),
                  const SizedBox(width: 12),
                  _buildTabButton('Completed', 'Completed'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Appointments List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (selectedTab == 'Upcoming')
                    ...appointments.map((apt) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAppointmentCard(apt, context),
                    )),
                  if (selectedTab == 'Completed')
                    ...completedAppointments.map((apt) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAppointmentCard(apt, context),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    bool isActive = selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, BuildContext context) {
    final Color statusColor = _getStatusColor(apt['status']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(apt['image']),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt['doctorName'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        apt['specialty'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          apt['status'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu Button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
          // Appointment Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Date & Time',
                  value: '${apt['date']} at ${apt['time']}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  icon: apt['type'] == 'Video Call'
                      ? Icons.videocam
                      : Icons.location_on,
                  label: apt['type'] == 'Video Call' ? 'Consultation' : 'Location',
                  value: apt['location'],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  icon: Icons.notes,
                  label: 'Notes',
                  value: apt['notes'],
                ),
              ],
            ),
          ),
          // Action Buttons
          if (apt['status'] == 'Confirmed' || apt['status'] == 'Pending')
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Reschedule',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 4,
                      ),
                      child: Text(
                        apt['type'] == 'Video Call'
                            ? 'Join Call'
                            : 'View Details',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 4,
                  ),
                  child: Text(
                    'Book Again',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}