// lib/models/doctor_model.dart  ·  PATIENT APP
//
// Maps to the 'doctors' collection in Firestore.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class fetchDoctorModel {
  final String drId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String specialty;
  final String subSpecialty;
  final String professionalBio;
  final String? profileImageUrl;
  final String hospitalName;
  final String address;
  final String city;
  final String stateZip;
  final String medicalLicense;
  final int    yearsOfExperience;
  final double consultationFee;
  final double rating;
  final int    totalReviews;
  final int    totalAppointments;
  final bool   isVerified;
  final bool   isOnline;
  final DateTime? createdAt;

  const fetchDoctorModel({
    required this.drId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.subSpecialty,
    required this.professionalBio,
    this.profileImageUrl,
    required this.hospitalName,
    required this.address,
    required this.city,
    required this.stateZip,
    required this.medicalLicense,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.rating,
    required this.totalReviews,
    required this.totalAppointments,
    required this.isVerified,
    required this.isOnline,
    this.createdAt,
  });

  // ── Convenience getters ────────────────────────────────────────────────────
  String get displayName => 'Dr. $firstName $lastName';
  String get fullName    => '$firstName $lastName';

  // ── fromFirestore ──────────────────────────────────────────────────────────
  factory fetchDoctorModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return fetchDoctorModel(
      drId:             d['drId']             as String? ?? doc.id,
      firstName:        d['firstName']        as String? ?? '',
      lastName:         d['lastName']         as String? ?? '',
      email:            d['email']            as String? ?? '',
      phone:            d['phone']            as String? ?? '',
      specialty:        d['specialty']        as String? ?? 'General',
      subSpecialty:     d['subSpecialty']     as String? ?? '',
      professionalBio:  d['professionalBio']  as String? ?? '',
      profileImageUrl:  d['profileImageUrl']  as String?,
      hospitalName:     d['hospitalName']     as String? ?? '',
      address:          d['address']          as String? ?? '',
      city:             d['city']             as String? ?? '',
      stateZip:         d['stateZip']         as String? ?? '',
      medicalLicense:   d['medicalLicense']   as String? ?? '',
      yearsOfExperience: (d['yearsOfExperience'] as num?)?.toInt()    ?? 0,
      consultationFee:   (d['consultationFee']   as num?)?.toDouble() ?? 0.0,
      rating:            (d['rating']            as num?)?.toDouble() ?? 0.0,
      totalReviews:      (d['totalReviews']      as num?)?.toInt()    ?? 0,
      totalAppointments: (d['totalAppointments'] as num?)?.toInt()    ?? 0,
      isVerified:        d['isVerified'] as bool? ?? false,
      isOnline:          d['isOnline']   as bool? ?? false,
      createdAt:         _ts(d['createdAt']),
    );
  }

  static DateTime? _ts(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    if (v is String && v.isNotEmpty) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is fetchDoctorModel && other.drId == drId;

  @override
  int get hashCode => drId.hashCode;
}