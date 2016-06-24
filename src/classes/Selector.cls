public with sharing class Selector implements ISelector {
    private static final Integer SELECT_LIMIT = 50000;
    public SObjectType type {get; private set;}
    public IFieldService service {get; private set;}

    public Selector(String type) {
        if ( Schema.getGlobalDescribe().containsKey(type) ) {
            this.type = Schema.getGlobalDescribe().get(type);
            this.service = new FieldService(type);
        } else {
            throw new DAOExceptions.InvalidSObjectTypeException();
        }
    }

    public Selector(String type, IFieldService service) {
        this(type);
        this.service = service;
    }

    public Selector(SObjectType type) {
        this.type = type;
        this.service = new FieldService(type);
    }

    public Selector(SObjectType type, IFieldService service) {
        this(type);
        this.service = service;
    }

    public List<SObject> getRecords() {
        return this.getRecords(SELECT_LIMIT);
    }

    public List<SObject> getRecords(Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        fflib_QueryFactory factory = new fflib_QueryFactory(this.type).selectFields(this.service.getFields()).setLimit(selectLimit);   
        System.debug('##### Selector : Query ##### [' + factory.toSOQL() + '] #####');
        return Database.query(factory.toSOQL());
    }
    
    public SObject getRecordById(Id recordId) {
        if ( recordId.getSobjectType() != this.type ) {
            throw new DAOExceptions.InvalidSObjectIDException();
        }
        return this.getSObjectById(recordId); 
    }

    public SObject getRecordById(String recordId) {
        Id convertedRecordId = Id.valueOf(recordId);
        if ( convertedRecordId.getSobjectType() != this.type ) {
            throw new DAOExceptions.InvalidSObjectIDException();
        }
        return this.getSObjectById(convertedRecordId);
    }

    @TestVisible
    private SObject getSObjectById(Id recordId) {
        String whereClause = 'Id = \'' + String.valueOf(recordId) + '\''; // NEED FORMATING IMPROVEMENT
        fflib_QueryFactory factory = new fflib_QueryFactory(this.type).selectFields(this.service.getFields()).setLimit(1).setCondition(whereClause);   
        System.debug('##### Selector : Query ##### [' + factory.toSOQL() + '] #####');
        List<SObject> sobjects = Database.query(factory.toSOQL());
        if ( sobjects.size() > 0 ) {
            return sobjects.get(0);
        } else {
            throw new DAOExceptions.RecordDoesntExistException();
        }
    }

    public List<SObject> getRecordsWhere(String whereClause) {
        return this.getRecordsWhere(whereClause, SELECT_LIMIT);
    }

    public List<SObject> getRecordsWhere(String whereClause, Integer selectLimit) {
        fflib_QueryFactory factory = new fflib_QueryFactory(this.type).selectFields(this.service.getFields()).setLimit(selectLimit).setCondition(whereClause);   
        System.debug('##### Selector : Query ##### [' + factory.toSOQL() + '] #####');
        return Database.query(factory.toSOQL());
    }

    public List<SObject> getRecordsByFields(String fields) {
        return this.getRecordsByFields(this.format(fields), SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFields(String fields, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        return this.getRecordsByFields(this.format(fields), selectLimit);
    }

    /*
     * Split string and delete whitespaces.
    */
    @TestVisible
    public Set<String> format(String fields) {
        String[] splitedFields = fields.split(',');
        Set<String> formatedFields = new Set<String>();
        for ( String field : splitedFields ) {
            formatedFields.add(field.deleteWhitespace());
        }
        return formatedFields;
    }

    public List<SObject> getRecordsByFieldset(String fieldSetName) {
        if ( String.isEmpty(fieldSetName) ) {
            throw new DAOExceptions.EmptyParameterException();
        }
        Map<String, Schema.FieldSet> fieldSetMap = this.type.getDescribe().fieldSets.getMap();
        if ( ! fieldSetMap.containsKey(fieldSetName) ) {
            throw new DAOExceptions.FieldSetDoesntExistException();
        }
        Set<String> fields = this.getFields(fieldSetMap.get(fieldSetName).getFields());
        return this.getRecordsByFields(new Set<String>(fields), SELECT_LIMIT);
    }

    @TestVisible
    private Set<String> getFields(List<Schema.FieldSetMember> fields) {
        Set<String> result = new Set<String>();
        for ( FieldSetMember member : fields ) {
            result.add(member.getFieldPath());
        }
        return result;
    }

    public List<SObject> getRecordsByFields(String[] fields) {
        return this.getRecordsByFields(new Set<String>(fields), SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFields(Set<String> fields) {
        return this.getRecordsByFields(fields, SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFields(String[] fields, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        return this.getRecordsByFields(new Set<String>(fields), selectLimit);
    }

    public List<SObject> getRecordsByFields(Set<String> fields, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        fflib_QueryFactory factory = new fflib_QueryFactory(this.type).selectFields(fields).setLimit(selectLimit);   
        System.debug('##### Selector : Query ##### [' + factory.toSOQL() + '] #####');
        return Database.query(factory.toSOQL());
    }

    public List<SObject> getRecordsByFieldsetWhere(String fieldsetName, String whereClause) {
        if ( String.isEmpty(fieldsetName) ) {
            throw new DAOExceptions.EmptyParameterException();
        }
        Map<String, Schema.FieldSet> fieldSetMap = this.type.getDescribe().fieldSets.getMap();
        if ( ! fieldSetMap.containsKey(fieldsetName) ) {
            throw new DAOExceptions.FieldSetDoesntExistException();
        }
        Set<String> fields = this.getFields(fieldSetMap.get(fieldsetName).getFields());
        return this.getRecordsByFieldsWhere(fields, whereClause, SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFieldsWhere(String fields, String whereClause) {
        return this.getRecordsByFieldsWhere(fields, whereClause, SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFieldsWhere(String[] fields, String whereClause) {
        return this.getRecordsByFieldsWhere(new Set<String>(fields), whereClause, SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFieldsWhere(Set<String> fields, String whereClause) {
        return this.getRecordsByFieldsWhere(fields, whereClause, SELECT_LIMIT);
    }

    public List<SObject> getRecordsByFieldsWhere(String fields, String whereClause, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        return this.getRecordsByFieldsWhere(new Set<String>(this.format(fields)), whereClause, selectLimit);
    }

    public List<SObject> getRecordsByFieldsWhere(String[] fields, String whereClause, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        return this.getRecordsByFieldsWhere(new Set<String>(fields), whereClause, selectLimit);
    }

    public List<SObject> getRecordsByFieldsWhere(Set<String> fields, String whereClause, Integer selectLimit) {
        if ( selectLimit == null || selectLimit <= 0 ) {
            throw new DAOExceptions.InvalidLimitParameterException();
        }
        fflib_QueryFactory factory = new fflib_QueryFactory(this.type).selectFields(fields).setLimit(selectLimit).setCondition(whereClause);   
        System.debug('##### Selector : Query ##### [' + factory.toSOQL() + '] #####');
        return Database.query(factory.toSOQL());
    }

}