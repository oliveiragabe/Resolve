import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class IssueFormScreen extends StatefulWidget {
  final int? issueId;

  const IssueFormScreen({super.key, this.issueId});

  @override
  State<IssueFormScreen> createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends State<IssueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueService = IssueService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectController = TextEditingController();

  String _severity = 'media';
  String _status = 'aberto';

  bool _isSaving = false;
  bool _formInitialized = false;

  late Future<Issue>? _issueFuture;

  bool get _isEditing => widget.issueId != null;

  @override
  void initState() {
    super.initState();

    _issueFuture = _isEditing ? _issueService.getById(widget.issueId!) : null;
  }

  void _fillForm(Issue issue) {
    if (_formInitialized) return;

    _titleController.text = issue.title;
    _descriptionController.text = issue.description ?? '';
    _projectController.text = issue.project;
    _severity = issue.severity;
    _status = issue.status;

    _formInitialized = true;
  }

  Future<void> _saveIssue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final issue = Issue(
      id: widget.issueId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      project: _projectController.text.trim(),
      severity: _severity,
      status: _status,
    );

    try {
      final savedIssue = _isEditing
          ? await _issueService.update(widget.issueId!, issue)
          : await _issueService.create(issue);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Ocorrência atualizada com sucesso!'
                : 'Ocorrência criada com sucesso!',
          ),
        ),
      );

      context.goNamed(
        AppRoutes.issueDetails,
        pathParameters: {'id': savedIssue.id.toString()},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar ocorrência: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();
    _issueService.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _isEditing ? 'Editar ocorrência' : 'Nova ocorrência',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing
                ? 'Atualize as informações da ocorrência.'
                : 'Preencha os dados para registrar uma ocorrência.',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ex.: Erro ao salvar usuário',
              prefixIcon: Icon(Icons.title),
            ),
            validator: Validators.title,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              hintText: 'Descreva o problema encontrado...',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _projectController,
            decoration: const InputDecoration(
              labelText: 'Projeto',
              hintText: 'Ex.: Resolve',
              prefixIcon: Icon(Icons.folder_outlined),
            ),
            validator: Validators.requiredField,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _severity,
            decoration: const InputDecoration(
              labelText: 'Severidade',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
              DropdownMenuItem(value: 'media', child: Text('Média')),
              DropdownMenuItem(value: 'critica', child: Text('Crítica')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _severity = value);
              }
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.pending_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'aberto', child: Text('Aberto')),
              DropdownMenuItem(
                value: 'em_resolucao',
                child: Text('Em resolução'),
              ),
              DropdownMenuItem(value: 'fechado', child: Text('Fechado')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: _isSaving ? null : _saveIssue,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isEditing ? 'Salvar alterações' : 'Cadastrar ocorrência',
            ),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: _isSaving ? null : () => context.pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova ocorrência')),
        body: _buildForm(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar ocorrência')),
      body: FutureBuilder<Issue>(
        future: _issueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Não foi possível carregar a ocorrência.'),
            );
          }

          _fillForm(snapshot.data!);

          return _buildForm();
        },
      ),
    );
  }
}
