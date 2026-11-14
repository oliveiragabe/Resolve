<?php

namespace App\Http\Controllers;

use App\Http\Services\IssueService;
use App\Models\Issue;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class IssueController extends Controller
{
    public function __construct(
        private IssueService $service
    ) {}

    public function index(): JsonResponse
    {
        return response()->json($this->service->getAll());
    }

    public function show(int $id): JsonResponse
    {
        $issue = $this->service->findById($id);

        if (!$issue) {
            return response()->json([
                'message' => 'Ocorrência não encontrada.'
            ], 404);
        }

        return response()->json($issue);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => 'required|string|max:150',
            'description' => 'nullable|string',
            'project' => 'required|string|max:100',
            'severity' => 'required|in:baixa,media,critica',
            'status' => 'sometimes|in:aberto,em_resolucao,fechado',
        ]);

        $issue = $this->service->create($data);

        return response()->json($issue, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $issue = $this->service->findById($id);

        if (!$issue) {
            return response()->json([
                'message' => 'Ocorrência não encontrada.'
            ], 404);
        }

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:150',
            'description' => 'nullable|string',
            'project' => 'sometimes|required|string|max:100',
            'severity' => 'sometimes|required|in:baixa,media,critica',
            'status' => 'sometimes|required|in:aberto,em_resolucao,fechado',
        ]);

        $updatedIssue = $this->service->update($issue, $data);

        return response()->json($updatedIssue);
    }

    public function destroy(int $id): JsonResponse
    {
        $issue = $this->service->findById($id);

        if (!$issue) {
            return response()->json([
                'message' => 'Ocorrência não encontrada.'
            ], 404);
        }

        $this->service->delete($issue);

        return response()->json([
            'message' => 'Ocorrência excluída com sucesso.'
        ]);
    }
}