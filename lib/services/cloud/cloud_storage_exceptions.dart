class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateriskException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllrisksException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateriskException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteriskException extends CloudStorageException {}
