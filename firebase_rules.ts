rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if a user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function to get the authenticated user's UID
    function getUserId() {
      return request.auth.uid;
    }

    // Helper function to check if the user is the owner of a given storeId
    function isStoreOwner(storeId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/stores/$(storeId)).data.created_by == getUserId();
    }

    // Rules for the 'stores' collection
    match /stores/{storeId} {
      // Allow creating a store if the user is authenticated and setting the 'created_by' field correctly
      allow create: if isAuthenticated() && request.resource.data.created_by == getUserId();

      // Allow reading the store if the user is authenticated and owns the store (based on 'created_by')
      allow read: if isAuthenticated() && resource.data.created_by == getUserId();

      // Allow updating and deleting a store if the user is authenticated and is the owner of the store
      allow update, delete: if isStoreOwner(storeId);
    }

    // Rules for the 'products' collection (top-level)
    match /products/{productId} {
      // Allow any authenticated user to read products
      allow read: if isAuthenticated();

      // Allow creating a product if the user is authenticated AND the 'store_id' belongs to a store they own
      allow create: if isAuthenticated() &&
        request.resource.data.store_id is string &&
        isStoreOwner(request.resource.data.store_id);

      // Allow updating or deleting a product if the user is authenticated AND the 'store_id' belongs to a store they own
      allow update, delete: if isAuthenticated() &&
        resource.data.store_id is string &&
        isStoreOwner(resource.data.store_id);
    }

    // Rules for the 'offers' collection (TOP-LEVEL)
    match /offers/{offerId} {
      // Allow any authenticated user to read offers
      allow read: if isAuthenticated();

      // Allow creating an offer if the user is authenticated AND the 'store_id' belongs to a store they own
      allow create: if isAuthenticated() &&
        request.resource.data.store_id is string &&
        isStoreOwner(request.resource.data.store_id);

      // Allow updating or deleting an offer if the user is authenticated AND the 'store_id' belongs to a store they own
      allow update, delete: if isAuthenticated() &&
        resource.data.store_id is string &&
        isStoreOwner(resource.data.store_id);
    }
  }
}
