<img src="/calendarReminderLogo.png" width="200">

# calendar-reminder
A utility to remind you when a calendar event is coming up.

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

# Quitting the app and updating
App versions above 0.2.0 can use the menu bar to quit the app. To update the app, enter settings then check for updates. Updates should then be installed properly.

For app version below 0.1.2 (including 0.1.2) can use the dock to quit the app, and use the menu bar > calendar reminder to update the app.
App version 0.1.1 does not have properly functioning updater. In this case, please download the latest version from releases and replace the old app.

# Features planned for the future
- Customisation of menu bar icon
- Calendar events will only remind you once per session
- Better UI
- Optimisation of scripts
- More coming soon when I have the idea...

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
