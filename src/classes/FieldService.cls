public with sharing class FieldService implements IFieldService {

    public SObjectType type {get; private set;}

    public FieldService(String type) {
        Map<String, SObjectType> describe = Schema.getGlobalDescribe();
    	if ( describe.containsKey(type) ) {
    		this.type = describe.get(type);
    	} else {
    		throw new DAOExceptions.InvalidSObjectTypeException();
    	}
    }

    public FieldService(SObjectType type) {
    	this.type = type;
    }

    public Set<String> getFields() {
    	Set<String> fields = new Set<String>();
        fields.addAll(this.getObjectFields());
    	return fields;
    }

    public Set<String> getObjectFields() {
        Set<String> result = new Set<String>();
        for ( SObjectField field : this.type.getDescribe().fields.getMap().values() ) {
            result.add(field.getDescribe().getName());
        }
        return result;
    }

    public Set<String> getParentsFields() {
        Set<String> result = new Set<String>();
        for ( SObjectField field : this.getRefenceFields() ) {
            DescribeFieldResult fieldDesc = field.getDescribe();
            for ( SObjectType type : fieldDesc.getReferenceTo() ) {
                String relationName = fieldDesc.getRelationshipName();
                FieldService service = new FieldService(type);
                for ( String fieldName : service.getObjectFields() ) {
                    result.add(relationName + '.' + fieldName);
                }
            }
        }
        return result;
    }

    public Set<String> getParentsFields(List<SObjectType> types) {
        Set<String> result = new Set<String>();
        for ( SObjectType type : types ) {
            result.addAll(this.getParentFields(type));
        }
        return result;
    }

    public Set<String> getParentFields(SObjectType parent) {
        Set<String> result = new Set<String>();
        if ( ! this.isParentObject(parent) ) {
            throw new DAOExceptions.NotParentObjectException();
        }
        return result;
    }

    @TestVisible
    private Boolean isParentObject(SObjectType parent) {
        return true;
    }

    @TestVisible
    private List<SObjectField> getRefenceFields() {
        List<SObjectField> result = new List<SObjectField>();
        for ( SObjectField field : this.type.getDescribe().fields.getMap().values() ) {
            DescribeFieldResult fieldDesc = field.getDescribe();
            if ( ! fieldDesc.getReferenceTo().isEmpty() ) { 
                result.add(field);
            }
        }
        return result;
    }

    @TestVisible
    private List<SObjectType> getReferenceToObjects() {
        List<SObjectType> result = new List<SObjectType>();
        for ( SObjectField field : this.getRefenceFields() ) {
            result.addAll(field.getDescribe().getReferenceTo());
        }
        return result;
    }
}