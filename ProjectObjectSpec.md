Create a custom object called 'Project__c' with the following details:
- Object Name: Project__c
- Object Label: Project
- Object Plural Label: My Projects

Fields:
- Project Name (nameField: Text, required, label:Project Name
- Start Date (Date)
- End Date (Date)
- Project Manager (Lookup to User)
- Status (Picklist= New, In Progress, Completed, On Hold)
- Budget (Currency precision=16, scale=2)

Additional Metadata:
- deploymentStatus: Deployed
- sharingModel: ReadWrite
- enableActivities: true
- enableReports: true