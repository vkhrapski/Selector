@isTest
private class SelectorTest {
    @isTest
    static void constructor_When_SObjectTypePassed_Then_createdObjectWithSpecifiedType() {
    	Test.startTest();
    		Selector accSelector = new Selector(Account.SObjectType);
    	Test.stopTest();
        System.assertEquals(accSelector.type, Account.SObjectType);
    }

    @isTest
    static void constructor_When_SObjectTypePassedWithFieldService_Then_createdObjectWithSpecifiedTypeAndService() {
        Test.startTest();
            Selector accSelector = new Selector(Account.SObjectType, new FieldService(Account.SObjectType));
        Test.stopTest();
        System.assertEquals(accSelector.type, Account.SObjectType);
        System.assertEquals(accSelector.service instanceof FieldService, true);
    }

    @isTest
    static void constructor_Should_createSelectorWithSpecifiedSObjectType_When_passedValidObjectName() {
        Test.startTest();
            Selector accSelector = new Selector('Account');
        Test.stopTest();
        System.assertEquals(accSelector.type, Account.SObjectType);
    }

    @isTest
    static void constructor_Should_throwInvalidSObjectTypeException_When_passInvalidObjectName() {
        Test.startTest();
            Boolean result = false;
            try {
                Selector testSelector = new Selector('111');
            } catch ( DAOExceptions.InvalidSObjectTypeException e ) {
                result = true;
            }
        Test.stopTest();
        System.assertEquals(result, true);
    }

    @isTest
    static void getRecords_Should_returnMax50KSObjectRecords() {
        Test.startTest();
            List<Account> accRecords = new List<Account>();
            Boolean isThrownExceptions = false;
            try {
                Selector accSelector = new Selector(Account.SObjectType);
                accRecords.addAll((List<Account>)accSelector.getRecords());
            } catch ( Exception e ) {
                isThrownExceptions = true;
            }
        Test.stopTest();
        System.assertEquals(isThrownExceptions, false);
        System.assertEquals(accRecords.size() <= 50000, true);
    }

    @isTest
    static void getRecords_Should_returnSpecifiedObejctCount_When_limitParamIsValid() {
        Test.startTest();
            List<Account> accRecords = new List<Account>();
            Boolean isThrownExceptions = false;
            try {
                Selector accSelector = new Selector(Account.SObjectType);
                accRecords.addAll((List<Account>)accSelector.getRecords(10));
            } catch ( Exception e ) {
                isThrownExceptions = true;
            }
        Test.stopTest();
        System.assertEquals(isThrownExceptions, false);
        System.assertEquals(accRecords.size() <= 10, true);
    }

    @isTest
    static void getRecordById_Should_returnRecord_When_passedValidStringId() {
        Test.startTest();
            Account acc = new Account(Name = 'getRecordById' + String.valueOf(System.now()));
            insert acc;
            Selector accSelector = new Selector(Account.SObjectType);
            Account selectedAcc = (Account) accSelector.getRecordById(String.valueOf(acc.Id));
        Test.stopTest();
        System.assertEquals(acc.Id, selectedAcc.Id);
    }

    @isTest
    static void getRecord_When_passedInvalidObjectId_Then_InvalidSObjectIDException() {
    	Test.startTest();
    		try {
    			Account acc = new Account(Name = String.valueOf(System.now()));
    			insert acc;
    		    new Selector('User').getRecordById(acc.Id);
    		}
    		catch ( DAOExceptions.InvalidSObjectIDException e ) {
    		    System.assert(true);
    		}
    	Test.stopTest();
    }

    @isTest
    static void getRecord_When_passedValidId_Then_returnObject() {
    	Test.startTest();
    		Account acc = new Account(Name = String.valueOf(System.now()));
    		insert acc;
    		Account selectedAccount = (Account) new Selector('Account').getRecordById(acc.Id);
    	Test.stopTest();
    	System.assertEquals(acc.Id, selectedAccount.Id);
    }

    @isTest
    static void getRecordsWhere_When_passedValidWhereClauseString_Then_returnValidObjectsMeetingCreteria() {
    	Test.startTest();
    		Account acc = new Account(Name = String.valueOf(System.now()));
    		insert acc;
    		List<Account> selectedAccounts = (List<Account>) new Selector('Account').getRecordsWhere('Id = \'' + acc.Id + '\'');
    	Test.stopTest();
    	System.assertEquals(selectedAccounts.size(), 1);
    	System.assertEquals(acc.Id, selectedAccounts.get(0).Id);
    }

