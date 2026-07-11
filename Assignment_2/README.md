# CSE489 Assignment 2 – Android Mobile Application

## Overview

This project is developed as part of **CSE489: Mobile Application Development**.

The objective of this assignment is to practice Android application development using:

- Navigation Drawer
- Fragments
- Broadcast Receivers
- Android Jetpack principles
- Gesture Detection
- Media Playback

The application provides multiple Android components through a Navigation Drawer interface.

---

## Features

### 1. Broadcast Receiver

Users can select one of two broadcast operations.

#### Option 1 – Custom Broadcast Receiver

Flow:

- Select **Custom Broadcast Receiver**
- Enter a text message
- Send the custom broadcast
- Display the received message in the receiver activity

#### Option 2 – Battery Broadcast Receiver

Flow:

- Select **Battery Broadcast Receiver**
- Receive and display the current battery percentage using the system battery broadcast.

---

### 2. Image Scaling

- Loads an image from the Internet
- Supports pinch-to-zoom gesture
- Users can zoom in and out smoothly

---

### 3. Video Player

- Plays a video inside the application
- Uses Android MediaPlayer/VideoView

---

### 4. Audio Player

- Plays an audio file inside the application
- Supports standard media controls

---

## Navigation Drawer Menu

```
Navigation Drawer
│
├── Broadcast Receiver
│   ├── Custom Broadcast Receiver
│   └── Battery Broadcast Receiver
│
├── Image Scale
│
├── Video Player
│
└── Audio Player
```

---

## Technologies Used

- Java
- Android Studio
- Android SDK
- Navigation Drawer
- Activities
- Fragments
- Broadcast Receiver
- Intent
- Gesture Detector
- MediaPlayer
- VideoView

---

## Project Structure

```
app/
│
├── activities/
│   ├── MainActivity
│   ├── BroadcastSelectionActivity
│   ├── CustomInputActivity
│   ├── BroadcastReceiverActivity
│   ├── ImageScaleActivity
│   ├── VideoActivity
│   └── AudioActivity
│
├── receivers/
│   ├── CustomBroadcastReceiver
│   └── BatteryBroadcastReceiver
│
├── adapter/
│
├── utils/
│
└── res/
```

---

## Application Flow

```
MainActivity
      │
      ▼
Navigation Drawer
      │
      ├──────────────► Broadcast Receiver
      │                     │
      │                     ▼
      │              Select Broadcast
      │               │            │
      │               │            │
      │        Custom Receiver   Battery Receiver
      │               │            │
      │               ▼            ▼
      │        Enter Message   Receive Battery %
      │               │
      │               ▼
      │       Receive Custom Broadcast
      │
      ├──────────────► Image Scale
      │
      ├──────────────► Video Player
      │
      └──────────────► Audio Player
```

---

## Learning Outcomes

Through this assignment, the following Android concepts were practiced:

- Navigation Drawer implementation
- Activity navigation
- Android Broadcast Receivers
- Custom Intent Broadcasts
- System Broadcasts
- Pinch Gesture Detection
- Media Playback
- Android Jetpack design philosophy

---

## References

- Android Broadcast Receiver Documentation  
  https://developer.android.com/guide/components/broadcasts

- Vogella Broadcast Receiver Tutorial  
  https://www.vogella.com/tutorials/AndroidBroadcastReceiver/article.html

- Android Battery Changed Intent  
  https://developer.android.com/reference/android/content/Intent#ACTION_BATTERY_CHANGED

- Android Jetpack Learning Resources  
  https://github.com/androiddevnotes/awesome-jetpack-compose-learning-resources

---

## Course Information

**Course:** CSE489 – Mobile Application Development

**Assignment:** Assignment 2

**Department:** Computer Science and Engineering

---
