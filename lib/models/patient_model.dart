// lib/models/patient_model.dart
// CareSync Patients (bookdr)

import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PATIENT MODEL
// ══════════════════════════════════════════════════════════════════════════════

class PatientModel {
  final String   patientId;
  final String   name;
  final String   email;
  final String   phone;
  final String?  profileImageUrl;

  // Medical info
  final String?  dateOfBirth;     // ISO string 'YYYY-MM-DD'
  final String?  gender;          // 'Male' | 'Female' | 'Other'
  final String?  bloodGroup;      // 'A+' | 'O-' etc.
  final List<String> allergies;
  final List<String> medicalHistory;

  // Location
  final String?  address;
  final String?  city;

  // Wallet / payments
  final double   walletBalance;
  final double   totalSpent;

  // Account
  final bool     isActive;
  final bool     isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PatientModel({
    required this.patientId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.allergies = const [],
    this.medicalHistory = const [],
    this.address,
    this.city,
    required this.walletBalance,
    required this.totalSpent,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Convenience getters ────────────────────────────────────────────────────
  String get firstName => name.trim().split(' ').first;
  String get initials {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty)  return parts[0][0].toUpperCase();
    return 'P';
  }

  // ── fromJson ───────────────────────────────────────────────────────────────
  factory PatientModel.fromJson(Map<String, dynamic> j) => PatientModel(
    patientId:      j['patientId']      ?? '',
    name:           j['name']           ?? '',
    email:          j['email']          ?? '',
    phone:          j['phone']          ?? '',
    profileImageUrl:j['profileImageUrl'],
    dateOfBirth:    j['dateOfBirth'],
    gender:         j['gender'],
    bloodGroup:     j['bloodGroup'],
    allergies:      List<String>.from(j['allergies']      ?? []),
    medicalHistory: List<String>.from(j['medicalHistory'] ?? []),
    address:        j['address'],
    city:           j['city'],
    walletBalance:  (j['walletBalance'] as num?)?.toDouble() ?? 0,
    totalSpent:     (j['totalSpent']    as num?)?.toDouble() ?? 0,
    isActive:       j['isActive']       ?? true,
    isVerified:     j['isVerified']     ?? false,
    createdAt:      _ts(j['createdAt']) ?? DateTime.now(),
    updatedAt:      _ts(j['updatedAt']),
  );

  // ── toJson ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'patientId':       patientId,
    'name':            name,
    'email':           email,
    'phone':           phone,
    'profileImageUrl': profileImageUrl,
    'dateOfBirth':     dateOfBirth,
    'gender':          gender,
    'bloodGroup':      bloodGroup,
    'allergies':       allergies,
    'medicalHistory':  medicalHistory,
    'address':         address,
    'city':            city,
    'walletBalance':   walletBalance,
    'totalSpent':      totalSpent,
    'isActive':        isActive,
    'isVerified':      isVerified,
    'createdAt':       FieldValue.serverTimestamp(),
    'updatedAt':       FieldValue.serverTimestamp(),
  };

  PatientModel copyWith({
    String?  name,         String?  phone,        String?  profileImageUrl,
    String?  dateOfBirth,  String?  gender,        String?  bloodGroup,
    List<String>? allergies,  List<String>? medicalHistory,
    String?  address,      String?  city,
    double?  walletBalance, double? totalSpent,
    bool?    isActive,     bool?    isVerified,
  }) => PatientModel(
    patientId:      patientId,
    name:           name            ?? this.name,
    email:          email,
    phone:          phone           ?? this.phone,
    profileImageUrl:profileImageUrl ?? this.profileImageUrl,
    dateOfBirth:    dateOfBirth     ?? this.dateOfBirth,
    gender:         gender          ?? this.gender,
    bloodGroup:     bloodGroup      ?? this.bloodGroup,
    allergies:      allergies       ?? this.allergies,
    medicalHistory: medicalHistory  ?? this.medicalHistory,
    address:        address         ?? this.address,
    city:           city            ?? this.city,
    walletBalance:  walletBalance   ?? this.walletBalance,
    totalSpent:     totalSpent      ?? this.totalSpent,
    isActive:       isActive        ?? this.isActive,
    isVerified:     isVerified      ?? this.isVerified,
    createdAt:      createdAt,
    updatedAt:      DateTime.now(),
  );

  static DateTime? _ts(dynamic v) {
    if (v == null)      return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    if (v is String)    { try { return DateTime.parse(v); } catch (_) {} }
    return null;
  }
}