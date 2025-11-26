public class BadPracticeExample {

    public void processAccounts(List<Account> accounts) {
        for (Account acc : accounts) { // SOQL query inside loop
            Account existingAccount = [SELECT Id, Name FROM Account WHERE Name = :acc.Name LIMIT 1]; 
            if (existingAccount != null) {
                existingAccount.Description = 'Updated by BadPracticeExample';
                update existingAccount; // DML inside loop
            } else {
                insert acc; // DML inside loop
            }
        }

        // Unnecessary nested loops
        List<Contact> allContacts = [SELECT Id, AccountId FROM Contact];
        for (Account acc : accounts) {
            for (Contact con : allContacts) {
                if (con.AccountId == acc.Id) {
                    // Do something with matching contacts (inefficient)
                    System.debug('Found contact for account: ' + acc.Name);
                }
            }
        }
    }

    public void doSomethingSimple() {
        // Hardcoded ID - prone to errors in different environments
        Id hardcodedId = '001XXXXXXXXXXXX'; 
        Account singleAccount = [SELECT Name FROM Account WHERE Id = :hardcodedId];
        System.debug('Account name: ' + singleAccount.Name);
    }
}