    @isTest
    static void getRecordsByFields_Should_returnObjectsWithSpecifiedFields_When_passedValidFieldsInString() {
        Test.startTest();
            SmartFactory.createSObjectList('Account', 10, true, true);
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFields('Name, BillingCity');
        Test.stopTest();
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertNotEquals(accRecords.get(0).Name, null);
    }

    @isTest
    static void getRecordsByFields_Should_returnSpecifiedObejctsCountWithSpecifiedFields_When_passedValidParams() {
        Test.startTest();
            Integer recordsCount = 10;
            SmartFactory.createSObjectList('Account', recordsCount, true, true);
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFields('Name, BillingCity', recordsCount);
        Test.stopTest();
        System.assertEquals(accRecords.size(), recordsCount);
    }

    @isTest
    static void getRecordsByFields_Should_returnObjectWithSpecifiedInListFieldsDeletingDuplicate_When_passedValidParams() {
        Test.startTest();
            Integer recordsCount = 10;
            SmartFactory.createSObjectList('Account', recordsCount, true, true);
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFields(new List<String>{'Name', 'Name', 'BillingCity'});
            accRecords = (List<Account>) accSelector.getRecordsByFields(new List<String>{'Name', 'Name', 'BillingCity'}, recordsCount);
        Test.stopTest();
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertNotEquals(accRecords.get(0).Name, null);
        System.assertEquals(accRecords.size(), recordsCount);
    }

    @isTest
    static void getRecordsByFields_Should_returnObjectWithSpecifiedInSetFields_When_passedValidStringParams() {
        Test.startTest();
            Integer recordsCount = 10;
            SmartFactory.createSObjectList('Account', recordsCount, true, true);
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFields(new Set<String>{'Name', 'BillingCity'});
        Test.stopTest();
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertNotEquals(accRecords.get(0).Name, null);
    }

    @isTest
    static void getRecordsByFieldsWhere_Should_returnObjectWithSpecifiedSetOFieldsAcceptWhereClause_When_paramsAreValid() {
        Test.startTest();
            Integer recordsCount = 1;
            String cityName = 'Test';
            Account acc = (Account) SmartFactory.createSObject('Account', true, 1, false);
            acc.BillingCity = cityName;
            insert acc;
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere(new Set<String>{'Name', 'BillingCity'}, 'BillingCity = \'' + cityName + '\'');
            accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere(new Set<String>{'Name', 'BillingCity'}, 'BillingCity = \'' + cityName + '\'', 1);
        Test.stopTest();
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertEquals(accRecords.get(0).BillingCity, cityName);
    }

    @isTest
    static void getRecordsByFieldsWhere_Should_returnObjectWithSpecifiedStringOFieldsAcceptWhereClause_When_paramsAreValid() {
        Test.startTest();
            Integer recordsCount = 1;
            String cityName = 'Test';
            Account acc = (Account) SmartFactory.createSObject('Account', true, 1, false);
            acc.BillingCity = cityName;
            insert acc;
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere('Name, BillingCity', 'BillingCity = \'' + cityName + '\'');
            accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere('Name, BillingCity', 'BillingCity = \'' + cityName + '\'', 1);
        Test.stopTest();
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertEquals(accRecords.get(0).BillingCity, cityName);
    }

    @isTest
    static void getRecordsByFieldsWhere_Should_returnObjectWithSpecifiedListOFieldsAcceptWhereClause_When_paramsAreValid() {
        Test.startTest();
            Integer recordsCount = 1;
            String cityName = 'Test';
            Account acc = (Account) SmartFactory.createSObject('Account', true, 1, false);
            acc.BillingCity = cityName;
            insert acc;
            Selector accSelector = new Selector(Account.SObjectType);
            List<Account> accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere(new List<String>{'Name', 'Name', 'BillingCity'}, 'BillingCity = \'' + cityName + '\'');
            accRecords = (List<Account>) accSelector.getRecordsByFieldsWhere(new List<String>{'Name', 'Name', 'BillingCity'}, 'BillingCity = \'' + cityName + '\'', 1);
        System.assertEquals(accRecords.isEmpty(), false);
        System.assertEquals(accRecords.get(0).BillingCity, cityName);
    }
}