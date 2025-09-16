# MzadQatar Car Deals

A Flutter app to analyze and browse car deals from mzadqatar.com.

## Features

- Fetches car listings via API with pagination support
- Category-based filtering and browsing
- Detailed car information with specifications
- Comments and ratings system
- Related listings from the same seller
- Saves data locally with SQLite
- Shows average, minimum, and maximum prices
- Clean UI with detail view and enhanced navigation
- Pull-to-refresh functionality

## API Endpoints

### 1. Get Category Data
```dart
MzadQatarApi.getCategoryData({
  int page = 1,
  int limit = 20,
  String? category,
})
```
Returns paginated car listings with category information and filtering support.

### 2. Get Product Comments
```dart
MzadQatarApi.getProductComments(int productId)
```
Fetches comments and ratings for a specific car listing.

### 3. Get Product Details
```dart
MzadQatarApi.getProductDetails(int productId)
```
Returns comprehensive car details including specifications, seller information, and features.

### 4. Get Related User Ads
```dart
MzadQatarApi.getRelatedUserAds(String userId, {int limit = 10})
```
Fetches other listings from the same seller.

## Data Models

- **CarListing**: Basic car listing information
- **ProductDetails**: Comprehensive car details with specifications
- **Comment**: User comments with ratings
- **Category**: Car categories with counts

## Getting Started

1. Install dependencies:

   ```
   flutter pub get
   ```

2. Run the app:

   ```
   flutter run
   ```

3. Run tests:

   ```
   flutter test
   ```

4. (Optional) Replace the API endpoint in `lib/api/mzadqatar_api.dart` with your own source.

## UI Features

### Enhanced Listing Screen
- Category filter chips for easy browsing
- Infinite scroll pagination
- Pull-to-refresh functionality
- Improved card layout with better visual hierarchy

### Detailed Car View
- Image galleries with multiple car photos
- Comprehensive car specifications
- Seller contact information
- Comments section with ratings
- Related listings carousel
- Feature tags and highlights

### Database Integration
- Local storage for offline access
- Comment and category caching
- Data synchronization support

## Dependencies

- Flutter
- http (API communication)
- sqflite (local database)
- path (file path utilities)
