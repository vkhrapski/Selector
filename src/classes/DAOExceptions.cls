public with sharing class DAOExceptions {
    public class InvalidSObjectTypeException extends Exception {}
    public class InvalidSObjectIDException extends Exception {}
    public class InvalidLimitParameterException extends Exception {}
    public class RecordDoesntExistException extends Exception {}
    public class NotParentObjectException extends Exception {}
    public class InvoiceLineItemChangeException extends Exception {}
    public class EmptyParameterException extends Exception {}
    public class FieldSetDoesntExistException extends Exception {}
}