
// USER APP ONLY READ ONLY ACCESS FOR NOW
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ========== Helpers ==========
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserId() {
      return request.auth.uid;
    }

    function isStoreOwner(storeId) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/stores/$(storeId)).data.created_by == getUserId();
    }

    // ========== STORES ==========
    match /stores/{storeId} {
      // Public users (unauthenticated) can read public fields only
      allow get, list: if true;

      // Prevent reading sensitive fields like `created_by` in the user app
      allow get: if !(request.auth == null) || !(request.resource.data.keys().hasAny(['created_by']));

      // Only owners can write/update/delete
      allow create: if isAuthenticated() &&
        request.resource.data.created_by == getUserId();

      allow update, delete: if isStoreOwner(storeId);
    }

    // ========== PRODUCTS ==========
    match /products/{productId} {
      // Anyone can read products
      allow read: if true;

      // Only store owners can create/update/delete
      allow create: if isAuthenticated() &&
        request.resource.data.store_id is string &&
        isStoreOwner(request.resource.data.store_id);

      allow update, delete: if isAuthenticated() &&
        resource.data.store_id is string &&
        isStoreOwner(resource.data.store_id);
    }

    // ========== OFFERS ==========
    match /offers/{offerId} {
      // Anyone can read offers
      allow read: if true;

      // Only store owners can create/update/delete
      allow create: if isAuthenticated() &&
        request.resource.data.store_id is string &&
        isStoreOwner(request.resource.data.store_id);

      allow update, delete: if isAuthenticated() &&
        resource.data.store_id is string &&
        isStoreOwner(resource.data.store_id);
    }
  }
}
