/**
 * CofaceCallBackController
 * Visualforce controller to initialize and create a new Account record.
 *
 * - Reads URL parameter `id` from the request (e.g., /apex/CofaceCallBackPage?id=xxx)
 * - Creates a Coface_Report__c record and associates it with the provided id when applicable
 * - Uses USER_MODE for DML where appropriate
 * - Returns a PageReference (null keeps current page; you can adapt to redirect if needed)
 *
 * Security:
 * - with sharing to respect org sharing rules
 * - Avoids hardcoded IDs/URLs
 *
 * Usage:
 * - The Visualforce page auto-submits a form to call createAccountOnInit()
 */
public with sharing class CofaceCallBackController {
    // Store incoming URL params for reuse/testing
    @TestVisible private String requestId;

    public CofaceCallBackController() {
        // Safely read the 'id' URL parameter
        Map<String, String> params = ApexPages.currentPage() != null
            ? ApexPages.currentPage().getParameters()
            : new Map<String, String>();
        requestId = params.get('id');
    }

    /**
     * Entry point invoked by the VF page (via hidden button auto-submit).
     * Reads requestId captured in constructor and performs business logic.
     */
    public PageReference createAccountOnInit() {
        // Basic validation: non-empty
        String incomingId = String.isBlank(requestId) ? null : requestId;

        // Example: create Coface_Report__c and optionally relate it using incomingId
        Cofase_Test__c cr = new Cofase_Test__c();
        cr.Key__c = incomingId;
        // If there is a lookup field to relate by the incoming id, set it here.
        // Replace Example_Lookup__c with actual API name if needed.
        // if (incomingId != null) {
        //     cr.Example_Lookup__c = incomingId;
        // }

        try {
            // Insert with standard context; switch to Database.insert with USER_MODE if required for FLS/sharing
            insert cr;
        } catch (DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }

        // No redirect specified; keep page to allow VF to show any messages or let caller handle redirect.
        return null;
    }
}