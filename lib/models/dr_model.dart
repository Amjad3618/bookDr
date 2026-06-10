// lib/models/dr_model.dart  ·  PATIENT APP
//
// Matches the doctor app's exact Firestore schema.
// No status field — every gig in the collection is live.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GIG PACKAGE
// ══════════════════════════════════════════════════════════════════════════════

class GigPackage {
  final String       name;
  final String       description;
  final double       price;
  final String       deliveryTime;
  final String       revisions;
  final List<String> features;

  const GigPackage({
    required this.name,
    required this.description,
    required this.price,
    required this.deliveryTime,
    required this.revisions,
    required this.features,
  });

  factory GigPackage.fromMap(Map<String, dynamic> m) => GigPackage(
    name:         m['name']         as String? ?? '',
    description:  m['description']  as String? ?? '',
    price:        (m['price']       as num?)?.toDouble() ?? 0.0,
    deliveryTime: m['deliveryTime'] as String? ?? '',
    revisions:    m['revisions']    as String? ?? '',
    features:     List<String>.from(m['features'] as List? ?? []),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// GIG FAQ
// ══════════════════════════════════════════════════════════════════════════════

class GigFaq {
  final String question;
  final String answer;

  const GigFaq({required this.question, required this.answer});

  factory GigFaq.fromMap(Map<String, dynamic> m) => GigFaq(
    question: m['question'] as String? ?? '',
    answer:   m['answer']   as String? ?? '',
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// GIG MODEL
// ══════════════════════════════════════════════════════════════════════════════

class GigModel {
  final String gigId;
  final String drId;

  final String drName;
  final String drSpecialty;
  final String drImageUrl;
  final double drRating;
  final bool   drIsVerified;

  final String       title;
  final String       description;
  final String       category;
  final String       subcategory;
  final List<String> tags;
  final String       consultationTypeStr;
  final String       requirements;
  final List<GigFaq> faqs;

  final GigPackage basicPackage;
  final GigPackage standardPackage;
  final GigPackage premiumPackage;

  final String       coverImageUrl;
  final List<String> galleryImageUrls;
  final String?      introVideoUrl;

  final bool hasPmdcUploaded;
  final bool hasDegreeUploaded;

  final bool   isFeatured;
  final double rating;
  final int    totalReviews;
  final int    totalOrders;
  final int    totalViews;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;

  const GigModel({
    required this.gigId,
    required this.drId,
    required this.drName,
    required this.drSpecialty,
    required this.drImageUrl,
    required this.drRating,
    required this.drIsVerified,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.tags,
    required this.consultationTypeStr,
    required this.requirements,
    required this.faqs,
    required this.basicPackage,
    required this.standardPackage,
    required this.premiumPackage,
    required this.coverImageUrl,
    required this.galleryImageUrls,
    this.introVideoUrl,
    required this.hasPmdcUploaded,
    required this.hasDegreeUploaded,
    required this.isFeatured,
    required this.rating,
    required this.totalReviews,
    required this.totalOrders,
    required this.totalViews,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  double get startingPrice => basicPackage.price;
  String get fullTitle     => 'I will ${title.trim()}';

  factory GigModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    GigPackage _pkg(String key) {
      final raw = d[key];
      if (raw == null || raw is! Map) return GigPackage.fromMap({});
      return GigPackage.fromMap(Map<String, dynamic>.from(raw as Map));
    }

    List<GigFaq> _parseFaqs() {
      final raw = d['faqs'];
      if (raw == null || raw is! List) return [];
      return (raw as List)
          .whereType<Map>()
          .map((e) => GigFaq.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return GigModel(
      gigId:               d['gigId']        as String? ?? doc.id,
      drId:                d['drId']         as String? ?? '',
      drName:              d['drName']       as String? ?? '',
      drSpecialty:         d['drSpecialty']  as String? ?? '',
      drImageUrl:          d['drImageUrl']   as String? ?? '',
      drRating:            (d['drRating']    as num?)?.toDouble()  ?? 0.0,
      drIsVerified:        d['drIsVerified'] as bool?   ?? false,
      title:               d['title']        as String? ?? '',
      description:         d['description']  as String? ?? '',
      category:            d['category']     as String? ?? '',
      subcategory:         d['subcategory']  as String? ?? '',
      tags:                List<String>.from(d['tags']  as List? ?? []),
      consultationTypeStr: d['consultationTypeStr'] as String? ?? '',
      requirements:        d['requirements'] as String? ?? '',
      faqs:                _parseFaqs(),
      basicPackage:        _pkg('basicPackage'),
      standardPackage:     _pkg('standardPackage'),
      premiumPackage:      _pkg('premiumPackage'),
      coverImageUrl:       d['coverImageUrl']    as String? ?? '',
      galleryImageUrls:    List<String>.from(d['galleryImageUrls'] as List? ?? []),
      introVideoUrl:       d['introVideoUrl']    as String?,
      hasPmdcUploaded:     d['hasPmdcUploaded']  as bool? ?? false,
      hasDegreeUploaded:   d['hasDegreeUploaded'] as bool? ?? false,
      isFeatured:    d['isFeatured']    as bool? ?? false,
      rating:        (d['rating']       as num?)?.toDouble() ?? 0.0,
      totalReviews:  (d['totalReviews'] as num?)?.toInt()   ?? 0,
      totalOrders:   (d['totalOrders']  as num?)?.toInt()   ?? 0,
      totalViews:    (d['totalViews']   as num?)?.toInt()   ?? 0,
      createdAt:     _ts(d['createdAt']),
      updatedAt:     _ts(d['updatedAt']),
      publishedAt:   _ts(d['publishedAt']),
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
      identical(this, other) || other is GigModel && other.gigId == gigId;

  @override
  int get hashCode => gigId.hashCode;
}

// ══════════════════════════════════════════════════════════════════════════════
// PATIENT MODEL
// Collection: 'patients'
// Firestore fields saved by patient_auth_service.dart:
//   'name'             → fullName
//   'profileImageUrl'  → imageUrl
// ══════════════════════════════════════════════════════════════════════════════

class PatientModel {
  final String  uid;
  final String  fullName;
  final String  email;
  final String? phone;
  final String? imageUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? bloodGroup;
  final int     totalOrders;
  final DateTime? createdAt;

  const PatientModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
    this.imageUrl,
    this.gender,
    this.dateOfBirth,
    this.bloodGroup,
    this.totalOrders = 0,
    this.createdAt,
  });

  // First name for greeting in header
  String get firstName {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PatientModel(
      uid:      doc.id,
      // 'name' is what patient_auth_service saves; 'fullName' is the fallback
      fullName: (d['name'] ?? d['fullName'] ?? 'Patient') as String,
      email:    d['email']       as String? ?? '',
      phone:    d['phone']       as String?,
      // 'profileImageUrl' is what patient_auth_service saves; 'imageUrl' is fallback
      imageUrl: (d['profileImageUrl'] ?? d['imageUrl']) as String?,
      gender:      d['gender']      as String?,
      dateOfBirth: d['dateOfBirth'] as String?,
      bloodGroup:  d['bloodGroup']  as String?,
      totalOrders: (d['totalOrders'] as num?)?.toInt() ?? 0,
      createdAt:   _tsP(d['createdAt']),
    );
  }

  static DateTime? _tsP(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    if (v is String && v.isNotEmpty) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }
}