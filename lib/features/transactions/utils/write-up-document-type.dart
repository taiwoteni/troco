enum WriteUpDocumentType { Credential, Information }

class WriteUpDocumentTypeConverter {
  static WriteUpDocumentType fromString({required final String documentType}) {
    switch (documentType.toLowerCase().trim()) {
      case 'credential':
        return WriteUpDocumentType.Credential;
      default:
        return WriteUpDocumentType.Information;
    }
  }
}
