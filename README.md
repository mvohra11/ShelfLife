# ShelfLife 💄

Keep track of your beauty routine with ShelfLife!  Built with Swift & Xcode, this iOS app uses the Makeup API to help you catalog your collection and stay organized.  Never use expired products again with custom shelf-life tracking and automated expiration notifications.

## ✨ Features

- **Product Catalog**: Browse and add makeup products from the Makeup API
- **Collection Management**: Keep track of all your beauty products in one place
- **Shelf-Life Tracking**: Set custom expiration dates for each product
- **Smart Notifications**: Get automated alerts before your products expire
- **Organization**: Stay on top of your beauty routine and product freshness

## 🛠️ Tech Stack

- **Language**: Swift
- **IDE**: Xcode
- **API**: [Makeup API](http://makeup-api.herokuapp.com/)
- **Platform**: iOS

### iOS Frameworks & Technologies

- **UIKit**: Core UI framework for building the interface
- **Core Data**: Local persistent storage for product collection
  - `NSPersistentContainer` for data stack management
  - `NSFetchedResultsController` for efficient data fetching
- **UICollectionView**: Grid layout for browsing product categories
- **UITableView**: List display for products and user's shelf
- **UISearchController**: Real-time search functionality across products
- **UIImagePickerController**: Camera and photo library integration for product photos
  - Camera capture support
  - Photo library selection
- **UserNotifications (UNUserNotificationCenter)**: Local push notifications for expiration alerts
  - Permission handling
  - Scheduled calendar-based notifications
- **URLSession**: Asynchronous API networking with the Makeup API
- **UIDatePicker**: Date selection for product expiration tracking
- **UIPickerView**: Category selection interface
- **UIActivityIndicatorView**: Loading indicators during data fetches
- **FileManager**: Local image file storage and retrieval
- **Segues & Navigation**: Storyboard-based navigation flow

### Architecture Patterns

- **MVC (Model-View-Controller)**: Standard iOS architecture
- **Delegate Pattern**: For database listeners and UI component communication
- **Protocol-Oriented Design**: `DatabaseProtocol` for data layer abstraction
- **Multicast Delegates**: For managing multiple database listeners

## 🚀 Getting Started

### Prerequisites

- Xcode (latest version recommended)
- iOS device or simulator
- Swift 5.0 or later

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/mvohra11/ShelfLife.git
   ```

2. Open the project in Xcode
   ```bash
   cd ShelfLife
   open ShelfLife.xcodeproj
   ```

3. Build and run the project
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## 📱 Usage

1. **Browse Products**:  Explore makeup products from the Makeup API
2. **Add to Collection**: Save products to your personal collection
3. **Set Expiration Dates**: Track when you opened each product and set custom shelf-life periods
4. **Receive Notifications**: Get timely reminders before products expire

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**mvohra11**
- GitHub: [@mvohra11](https://github.com/mvohra11)

## 🙏 Acknowledgments

- [Makeup API](http://makeup-api.herokuapp.com/) for providing the product data

---

**Note**: This app helps track product expiration dates based on general guidelines and user input. Always follow manufacturer recommendations for specific products. 
