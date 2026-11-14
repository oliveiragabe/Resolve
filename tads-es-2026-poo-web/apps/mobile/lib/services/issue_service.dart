import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/issue.dart';

class IssueService {
  final http.Client _client;

  IssueService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Issue>> getAll() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.issues),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => Issue.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao carregar ocorrências.');
  }

  Future<Issue> getById(int id) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.issues}/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Issue.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao buscar ocorrência.');
  }

  Future<Issue> create(Issue issue) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.issues),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(issue.toJson()),
    );

    if (response.statusCode == 201) {
      return Issue.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao criar ocorrência: ${response.body}');
  }

  Future<Issue> update(int id, Issue issue) async {
    final response = await _client.put(
      Uri.parse('${ApiConstants.issues}/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(issue.toJson()),
    );

    if (response.statusCode == 200) {
      return Issue.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao atualizar ocorrência: ${response.body}');
  }

  Future<void> delete(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.issues}/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir ocorrência.');
    }
  }

  void dispose() {
    _client.close();
  }
}
