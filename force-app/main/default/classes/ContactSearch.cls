/**
 * @description Public utility class for searching Contact records by last name and mailing postal code.
 *              Returns a list of Contact records containing only Id and Name fields.
 * @author Agentforce
 * @date 2025-11-26
 */
public with sharing class ContactSearch {

    /**
     * @description Searches for Contacts that match both the provided last name and mailing postal code.
     *              Ensures parameters are not null or blank (after trim). Returns a new list of Contact
     *              records (Id and Name fields) that satisfy both criteria.
     *
     * @param lastName   The Contact LastName value to match (exact match).
     * @param postalCode The Contact MailingPostalCode value to match (exact match).
     * @return List<Contact> A list of Contact records with Id and Name fields populated.
     */
    public static List<Contact> searchForContacts(String lastName, String postalCode) {
        // Debug: input parameters received
        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Inputs received: lastName=' + lastName + ', postalCode=' + postalCode);

        // Initialize the results list (as requested, create new list explicitly)
        List<Contact> results = new List<Contact>();

        // Validate inputs: both parameters must be provided and not blank after trim
        Boolean isLastNameBlank = (lastName == null || String.isBlank(lastName.trim()));
        Boolean isPostalBlank = (postalCode == null || String.isBlank(postalCode.trim()));
        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Validation: isLastNameBlank=' + isLastNameBlank + ', isPostalBlank=' + isPostalBlank);

        if (isLastNameBlank || isPostalBlank) {
            System.debug(LoggingLevel.WARN, 'ContactSearch.searchForContacts - Invalid input. Returning empty results.');
            return results; // return early with empty list
        }

        // Trim inputs for exact matching
        String ln = lastName.trim();
        String pc = postalCode.trim();
        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Using trimmed values: lastName=' + ln + ', postalCode=' + pc);

        // Perform SOQL to find matching Contacts (no WITH SECURITY_ENFORCED per instruction)
        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Executing SOQL query...');
        List<Contact> queried = [
            SELECT Id, Name
            FROM Contact
            WHERE LastName = :ln
              AND MailingPostalCode = :pc
        ];
        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Query returned ' + queried.size() + ' row(s).');

        // Store each returned record in the explicitly defined list
        for (Contact c : queried) {
            results.add(c);
            System.debug(LoggingLevel.FINE, 'ContactSearch.searchForContacts - Added Contact: Id=' + c.Id + ', Name=' + c.Name);
        }

        System.debug(LoggingLevel.INFO, 'ContactSearch.searchForContacts - Returning ' + results.size() + ' result(s).');
        return results;
    }
}
