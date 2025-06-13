service cloud.firestore {
  match /databases/{database}/documents {

    // Helper Functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserId() {
      return request.auth.uid;
    }

    function isAdmin() {
      // Replace with actual check for admin users
      return getUserId() == 'admin_user_id';  // Example: You can add your actual admin check here
    }

    function isStoreOwner(storeId) {
      return isAuthenticated() &&
             exists(/databases/$(database)/documents/stores/$(storeId)) &&
             get(/databases/$(database)/documents/stores/$(storeId)).data.created_by == getUserId();
    }

    // Store Collection Rules
    match /stores/{storeId} {
      // Create: Only Admin can create a store
      allow create: if isAdmin();

      // Read: Anyone can read a store
      allow read: if true;

      // Update: Only Store Owner and Admin can update store data
      allow update: if isStoreOwner(storeId) || isAdmin();

      // Delete: Only Store Owner and Admin can delete a store
      allow delete: if isStoreOwner(storeId) || isAdmin();
    }

    // Products Collection Rules
    match /products/{productId} {
      // Read: Anyone can read a product
      allow read: if true;

      // Create: Only the Store Owner and Admin can create a product
      allow create: if isAuthenticated() && isStoreOwner(request.resource.data.store_id) || isAdmin();

      // Update/Delete: Only the Store Owner and Admin can update or delete a product
      allow update, delete: if isAuthenticated() && isStoreOwner(resource.data.store_id) || isAdmin();
    }

    // Offers Collection Rules
    match /offers/{offerId} {
      // Read: Anyone can read an offer
      allow read: if true;

      // Create: Only the Store Owner and Admin can create an offer
      allow create: if isAuthenticated() && isStoreOwner(request.resource.data.store_id) || isAdmin();

      // Update/Delete: Only the Store Owner and Admin can update or delete an offer
      allow update, delete: if isAuthenticated() && isStoreOwner(resource.data.store_id) || isAdmin();
    }
  }
}
