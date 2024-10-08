# RandomVocab

RandomVocab is an iOS app that helps users expand their vocabulary by displaying up to 5 unique words each day. For each word, users can view definitions, parts of speech, and pronunciation, with the option to listen to the pronunciation if an mp3 file is available.

## Features

- **Daily Words**: Get up to 5 unique words per day.
- **Word Details**: View the definition, part of speech, and pronunciation of each word.
- **Audio Pronunciation**: Listen to the pronunciation if an mp3 file is available.
- **Favorite Words**: Mark words as favorite and access all your favorite words on a single page.
- **Data Persistence**: Words and favorites are stored locally using **SwiftData**, a new iOS 17 feature for efficient data persistence.

## Technologies Used

- **Language**: Swift
- **UI Framework**: UIKit
- **Data Persistence**: SwiftData (iOS 17 feature)

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/SysCall97/RandomVocab.git
2. Open the project in Xcode:
   ```bash
    cd RandomVocab
    open RandomVocab.xcodeproj
3. Build and run the project on a device or simulator running iOS 17 or later.

## Screenshots

<table align="center">
  <tr>
    <td><img src="./Screenshots/homePage.png" alt="Home Page" width="200" /></td>
    <td><img src="./Screenshots/homePage_with_fav.png" alt="Home Page with Favorite" width="200" /></td>
    <td><img src="./Screenshots/favoritePage.png" alt="Favorite Page" width="200" /></td>
    <td><img src="./Screenshots/favoritePage_with_del_action.png" alt="Favorite Page with Delete Action" width="200" /></td>
  </tr>
  <tr>
    <td style="text-align: center;">(1) Home Page</td>
    <td style="text-align: center;">(2) Home Page with Favorite</td>
    <td style="text-align: center;">(3) Favorite Page</td>
    <td style="text-align: center;">(4) Favorite Page with Delete Action</td>
  </tr>
</table>



