







# 📨 Feedback  
*A multiplatform feedback assistant inspired by Apple’s native Feedback app – built with SwiftUI, Core Data, CloudKit, and more.*

![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?logo=swift)  
![Platform Support](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey?logo=apple)  
![iCloud Sync](https://img.shields.io/badge/CloudKit-Enabled-brightgreen?logo=icloud)  
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## 🚀 Overview

**Feedback** is a polished, multiplatform app designed to help users submit, organize, and track feedback. Inspired by Apple’s Feedback Assistant, it works natively across macOS and iOS using SwiftUI and a unified Core Data + CloudKit stack.

This app was built by applying every skill learned from the Ultimate Portfolio App course and refining it with real-world engineering decisions, platform-specific design, and a strong focus on user experience and sync reliability.

---

## 🧱 Technologies Used

- **SwiftUI** for declarative, cross-platform UI
- **Core Data** for local persistence
- **CloudKit** for seamless iCloud sync
- **App Groups** for data sharing across extensions
- **Spotlight Integration** for search
- **StoreKit** for in-app purchase (optional)
- **Accessibility** + **Localization** for global, inclusive design

---

## ✍️ My Journey

> Building *Feedback* wasn't just a coding exercise — it was an end-to-end app development experience.  
> From setting up CloudKit to solving macOS permission quirks, every obstacle sharpened my development skills.

---

## 🔧 Development Challenges and Resolutions

### 🧩 Challenge #1: CloudKit & Core Data Synchronization

**Problem:**  
Syncing Core Data via CloudKit worked well on iOS — but broke silently on macOS due to missing defaults and framework links.

**Solution:**  
- Audited every entity and made all attributes optional or gave them default values  
- Manually linked `CloudKit.framework` on macOS to avoid missing dependency issues

---

### 🔐 Challenge #2: App Group Permissions (macOS 15)

**Problem:**  
macOS 15 introduced stricter privacy rules — the app couldn’t access shared data without full disk access.

**Solution:**  
- Added robust error handling when permission was denied  
- Provided clear in-app instructions guiding users to System Settings → Privacy & Security → Full Disk Access

---

### 💡 Challenge #3: Cross-Platform UI Consistency

**Problem:**  
SwiftUI behaves differently on macOS and iOS (e.g., NavigationSplitView and Toolbars)

**Solution:**  
- Modularized UI using reusable views  
- Used `#if os(macOS)` and `#if os(iOS)` to tailor views per platform

---

### ⚠️ Challenge #4: Duplicate Default Data on First Launch

**Problem:**  
If users launched the app on multiple devices before CloudKit synced, it created duplicate entries.

**Solution:**  
- Checked for existing feedback records in iCloud before adding defaults  
- Made onboarding idempotent and smart

---

## ✨ Key Features

- Submit, edit, and organize feedback items  
- Real-time iCloud sync across iOS and macOS  
- Spotlight search support for fast access  
- Tag feedback with customizable statuses  
- Share feedback with other apps  
- Native dark mode support  
- SwiftUI widgets on all platforms  
- Optional in-app purchases (StoreKit-ready)  
- Fully localized and accessibility-tested

---

## 📦 Installation

> **Requirements**  
> - macOS 13+ or iOS 16+  
> - Xcode 15 or later  
> - Apple Developer Account with iCloud enabled

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/sahaj1519/Feedback_APP.git
   cd FeedbackApp

👤 Author

Ajay
iOS & macOS Developer
[LinkedIn](https://www.linkedin.com/in/ajay-sangwan-601171348) · [GitHub](https://github.com/sahaj1519)




MIT License

Copyright (c) 2025 [Ajay]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell   
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:                    

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.                             

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER     
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         
DEALINGS IN THE SOFTWARE.


