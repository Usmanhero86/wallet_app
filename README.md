# Wallet App - Zainpay API Demo

This is a Flutter application built to demonstrate connecting to the Zainpay API, handling state with Provider, and building a user-friendly mobile interface.

## Features Implemented

*   **Mock Login:** A simple login screen to demonstrate navigation.
*   **Dashboard:** Displays wallet balance and a list of recent transactions.
*   **Create Virtual Account:** A form to create a new virtual account via a POST request.
*   **State Management:** Uses `provider` for managing application state, including loading and error states.

**Bonus Features:**
*   Light/Dark mode toggle.
*   Pull-to-refresh on the dashboard.
*   Local data caching using `shared_preferences`.
*   Reusable UI components for consistency.

## Setup Instructions

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Run the app: `flutter run`.

## API Endpoints Used

*   **GET** `/zainbox/wallet-balance`: To fetch the user's wallet balance.
*   **GET** `/zainbox/transactions/list`: To fetch a list of recent transactions.
*   **POST** `/zainbox/virtual-account/create/reserved`: To create a new dedicated virtual account.

## Notes
*   The login screen is mocked and does not perform real authentication.
*   The charting bonus feature was not implemented.


