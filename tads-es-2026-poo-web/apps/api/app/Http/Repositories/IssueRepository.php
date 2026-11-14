<?php

namespace App\Http\Repositories;

use App\Models\Issue;
use Illuminate\Database\Eloquent\Collection;

class IssueRepository
{
    public function getAll(): Collection
    {
        return Issue::orderBy('created_at', 'desc')->get();
    }

    public function findById(int $id): ?Issue
    {
        return Issue::find($id);
    }

    public function create(array $data): Issue
    {
        return Issue::create($data);
    }

    public function update(Issue $issue, array $data): Issue
    {
        $issue->update($data);

        return $issue->fresh();
    }

    public function delete(Issue $issue): bool
    {
        return $issue->delete();
    }
}