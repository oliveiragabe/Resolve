import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/issue_options.dart';
import '../../core/utils/validators.dart';
import '../../models/issue.dart';
import '../../services/issue_service.dart';

class IssueFormScreen extends StatefulWidget {
  final int? issueId;
  final IssueService? service;

  const IssueFormScreen({super.key, this.issueId, this.service});

  @override
  State<IssueFormScreen> createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends State<IssueFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final IssueService _issueService;
  late final bool _ownsService;

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

    _ownsService = widget.service == null;
    _issueService = widget.service ?? IssueService();

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
      if (_isEditing) {
        await _issueService.update(widget.issueId!, issue);
      } else {
        await _issueService.create(issue);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? AppStrings.editSuccess : AppStrings.createSuccess,
          ),
        ),
      );

      // Após salvar, retorna diretamente ao dashboard.
      context.go('/');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${AppStrings.saveError}$e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();

    if (_ownsService) {
      _issueService.dispose();
    }

    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        children: [
          Text(
            _isEditing
                ? AppStrings.editIssueTitle
                : AppStrings.createIssueTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            _isEditing
                ? AppStrings.editIssueDescription
                : AppStrings.createIssueDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacingXXL),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: AppStrings.title,
              hintText: AppStrings.titleHint,
              prefixIcon: Icon(Icons.title),
            ),
            validator: Validators.title,
          ),
          const SizedBox(height: AppDimensions.spacingLG),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: AppStrings.description,
              hintText: AppStrings.descriptionHint,
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: AppDimensions.spacingLG),

          TextFormField(
            controller: _projectController,
            decoration: const InputDecoration(
              labelText: AppStrings.project,
              hintText: AppStrings.projectHint,
              prefixIcon: Icon(Icons.folder_outlined),
            ),
            validator: Validators.requiredField,
          ),
          const SizedBox(height: AppDimensions.spacingLG),

          DropdownButtonFormField<String>(
            initialValue: _severity,
            decoration: const InputDecoration(
              labelText: AppStrings.severity,
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: IssueOptions.severities.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _severity = value);
              }
            },
          ),
          const SizedBox(height: AppDimensions.spacingLG),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: AppStrings.status,
              prefixIcon: Icon(Icons.pending_outlined),
            ),
            items: IssueOptions.statuses.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
          const SizedBox(height: AppDimensions.spacingXXXL),

          FilledButton.icon(
            onPressed: _isSaving ? null : _saveIssue,
            icon: _isSaving
                ? const SizedBox(
                    width: AppDimensions.iconSM,
                    height: AppDimensions.iconSM,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isEditing ? AppStrings.saveChanges : AppStrings.registerIssue,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),

          OutlinedButton(
            onPressed: _isSaving ? null : () => context.go('/'),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar ao painel',
          ),
          title: const Text(AppStrings.createIssueTitle),
        ),
        body: _buildForm(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar ao painel',
        ),
        title: const Text(AppStrings.editIssueTitle),
      ),
      body: FutureBuilder<Issue>(
        future: _issueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text(AppStrings.loadIssueError));
          }

          _fillForm(snapshot.data!);

          return _buildForm();
        },
      ),
    );
  }
}
