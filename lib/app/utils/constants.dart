class AppConstants {
  // --- Cloudinary Credentials ---
  static const String cloudinaryCloudName = 'dn2juvb5i'; // Your Cloudinary Cloud Name
  static const String cloudinaryUploadPreset = 'unsigned_preset'; // Your Cloudinary Upload Preset
  static const String cloudinaryBaseUrl = 'https://api.cloudinary.com/v1_1/';
  static const String cloudinaryUploadUrl = '$cloudinaryBaseUrl$cloudinaryCloudName/image/upload';

// --- Cloudinary Folder Names ---
  static const String storeLogosFolder = 'store_logos'; // New constant for store logos
  static const String productsFolder = 'products'; // Good to make this explicit now
  static const String offersFolder = 'offers'; // For future use
  static const String offerBannersFolder = 'offer_banners'; // <--- NEW folder for offer banners

  // --- Firestore Collection Names ---
  static const String storesCollection = 'stores';
  static const String productsCollection = 'products';
  static const String offersCollection = 'offers'; // For future use
  // You might also add sub-collections if you use them often
  // static const String productImagesSubCollection = 'images';


  // --- Firestore Document Field Names (Offer specific) ---
  static const String offerTitleField = 'title'; // <--- NEW
  static const String offerDescriptionField = 'description'; // <--- NEW
  static const String offerTypeField = 'type'; // <--- NEW (e.g., 'percentage', 'amount')
  static const String offerValueField = 'value'; // <--- NEW (e.g., 10 for 10% or $5)
  static const String offerStartDateField = 'start_date'; // <--- NEW
  static const String offerEndDateField = 'end_date'; // <--- NEW
  static const String offerIsActiveField = 'is_active'; // <--- NEW (default true)
  static const String offerBannerImageUrlField = 'banner_image_url'; // <--- NEW


  // --- Firestore Document Field Names (Commonly used) ---
  static const String createdByField = 'created_by';
  static const String logoUrlField = 'logo_url';
  static const String nameField = 'name';
  static const String descriptionField = 'description';
  static const String phoneField = 'phone';
  static const String cityField = 'city';
  static const String locationField = 'location';
  static const String socialField = 'social';
  static const String createdAtField = 'created_at';
  static const String updatedAtField = 'updated_at';
  static const String imagesField = 'images'; // For product images
  static const String priceField = 'price';
  static const String categoryField = 'category';
  static const String storeIdField = 'store_id'; // To link products/offers to stores
  static const String isAvailableField = 'is_available'; // For products

  // --- Other potentially useful constants ---
  static const Duration snackbarDuration = Duration(seconds: 3);

  static const List<String> offerTypes = ['percentage', 'fixed'];
}
