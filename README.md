# KawalTani App

## Overview

KawalTani is a Flutter-based mobile application designed to monitor and manage agricultural land data. It provides real-time environmental indicators, plant information, and task management for farmers, leveraging data from various sensors and APIs.

## Features

- **Dashboard**: Displays real-time data on temperature, humidity, wind, light, and rainfall.
- **Plant Information**: Shows details about crops, including commodity, variety, planting date, age, phase, and time to harvest.
- **Task Management**: Lists tasks and warnings based on sensor data and agricultural needs.
- **Site Selection**: Allows users to select different agricultural sites/locations.
- **Data Visualization**: Includes charts for temperature and humidity trends using `fl_chart`.
- **Secure Authentication**: Uses `flutter_secure_storage` for managing user sessions and site IDs.
- **Animations**: Implements smooth UI transitions with `flutter_animate`.

## Tech Stack

- **Frontend**: Flutter, Dart
- **Libraries**:
  - `fl_chart`: For data visualization
  - `flutter_secure_storage`: For secure storage of user data
  - `flutter_animate`: For UI animations
- **Backend**: Custom API service (`api_service.dart`) for fetching dashboard and real-time data

## Getting Started

### Prerequisites

- Flutter SDK (version 3.x or later)
- Dart
- Android Studio or VS Code with Flutter extensions
- A device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd kawaltani_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Configuration

- Ensure the API service (`lib/services/api_service.dart`) is configured with the correct backend endpoint.
- Add necessary assets (e.g., device images) to the `assets/image/` directory and update `pubspec.yaml` accordingly.

## Usage

1. **Login**: Authenticate using the login screen (`/login` route).
2. **Select Site**: Choose a site from the dropdown in the dashboard to view data.
3. **Monitor Data**: View real-time environmental data, plant details, and tasks.
4. **Interact with Charts**: Refresh the dashboard to update charts and sensor data.
5. **Logout**: Use the logout button to clear session data and return to the login screen.

## Project Structure

- `lib/screens/`: Contains UI screens (e.g., `dashboard_screen.dart`)
- `lib/services/`: API service for backend communication
- `lib/models/`: Data models (e.g., `dashboard_data.dart`)
- `assets/`: Static assets like images

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit changes (`git commit -m "Add feature"`).
4. Push to the branch (`git push origin feature-name`).
5. Create a pull request.

## License

This project is licensed under the MIT License.
