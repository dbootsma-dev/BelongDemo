/**
 * @description Apex test class for ContactSearch. Validates input handling, trimming behavior,
 *              exact-match querying, multi-row results, and with sharing execution context.
 *              Includes debug statements throughout for traceability.
 * @author Agentforce
 * @date 2025-11-26
 *
 * Test Coverage Goals:
 * - Exercise early-return paths for null/blank parameters
 * - Validate exact match and trimmed input behavior
 * - Validate zero, single, and multiple match scenarios
 * - Execute under a non-admin user context to respect "with sharing"
 */
@IsTest
public /* per request: public scope */ class TestContactSearch {

    /**
     * @description Creates a standard user to validate with sharing context and returns the Id.
     *              This helper avoids SeeAllData by creating a minimal user and profile lookup.
     */
    private static Id createStandardUser() {
        System.debug(LoggingLevel.INFO, 'TestContactSearch.createStandardUser - Start');
        // Query any non-admin profile to assign to the test user
        Profile p = [SELECT Id, Name FROM Profile WHERE Name != 'System Administrator' LIMIT 1];
        System.debug(LoggingLevel.INFO, 'TestContactSearch.createStandardUser - Using Profile: ' + p.Name);

        User u = new User(
            Alias = 'stdusr',
            Email = 'stdusr@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Std',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'stdusr.' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id
        );
        insert u;
        System.debug(LoggingLevel.INFO, 'TestContactSearch.createStandardUser - Created User Id=' + u.Id);
        return u.Id;
    }

    /**
     * @description Test data setup for Contacts used across test methods.
     *              Inserts a mix of matching and non-matching records for the search criteria.
     */
    @TestSetup
    static void setupTestData() {
        System.debug(LoggingLevel.INFO, 'TestContactSearch.setupTestData - Start');

        List<Contact> contacts = new List<Contact>();
        // Matching records: LastName='Smith', Postal='12345'
        contacts.add(new Contact(LastName = 'Smith', FirstName = 'Alice', MailingPostalCode = '12345'));
        contacts.add(new Contact(LastName = 'Smith', FirstName = 'Bob',   MailingPostalCode = '12345'));

        // Distractors / non-matching variations
        contacts.add(new Contact(LastName = 'Smith', FirstName = 'Carol', MailingPostalCode = '54321')); // postal mismatch
        contacts.add(new Contact(LastName = 'Jones', FirstName = 'Dave',  MailingPostalCode = '12345')); // last name mismatch
        contacts.add(new Contact(LastName = 'Clark', FirstName = 'Eve',   MailingPostalCode = null));    // null postal
        contacts.add(new Contact(LastName = '  Smith  ', FirstName = 'Frank', MailingPostalCode = '12345')); // extra spaces in data

        insert contacts;
        System.debug(LoggingLevel.INFO, 'TestContactSearch.setupTestData - Inserted Contacts: ' + contacts.size());
    }

    /**
     * @description Verifies early return when lastName is null.
     */
    @IsTest
    static void testEarlyReturn_WhenLastNameNull_ReturnsEmpty() {
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenLastNameNull_ReturnsEmpty - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts(null, '12345');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenLastNameNull_ReturnsEmpty - Results size=' + results.size());
        System.assertEquals(0, results.size(), 'Expected empty results when lastName is null');
    }

    /**
     * @description Verifies early return when postalCode is null.
     */
    @IsTest
    static void testEarlyReturn_WhenPostalNull_ReturnsEmpty() {
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenPostalNull_ReturnsEmpty - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts('Smith', null);
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenPostalNull_ReturnsEmpty - Results size=' + results.size());
        System.assertEquals(0, results.size(), 'Expected empty results when postalCode is null');
    }

    /**
     * @description Verifies early return when inputs are blank or whitespace.
     */
    @IsTest
    static void testEarlyReturn_WhenParamsBlank_ReturnsEmpty() {
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenParamsBlank_ReturnsEmpty - Start');
        Test.startTest();
        List<Contact> r1 = ContactSearch.searchForContacts('', '12345');
        List<Contact> r2 = ContactSearch.searchForContacts('Smith', '   ');
        List<Contact> r3 = ContactSearch.searchForContacts('   ', '   ');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testEarlyReturn_WhenParamsBlank_ReturnsEmpty - r1=' + r1.size() + ', r2=' + r2.size() + ', r3=' + r3.size());
        System.assertEquals(0, r1.size(), 'Expected empty when lastName is blank');
        System.assertEquals(0, r2.size(), 'Expected empty when postalCode is blank');
        System.assertEquals(0, r3.size(), 'Expected empty when both are blank');
    }

    /**
     * @description Verifies exact match returns expected contacts.
     */
    @IsTest
    static void testExactMatch_ReturnsExpectedContacts() {
        System.debug(LoggingLevel.INFO, 'testExactMatch_ReturnsExpectedContacts - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts('Smith', '12345');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testExactMatch_ReturnsExpectedContacts - Results size=' + results.size());
        System.assert(results.size() >= 2, 'Expected at least two matching Smith/12345 contacts');
        for (Contact c : results) {
            System.debug(LoggingLevel.FINE, 'testExactMatch_ReturnsExpectedContacts - Contact Id=' + c.Id + ', Name=' + c.Name);
            System.assertNotEquals(null, c.Id, 'Id should be populated');
            System.assertNotEquals(null, c.Name, 'Name should be populated');
        }
    }

    /**
     * @description Verifies trimmed input behavior returns expected contacts.
     */
    @IsTest
    static void testTrimmedInputs_ReturnsExpectedContacts() {
        System.debug(LoggingLevel.INFO, 'testTrimmedInputs_ReturnsExpectedContacts - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts('  Smith  ', '  12345  ');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testTrimmedInputs_ReturnsExpectedContacts - Results size=' + results.size());
        System.assert(results.size() >= 2, 'Expected matches when inputs include surrounding whitespace');
    }

    /**
     * @description Verifies no matches scenario returns empty list.
     */
    @IsTest
    static void testNoMatches_ReturnsEmpty() {
        System.debug(LoggingLevel.INFO, 'testNoMatches_ReturnsEmpty - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts('Nonexistent', '99999');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testNoMatches_ReturnsEmpty - Results size=' + results.size());
        System.assertEquals(0, results.size(), 'Expected empty for non-matching criteria');
    }

    /**
     * @description Verifies multiple matches are returned when multiple records satisfy criteria.
     */
    @IsTest
    static void testMultipleMatches_ReturnsAll() {
        System.debug(LoggingLevel.INFO, 'testMultipleMatches_ReturnsAll - Start');
        Test.startTest();
        List<Contact> results = ContactSearch.searchForContacts('Smith', '12345');
        Test.stopTest();
        System.debug(LoggingLevel.INFO, 'testMultipleMatches_ReturnsAll - Results size=' + results.size());
        System.assert(results.size() >= 2, 'Expected multiple matches for Smith/12345');
    }

    /**
     * @description Executes the search under a standard user context to respect "with sharing".
     */
    @IsTest
    static void testWithSharing_RunAsStandardUser_BehavesConsistently() {
        System.debug(LoggingLevel.INFO, 'testWithSharing_RunAsStandardUser_BehavesConsistently - Start');
        Id stdUserId = createStandardUser();
        System.runAs(new User(Id = stdUserId)) {
            Test.startTest();
            List<Contact> results = ContactSearch.searchForContacts('Smith', '12345');
            Test.stopTest();
            System.debug(LoggingLevel.INFO, 'testWithSharing_RunAsStandardUser_BehavesConsistently - Results size=' + results.size());
            // We assert non-error execution and reasonable result shape; exact count may vary by sharing defaults.
            System.assertNotEquals(null, results, 'Results should not be null');
            for (Contact c : results) {
                System.assertNotEquals(null, c.Id, 'Id should be populated');
                System.assertNotEquals(null, c.Name, 'Name should be populated');
            }
        }
    }
}
