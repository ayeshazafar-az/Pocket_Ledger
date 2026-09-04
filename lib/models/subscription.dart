class Subscription {
  final String id;
  final String title;
  final double amount;
  final String cycle;

  Subscription({
    required this.id,
    required this.title,
    required this.amount,
    required this.cycle,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'cycle': cycle,
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    title: json['title'],
    amount: (json['amount'] as num).toDouble(),
    cycle: json['cycle'] ?? 'Monthly',
  );
}
