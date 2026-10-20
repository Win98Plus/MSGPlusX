# MSGPlusX (v1.1) — Source Code

**MSGPlusX** is a feature customization tweak for **Facebook Messenger** (`com.facebook.Messenger`) on iOS (`arm64`, iOS 15.0+). It integrates a native `PSListController` settings interface, a custom 3-column alternate app icon picker, privacy controls, media utilities, and tab bar customization.

## Architecture & Project Structure

| File | Role |
| :--- | :--- |
| `Tweak.xm` | Logos hooks across 17 Messenger and UIKit/Intents classes, update checker, and `MSGIconPickerController` implementation |
| `MSGSettingsViewController.h` | Public interfaces for `MSGSettingsViewController`, `MSGIconPickerController`, `MSGButtonTableViewCell`, and `MSGSwitchTableCell` |
| `MSGSettingsViewController.m` | `PSListController` settings panel, custom `UIStackView`-based table cells, `NSUserDefaults` persistence, and device/bundle diagnostics |
| `Makefile` | Theos build configuration targeting `iphone:clang:latest:15.0` |
| `control` | Debian package metadata (`com.densor.msgplusx`, version `1.1.0`) |
| `MSGPlusX.plist` | MobileSubstrate filter targeting `com.facebook.Messenger` |

## Feature Matrix & NSUserDefaults Keys

| Category | Feature Title | `NSUserDefaults` Key | Default | Hooked Class & Selector |
| :--- | :--- | :--- | :--- | :--- |
| **Chat** | View Photos Unlimited | `unlimited_photos` | `YES` | `LSMediaViewController -markViewOnceMessageAsOpened:` (`mediaType != 9`) |
| **Chat** | View Videos Unlimited | `unlimited_videos` | `YES` | `LSMediaViewController -markViewOnceMessageAsOpened:` (`mediaType == 9`) |
| **Chat** | Read Chats Anonymously | `read_chats_anonymously` | `YES` | `MSGMessageListViewController -viewDidLoad` (`_disableReadReceipts = YES`) |
| **Chat** | Download photos [HD] | `download_photos` | `NO` | `LSNetworkImageView -layoutSubviews` (0.5s long-press saves via `UIImageWriteToSavedPhotosAlbum`) |
| **Chat** | Download videos | `download_videos` | `NO` | `LSMediaVideoViewController -viewDidLoad` (0.5s long-press triggers `-shareMedia`) |
| **Chat** | Loop videos | `loop_videos` | `NO` | `LSMediaVideoViewController -playDidEnd` (calls `-mediaVideoControlsViewDidTapPlay:`) |
| **Chat** | No Screenshot Detection | `no_screenshot_detection` | `NO` | `MSGApplication -_handleScreenshot` |
| **Chat** | Upload videos as voice messages | `uploadvideos_voice` | `NO` | `MSGVoiceClipCreationViewController -viewDidAppear:` (`AVAssetExportPresetAppleM4A` to `MSGPlusXVoice.ogg`) |
| **Chat** | Upload photos in HD | `upload_hd_photos` | `NO` | `LSMediaPickerViewController -viewDidLoad` (calls `-_didTapHDToggle:`) |
| **Stories** | Watch stories anonymously | `watch_stories_anonymously` | `NO` | `LSStoryBucketViewController -startTimer` (`objc_msgSendSuper` to `LSStoryBucketViewControllerBase`) |
| **Stories** | Remove Tray Stories | `remove_trays_stories` | `NO` | `MSGInboxTrayViewController` (`-_setInboxTrayItems:`, `-_didFetchInboxUnitItems:`, `-inboxTrayDataManagerDidReceiveUpdate:`) |
| **Stories** | Hide Reply Bar | `hide_reply_bar` | `NO` | `LSStoryBucketViewController -_addReplyBarViewController` |
| **Confirmation** | Call Confirmation | `call_confirmation` | `NO` | `LSRTCCallButton -handleButtonTap` |
| **TABS** | Hide 'Stories' tab | `hide_Stories` | `NO` | `UITabBar` & `_TtC15MDSModernTabBar15MDSModernTabBar -setItems:animated:` (`tabbar-stories`) |
| **TABS** | Hide 'Menu' tab | `hide_Menu` | `NO` | `UITabBar` & `_TtC15MDSModernTabBar15MDSModernTabBar -setItems:animated:` (`tabbar-more-menu`) |
| **TABS** | Hide 'Notifications' tab | `hide_Notifications` | `NO` | `UITabBar` & `_TtC15MDSModernTabBar15MDSModernTabBar -setItems:animated:` (`tabbar-jewel-notification-menu`) |
| **TABS** | Hide 'Chats' tab | `hide_chats` | `NO` | `UITabBar` & `_TtC15MDSModernTabBar15MDSModernTabBar -setItems:animated:` (`tabbar-chats`) |
| **Icons** | Alternate App Icon | `MSGSelectedAppIcon` | `AppIcon60x60` | `MSGIconPickerController`, `UIApplication -setAlternateIconName:completionHandler:`, `UIAlertController` |
| **Sideload Fix** | SiriKit Crash Prevention | — | Always On | `INVocabulary +sharedVocabulary` (returns `nil`) |

## Entry Points for Settings UI

1. **Top Navigation Wordmark**: `MSGMessengerWordmarkView -layoutSubviews` hides the default `_imageView`, injects a bold `MSGPLusX` label (`tag = 9911`), and attaches a `UITapGestureRecognizer` (`msgWordmarkTap`) that opens `MSGSettingsViewController` in a full-screen `UINavigationController`.
2. **Tab Bar Item**: `UITabBar -setItems:animated:` appends a `UITabBarItem` titled `MSG+` (`staroflife.fill`, `tag = 99`) that opens `MSGSettingsViewController` when selected.

## Building from Source

### Prerequisites

* [Theos](https://www.google.com/search?q=https%3A%2F%2Ftheos.dev) installed with `$THEOS` configured
* iOS SDK (`iPhoneOS15.0.sdk` or newer) with private `Preferences.framework` headers

### 1. Build Rootful `.deb` (Standard Jailbreak)

```bash
make clean package FINALPACKAGE=1
```

### 2. Build Rootless `.deb` (Dopamine / palera1n Rootless)

```bash
make clean package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
```

### 3. Build Standalone `.dylib` for Sideloading & LiveContainer

After running `make`, copy the compiled dynamic library from `.theos/obj/debug/MSGPlusX.dylib` (or `.theos/obj/MSGPlusX.dylib` when `FINALPACKAGE=1` is set). For non-jailbroken IPA injection (Feather, ESign, Sideloadly, Azule, or LiveContainer), ensure `CydiaSubstrate.framework/CydiaSubstrate` is rewritten to `@executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate` via `install_name_tool` if required by your signer.
