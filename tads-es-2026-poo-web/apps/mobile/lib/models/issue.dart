class Issue {
  final int? id;
  final String title;
  final String? description;
  final String project;
  final String severity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Issue({
    this.id,
    required this.title,
    this.description,
    required this.project,
    required this.severity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      project: json['project'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'project': project,
      'severity': severity,
      'status': status,
    };
  }
}
