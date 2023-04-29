class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateTaskException extends CloudStorageException{}

//R in CRUD
class CouldNotGetTaskException extends CouldNotCreateTaskException{}

//U in CRUD
class CouldNotUpdateTaskException extends CouldNotCreateTaskException{}

//D in CRUD
class CouldNotDeleteTaskException extends CouldNotCreateTaskException{}
