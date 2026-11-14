class IssueOptions {
  static const List<Map<String, String>> statuses = [
    {'value': 'aberto', 'label': 'Aberto'},
    {'value': 'em_resolucao', 'label': 'Em resolução'},
    {'value': 'fechado', 'label': 'Fechado'},
  ];

  static const List<Map<String, String>> severities = [
    {'value': 'baixa', 'label': 'Baixa'},
    {'value': 'media', 'label': 'Média'},
    {'value': 'critica', 'label': 'Crítica'},
  ];
}
