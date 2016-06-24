public interface ISelector {
    List<SObject> getRecords();
    SObject getRecordById(Id recordId);
    List<SObject> getRecordsWhere(String whereClause);
    List<SObject> getRecordsByFields(Set<String> fields);
    List<SObject> getRecordsByFieldsWhere(Set<String> fields, String whereClause);
}