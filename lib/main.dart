import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Models
class Doctor {
  final String name;
  final String specialty;
  final String imageAsset;
  final double rating;
  final int reviews;

  Doctor({
    required this.name,
    required this.specialty,
    required this.imageAsset,
    required this.rating,
    required this.reviews,
  });
}

class MedicalCenter {
  final String name;
  final String imageAsset;
  final double rating;
  final int reviews;
  final String distance;

  MedicalCenter({
    required this.name,
    required this.imageAsset,
    required this.rating,
    required this.reviews,
    required this.distance,
  });
}

// Providers
final doctorsProvider = StateNotifierProvider<DoctorsNotifier, List<Doctor>>((ref) {
  return DoctorsNotifier();
});

final medicalCentersProvider = Provider<List<MedicalCenter>>((ref) {
  // Mock data for medical centers
  return [
    MedicalCenter(
      name: 'Sunrise Health Clinic',
      imageAsset: 'assets/images/f213d7dbdf0e01693c868dd621270fcb.jpg',
      rating: 4.8,
      reviews: 128,
      distance: '1.2 km',
    ),
    MedicalCenter(
      name: 'Golden Care Center',
      imageAsset: 'assets/images/edb80c5d0e9f43d9cc9e7c48030fa945.jpg',
      rating: 4.6,
      reviews: 96,
      distance: '2.5 km',
    ),
  ];
});

class DoctorsNotifier extends StateNotifier<List<Doctor>> {
  List<Doctor> _allDoctors = [];

  DoctorsNotifier() : super([]);

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/doctors'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _allDoctors = (data['doctors'] as List).map((doctorData) => Doctor(
          name: doctorData['name'],
          specialty: doctorData['specialty'],
          imageAsset: doctorData['imageAsset'],
          rating: doctorData['rating'].toDouble(),
          reviews: doctorData['reviews'],
        )).toList();
        state = _allDoctors;
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      print(e);
      // Mock data in case of error
      _allDoctors = [
        Doctor(name: 'Dr. David Patel', specialty: 'Cardiologist', imageAsset: 'assets/images/bffb300537aa46caf4c65351a0a20dde.png', rating: 4.9, reviews: 125),
        Doctor(name: 'Dr. Jessica Turner', specialty: 'Dermatologist', imageAsset: 'assets/images/b0db1e98ab7f1a31afba13769f282033.png', rating: 4.8, reviews: 98),
      ];
      state = _allDoctors;
    }
  }

  void searchDoctors(String query) {
    if (query.isEmpty) {
      state = _allDoctors;
    } else {
      state = _allDoctors
          .where((doctor) => doctor.name.toLowerCase().contains(query.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(doctorsProvider.notifier).fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text('Seattle, USA', style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(),
              SizedBox(height: 20),
              Text(
                'Looking for a Specialist Doctor?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CategoryGrid(),
              SizedBox(height: 20),
              Text(
                'Nearby Medical Centers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              MedicalCentersList(),
              SizedBox(height: 20),
              DoctorsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search doctors, specialties...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: (value) {
        ref.read(doctorsProvider.notifier).searchDoctors(value);
      },
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.local_hospital, 'name': 'Surgery', 'color': Colors.green},
    {'icon': Icons.favorite, 'name': 'Cardiology', 'color': Colors.red},
    {'icon': Icons.psychology, 'name': 'Psychiatrist', 'color': Colors.purple},
    {'icon': Icons.medical_services, 'name': 'General', 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              backgroundColor: categories[index]['color'].withOpacity(0.2),
              radius: 30,
              child: Icon(categories[index]['icon'], color: categories[index]['color']),
            ),
            SizedBox(height: 8),
            Text(categories[index]['name'], textAlign: TextAlign.center),
          ],
        );
      },
    );
  }
}

class MedicalCentersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicalCenters = ref.watch(medicalCentersProvider);
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: medicalCenters.length,
        itemBuilder: (context, index) {
          final center = medicalCenters[index];
          return MedicalCenterCard(
            name: center.name,
            imageAsset: center.imageAsset,
            rating: center.rating,
            reviews: center.reviews,
            distance: center.distance,
          );
        },
      ),
    );
  }
}

class MedicalCenterCard extends StatelessWidget {
  final String name;
  final String imageAsset;
  final double rating;
  final int reviews;
  final String distance;

  const MedicalCenterCard({
    Key? key,
    required this.name,
    required this.imageAsset,
    required this.rating,
    required this.reviews,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imageAsset, height: 120, width: 200, fit: BoxFit.cover),
          ),
          SizedBox(height: 8),
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 16),
              Text('$rating ($reviews reviews)'),
              Spacer(),
              Text(distance),
            ],
          ),
        ],
      ),
    );
  }
}

class DoctorsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);

    if (doctors.isEmpty) {
      return Center(child: Text('No doctors found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(doctor.imageAsset),
          ),
          title: Text(doctor.name),
          subtitle: Text(doctor.specialty),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  Text('${doctor.rating}'),
                ],
              ),
              Text('${doctor.reviews} reviews'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailPage(doctor: doctor),
              ),
            );
          },
        );
      },
    );
  }
}

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${doctor.name} Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(doctor.imageAsset),
                ),
              ),
              SizedBox(height: 20),
              Text(
                doctor.name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                doctor.specialty,
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 4),
                  Text('${doctor.rating} (${doctor.reviews} reviews)'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'About',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Dr. ${doctor.name} is an experienced ${doctor.specialty} with over 10 years of experience. They specialize in...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Book Appointment'),
                onPressed: () {
                  // Implement appointment booking logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}