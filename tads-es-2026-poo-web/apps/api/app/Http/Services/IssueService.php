<?php

namespace App\Http\Services;

use App\Http\Repositories\IssueRepository;
use App\Models\Issue;
use Illuminate\Database\Eloquent\Collection;

class IssueService
{
    public function __construct(
        private IssueRepository $repository
    ) {}

    public function getAll(): Collection
    {
        return $this->repository->getAll();
    }

    public function findById(int $id): ?Issue
    {
        return $this->repository->findById($id);
    }

    public function create(array $data): Issue
    {
        return $this->repository->create($data);
    }

    public function update(Issue $issue, array $data): Issue
    {
        return $this->repository->update($issue, $data);
    }

    public function delete(Issue $issue): bool
    {
        return $this->repository->delete($issue);
    }
}