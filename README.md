<img src="/calendarReminderLogo.png" width="200">

# calendar-reminder
A utility to remind you when a calendar event is coming up.

This project was oringinally inspired by a few other paid apps. I decided to make my own version of it. Obviously this app lacks a lot of polish but overtime I will try to make it as customisable and polished as possible. This app may never reach the quality of the paid apps, but one day it might, with your contributions on finding issues and improving upon them!

# Requirements
Minimum operating version macOS 15 or above

# How to use
First, create a calendar in your calendar app named Calendar Reminder exactly - note the space and the capitals. Create events using this calendar. Then, when the time comes, the app will automatically notify you with an onscreen popup.

Go into app settings>launch at login and the app will automatically launch at login.

Please note that the app not yet runs in the background. This will be fixed in a feature update.
Please note that the app is not signed. For more information on how to bypass this, see https://support.apple.com/en-gb/guide/mac-help/mh40616/mac. I am not enrolled into the $99/year apple developer program, hence I am not able to sign it.
Alternatively to bypass the signing problem, download source code and build app from source directly yourself using xcode.

# Troubleshooting
First try to restart the app. Quit the app using the menu bar (≥0.2.0) or using dock (≤0.1.2) and reopen it.

If menu bar icon cannot be seen, then you may be having too many menu bar icons. Try quitting other apps or disabling menu bar items in system settings > menu bar.

If it still does not work, try to update to the latest version using settings (≥0.2.0) or menu bar (≤0.1.2). See notes below for more information.

If the app still does not work, please first check for calendar permissions. If they are not granted the app will not work due to not being able to read your calendars.

To enable, first go into system settings, privacy and security, then full calendar access. Then enable the switch on calendar reminder.
The app is fully open source! If you don't trust the app, then go into the xcodeproj, then build from source yourself!

If after all the solutions above the app still does not work please kindly file an issue report on the repo. Thank you for your support.

# Quitting the app and updating
## Finding your app version
If you cannot see an app icon in the dock - go to menu the menu bar, find the calendar reminder icon, then click settings. Then click info in the tab bar and you will find the version number there.

If you can see an app icon in the dock - go to menu bar, click the calendar reminder name, then click info. The version number will be shown there.

## App versions 0.2.3 and above
Use the menu bar icon to quit the app.
To update the app, enter settings, go into the updates tab then click check for updates. The updator should then guide you to update to the latest version.

## App versions 0.2.0 to 0.2.2
Use the menu bar icon to quit the app. 
To update the app, enter settings, general, then check for updates. Updates should then be installed properly.

## App version below 0.1.2 (including 0.1.2)
Use the dock to quit the app.
Use the menu bar > calendar reminder to update the app.

## App version 0.1.1 
This version does not have properly functioning updater. In this case, please download the latest version from releases and replace the old app.

# Features planned for the future
- ~~Customisation of menu bar icon~~ Done!
- ~~Calendar events will only remind you once per session~~ Done!
- ~~Onboarding~~ Done!
- Better UI
- Optimisation of scripts
- Uploading onto Homebrew as cask
- More coming soon when I have the idea...

These features will come over the following weeks. Big releases will come over weekends. Please stayed tuned.

# Copyright notice

   Copyright 2026 Jacksonvil

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
