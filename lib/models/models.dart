class Member {
  /// Firestore document ID — used to scope payment queries and write updates.
  final String docId;

  final int id;
  final String name;
  final String email;
  final String phone;
  final String membership;
  String status;

  /// ISO-8601 date string "YYYY-MM-DD" (or legacy human-readable).
  final String joinDate;

  /// ISO-8601 date string "YYYY-MM-DD" — the end of the current billing cycle.
  final String expiryDate;

  // Extended fields from the comprehensive Add Member form
  final String? profileImageUrl;
  final String? dateOfBirth;
  final String? address;
  final List<String>? fitnessGoals;
  final List<String>? addOnServices;
  final String? paymentMethod;

  /// "Monthly" | "Quarterly" | "Yearly" | "One-time Full Payment"
  final String? billingFrequency;
  final String? preferredStartDate;
  final String? signature;
  final String? dateSigned;
  final String? lastPaymentDate;

  Member({
    this.docId = '',
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membership,
    required this.status,
    required this.joinDate,
    required this.expiryDate,
    this.profileImageUrl,
    this.dateOfBirth,
    this.address,
    this.fitnessGoals,
    this.addOnServices,
    this.paymentMethod,
    this.billingFrequency,
    this.preferredStartDate,
    this.signature,
    this.dateSigned,
    this.lastPaymentDate,
  });

  /// Maps a Firestore [QueryDocumentSnapshot] to a [Member].
  /// All date fields are stored as "YYYY-MM-DD" strings in Firestore.
  factory Member.fromFirestore(Map<String, dynamic> data, String docId) {
    return Member(
      docId: docId,
      id: (data['gymId'] != null)
          ? int.tryParse(data['gymId'].toString()) ?? 0
          : 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      membership: data['membership'] ?? '',
      status: data['status'] ?? 'Active',
      joinDate: data['joinDate'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      profileImageUrl: data['image'],
      dateOfBirth: data['dateOfBirth'],
      address: data['address'],
      fitnessGoals: (data['fitnessGoals'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      addOnServices: (data['addOnServices'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      paymentMethod: data['paymentMethod'],
      billingFrequency: data['billingFrequency'],
      preferredStartDate: data['preferredStartDate'],
      signature: data['signature'],
      dateSigned: data['dateSigned'],
      lastPaymentDate: data['lastPaymentDate'],
    );
  }
}

class GymClass {
  final int id;
  final String name;
  final String trainer;
  final String schedule;
  final String time;
  final int capacity;
  int enrolled;
  final String category;
  String status;

  GymClass({
    required this.id,
    required this.name,
    required this.trainer,
    required this.schedule,
    required this.time,
    required this.capacity,
    required this.enrolled,
    required this.category,
    required this.status,
  });

  int get spotsLeft => capacity - enrolled;
}

class Trainer {
  final int id;
  final String name;
  final String specialization;
  final String email;
  final String phone;
  final double rating;
  final int classes;
  String status;
  final String joinDate;

  Trainer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.email,
    required this.phone,
    required this.rating,
    required this.classes,
    required this.status,
    required this.joinDate,
  });
}

class AttendanceRecord {
  final int id;
  final String member;
  final String className;
  final String trainer;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.member,
    required this.className,
    required this.trainer,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

class Payment {
  /// Firestore document ID — required to call `.update()` on this specific doc.
  final String docId;

  final int id;
  final String member;
  final double amount;
  final String plan;
  final String method;
  String status;

  /// ISO-8601 date string "YYYY-MM-DD".
  final String date;
  final String dueDate;
  final String invoiceId;
  final String gymId;

  /// Firestore document ID of the member who made this payment.
  final String memberId;

  Payment({
    this.docId = '',
    required this.id,
    required this.member,
    required this.amount,
    required this.plan,
    required this.method,
    required this.status,
    required this.date,
    required this.dueDate,
    required this.invoiceId,
    this.gymId = '',
    this.memberId = '',
  });

  factory Payment.fromFirestore(Map<String, dynamic> data, String docId) {
    final rawGymId = data['gymId']?.toString() ?? '';
    final rawMemberId = data['memberId']?.toString() ?? '';
    final gymIdVal = rawGymId.isNotEmpty ? rawGymId : rawMemberId;

    return Payment(
      docId: docId,
      id: 0,
      member: data['member'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      plan: data['plan'] ?? '',
      method: data['method'] ?? '',
      status: data['status'] ?? 'Pending',
      date: data['date'] ?? '',
      dueDate: data['date'] ?? '',
      invoiceId: data['invoiceId'] ?? docId,
      gymId: gymIdVal,
      memberId: rawMemberId,
    );
  }
}

// ── Seed data ──────────────────────────────────────────────────────────────────

final List<Member> seedMembers = [
  Member(id: 1, name: 'Sarah Johnson', email: 'sarah.j@email.com', phone: '(555) 123-4567', membership: 'Premium', status: 'Active', joinDate: 'Jan 15, 2026', expiryDate: 'Jan 15, 2027'),
  Member(id: 2, name: 'Mike Davis', email: 'mike.d@email.com', phone: '(555) 234-5678', membership: 'Standard', status: 'Active', joinDate: 'Feb 20, 2026', expiryDate: 'Feb 20, 2027'),
  Member(id: 3, name: 'Emma Wilson', email: 'emma.w@email.com', phone: '(555) 345-6789', membership: 'Premium', status: 'Active', joinDate: 'Mar 10, 2026', expiryDate: 'Mar 10, 2027'),
  Member(id: 4, name: 'James Brown', email: 'james.b@email.com', phone: '(555) 456-7890', membership: 'Basic', status: 'Pending', joinDate: 'Jun 5, 2026', expiryDate: 'Jun 5, 2027'),
  Member(id: 5, name: 'Lisa Anderson', email: 'lisa.a@email.com', phone: '(555) 567-8901', membership: 'Premium', status: 'Active', joinDate: 'Apr 8, 2026', expiryDate: 'Apr 8, 2027'),
  Member(id: 6, name: 'David Martinez', email: 'david.m@email.com', phone: '(555) 678-9012', membership: 'Standard', status: 'Expired', joinDate: 'May 12, 2025', expiryDate: 'May 12, 2026'),
];

final List<GymClass> seedClasses = [
  GymClass(id: 1, name: 'Morning Yoga', trainer: 'Anna Lee', schedule: 'Mon, Wed, Fri', time: '7:00 AM', capacity: 20, enrolled: 18, category: 'Yoga', status: 'Active'),
  GymClass(id: 2, name: 'HIIT Blast', trainer: 'Carlos Ruiz', schedule: 'Tue, Thu', time: '6:00 PM', capacity: 15, enrolled: 15, category: 'Cardio', status: 'Full'),
  GymClass(id: 3, name: 'Strength & Conditioning', trainer: 'Mark Powell', schedule: 'Mon, Wed', time: '5:30 PM', capacity: 12, enrolled: 9, category: 'Strength', status: 'Active'),
  GymClass(id: 4, name: 'Spin Cycle', trainer: 'Anna Lee', schedule: 'Tue, Thu, Sat', time: '8:00 AM', capacity: 25, enrolled: 20, category: 'Cardio', status: 'Active'),
  GymClass(id: 5, name: 'Pilates Core', trainer: 'Sofia Mendez', schedule: 'Wed, Fri', time: '10:00 AM', capacity: 15, enrolled: 11, category: 'Pilates', status: 'Active'),
  GymClass(id: 6, name: 'Boxing Fundamentals', trainer: 'Carlos Ruiz', schedule: 'Mon, Thu', time: '7:00 PM', capacity: 10, enrolled: 4, category: 'Boxing', status: 'Active'),
];

final List<Trainer> seedTrainers = [
  Trainer(id: 1, name: 'Anna Lee', specialization: 'Yoga & Pilates', email: 'anna.l@gym.com', phone: '(555) 111-2222', rating: 4.9, classes: 2, status: 'Active', joinDate: 'Mar 2024'),
  Trainer(id: 2, name: 'Carlos Ruiz', specialization: 'HIIT & Boxing', email: 'carlos.r@gym.com', phone: '(555) 222-3333', rating: 4.7, classes: 2, status: 'Active', joinDate: 'Jan 2024'),
  Trainer(id: 3, name: 'Mark Powell', specialization: 'Strength Training', email: 'mark.p@gym.com', phone: '(555) 333-4444', rating: 4.8, classes: 1, status: 'Active', joinDate: 'Jun 2023'),
  Trainer(id: 4, name: 'Sofia Mendez', specialization: 'Pilates & Flexibility', email: 'sofia.m@gym.com', phone: '(555) 444-5555', rating: 4.6, classes: 1, status: 'Active', joinDate: 'Sep 2024'),
];

final List<AttendanceRecord> seedAttendance = [
  AttendanceRecord(id: 1, member: 'Sarah Johnson', className: 'Morning Yoga', trainer: 'Anna Lee', date: 'Jun 10, 2026', checkIn: '6:55 AM', checkOut: '8:00 AM', status: 'Present'),
  AttendanceRecord(id: 2, member: 'Mike Davis', className: 'HIIT Blast', trainer: 'Carlos Ruiz', date: 'Jun 10, 2026', checkIn: '5:58 PM', checkOut: '7:00 PM', status: 'Present'),
  AttendanceRecord(id: 3, member: 'Emma Wilson', className: 'Morning Yoga', trainer: 'Anna Lee', date: 'Jun 10, 2026', checkIn: '7:02 AM', checkOut: '8:00 AM', status: 'Late'),
  AttendanceRecord(id: 4, member: 'James Brown', className: 'Strength & Conditioning', trainer: 'Mark Powell', date: 'Jun 10, 2026', checkIn: '—', checkOut: '—', status: 'Absent'),
  AttendanceRecord(id: 5, member: 'Lisa Anderson', className: 'Spin Cycle', trainer: 'Anna Lee', date: 'Jun 9, 2026', checkIn: '7:59 AM', checkOut: '9:00 AM', status: 'Present'),
  AttendanceRecord(id: 6, member: 'David Martinez', className: 'Boxing Fundamentals', trainer: 'Carlos Ruiz', date: 'Jun 9, 2026', checkIn: '—', checkOut: '—', status: 'Absent'),
];

final List<Payment> seedPayments = [
  Payment(id: 1, member: 'Sarah Johnson', amount: 120, plan: 'Premium', method: 'Credit Card', status: 'Paid', date: 'Jun 1, 2026', dueDate: 'Jun 1, 2026', invoiceId: 'INV-001'),
  Payment(id: 2, member: 'Mike Davis', amount: 80, plan: 'Standard', method: 'Bank Transfer', status: 'Paid', date: 'Jun 2, 2026', dueDate: 'Jun 2, 2026', invoiceId: 'INV-002'),
  Payment(id: 3, member: 'Emma Wilson', amount: 120, plan: 'Premium', method: 'Credit Card', status: 'Paid', date: 'Jun 3, 2026', dueDate: 'Jun 3, 2026', invoiceId: 'INV-003'),
  Payment(id: 4, member: 'James Brown', amount: 50, plan: 'Basic', method: 'Cash', status: 'Pending', date: '—', dueDate: 'Jun 10, 2026', invoiceId: 'INV-004'),
  Payment(id: 5, member: 'Lisa Anderson', amount: 120, plan: 'Premium', method: 'Credit Card', status: 'Paid', date: 'May 28, 2026', dueDate: 'May 28, 2026', invoiceId: 'INV-005'),
  Payment(id: 6, member: 'David Martinez', amount: 80, plan: 'Standard', method: 'Credit Card', status: 'Overdue', date: '—', dueDate: 'May 12, 2026', invoiceId: 'INV-006'),
];
