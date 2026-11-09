// MSTest asks every test project to say whether tests may run at the same time. These can: none
// of them touch a file or anything shared.
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
