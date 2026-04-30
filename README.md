# Country Explorer App

## Student Details

- **Full Name**: Kaleab Bantayehu
- **Student ID**: ATE/0365/15
- **Institution**: Addis Ababa University
- **Course**: Mobile Application Development (Unit 4)

## Project Description

The Country Explorer App is a Flutter-based mobile application that fetches and displays country data using the RestCountries API. It demonstrates key concepts in mobile app development, including REST API integration, JSON parsing, asynchronous programming, and user interface design. The app allows users to browse a list of countries, search for specific countries, and view detailed information about each country. It incorporates robust error handling for network issues and provides a smooth user experience with loading states and caching mechanisms.

## Features

- List of all countries with pagination (Load More functionality)
- Search countries by name with debouncing to prevent excessive API calls
- Detailed country information including capital, population, languages, currencies, area, timezones, and flag
- Error handling for network issues, timeouts, and API errors
- Loading states using FutureBuilder for asynchronous operations
- Local in-memory caching with a 5-minute TTL for improved performance
- Responsive UI with Material Design 3 components

## Tech Stack

- Flutter
- Dart
- http package
- RestCountries API

## API Information

- **Base URL**: https://restcountries.com/v3.1
- **Endpoints**:
  - `/all?fields=name,flags,region,population,cca3` - Fetch all countries with selected fields
  - `/name/{name}` - Search countries by name
  - `/alpha/{code}` - Fetch country details by 3-letter code

## How to Run the Project

1. Ensure Flutter SDK is installed on your system.
2. Clone or download the project repository.
3. Navigate to the project directory.
4. Run `flutter pub get` to install dependencies.
5. Run `flutter run` to launch the app on a connected device or emulator.
6. An internet connection is required for API calls.

## Project Structure

```
lib/
  main.dart
  models/
    country.dart
  services/
    api_exception.dart
    country_api_service.dart
  screens/
    detail_screen.dart
    home_screen.dart
    search_screen.dart
```

## Error Handling

The app implements comprehensive error handling for various network scenarios:

- **SocketException**: Handles cases of no internet connection with user-friendly messages.
- **TimeoutException**: Manages request timeouts with retry mechanisms.
- **ApiException**: Custom exceptions for API-specific errors, including status code handling.
- **Generic error fallback**: Catches unexpected errors and provides informative messages to users.

## Limitations

- The app requires an active internet connection as it relies on the RestCountries API.
- Caching is implemented in-memory only and does not persist across app restarts.
- The search functionality is case-sensitive and matches country names exactly.

## Notes

- No API keys are required for this project.
- The application is built for educational purposes to demonstrate Flutter development concepts.
- The code follows clean architecture principles with separation of concerns between models, services, and UI layers.
