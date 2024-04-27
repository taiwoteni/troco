/// The [Process] is used to indicate the entire process
/// Of the transaction. It's handful and used in the transaction process.
class Process{
  final String message;
  final List<SubProcess> subProcesses;
  const Process({required this.message, required this.subProcesses});

  bool get completed => subProcesses.every((element) => element.done);

}

class SubProcess{
  final String message;
  final bool done;

  const SubProcess({required this.message, required this.done});
}