# impulse
</br>

<!--![banner_light](https://github.com/kannel-outis/impulse/assets/32224274/7cbcfef2-ec0d-48c4-abaf-841edc0689af)-->
<div align="center">
  <img src="https://github.com/kannel-outis/impulse/assets/32224274/7522f0f0-d386-49f2-a7dc-ae4719d3ab51"  width="20%" />
</div>

</br>
</br>

# Introduction 👋
Impulse is a file-sharing application, built with [flutter](https://flutter.dev/), that allows devices within the same network to effortlessly transfer and share files across the network using a single connection.
</br>
</br>

## Features 💡
Impulse presents a rich set of features that contribute to the effortless sharing of files among devices, which include...

- 📱 <b>Simple and adaptive UI :</b> Impulse offers a very simple, user-friendly and easy to navigate User Interface. Impulse seamlessly accommodates and adjusts to larger screen sizes, presenting a clean and user-friendly interface tailored to desktop dimensions.
- 🔃 <b>Share and receive file on a single connection :</b> With impulse, both devices can send and receive file at thesame time. i.e both devices act as a server and client at once.
- 📡 <b>Quick scan to discover available networks :</b> Impulse offers a quick and efficient method for scanning and discovering available devices on the network.
- 🔎 <b>QR Scan for faster network discovery :</b>Not finding Quick Scan quick ;) enough?, fear not. Impulse offers another quick option to connect directly with a ready host.
- 📂 <b>In-built file manager :</b> Impulse comes with its very own built-in file manager. you don't have to leave your confort zone to select files, select directly from impulse!.
- 👩🏻‍💻 <b>Create profile :</b> Create a profile to identify yourself on the network. don't just be another ip address, go by your name!.
- 📂 <b>Network file manager :</b> Impulse enhances the file-sharing experience by enabling connected users to seamlessly browse each other's file managers. Tired of waiting for files to be sent, simply navigate to the Network file manager and take matters into your own hands.
- ⬇️ <b>Resumable transfers :</b> Interruptions to connections occur on the network at all times; Impulse makes sure that transfers that are interrupted are resumed in the next connection or session. Impulse ensures that your files are not corrupted and are ready to be used.
</br>
</br>

# Screenshots 🖼️

https://github.com/kannel-outis/impulse/assets/32224274/c84008bf-31dc-4805-9d91-4cd587561d59

<img src="https://github.com/kannel-outis/impulse/assets/32224274/fd3cb90c-0af7-4c77-a89a-48571665bdbd" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/253e425a-cf47-49c4-9269-bcbfab8ab167" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/cf45e9ff-99e6-4438-8219-4bbf268a72e4" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/294167cc-c39e-4921-8c94-e11c0cb900d6" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/f7d8e06e-3ea0-4d31-824e-703284d79611" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/5a319153-98fd-4c08-baab-e2497c539379" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/62ae9ee0-c5d2-48ef-a8ce-abf4d6f6f400" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/6b399684-848e-4337-aa47-c7e22a4effad" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/7618d6fe-a6c8-4c8b-921f-9934c209bca2" width="40%">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/44cc592f-1635-4358-a96a-dce873bcb3b5">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/29f6db8c-f78d-467e-a1d9-9c0f51adf43d">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/ea859ffd-0db5-4b9f-b761-965d45c1b0de">
<img src="https://github.com/kannel-outis/impulse/assets/32224274/c3b8b20f-3666-41f3-9cb5-14a874fd6cea">
</br>
</br>

# How to use impulse 📋
Ready to dive into Impulse's fantastic features? Just follow these steps!.


## Sender
- Host or Connect to a wifi network ( Preferably the same network the receiver is going to be on).  
- Open the impulse app and click on the red button (on Mobile) or the + button (on Desktop).
- On desktop, a dialog will pop up and on Mobile, a speed dial is opened. click on the send icon.
- if successful, a modal is shown to display your qr code while you wait for a connection to be established.
- Dismissed the modal, Do not fret. you can show the modal again by clicking the button from step 2, only this time you dont have to select if to send or to receive.
</br>


## Receiver
- Connect to the same network the sender has created or connected to.
- Open the impulse app and click on the red button (on Mobile) or the + button (on Desktop).
  #### Quick Scan
   - On desktop, a dialog will pop up and on Mobile, a speed dial is opened. click on the Receive icon.
   - A modal will open to scan for available users. when users are found, Find and click on the user you want to connect to. A connection request is sent to this user.
   - Wait for the user to accept your request, and Voila! You have successfully connected to the sender!.

  #### Qr Code Scan
   - Click on the scan icon on mobile.
   - Hold your device's camera so that the QR code is within the scan frame.
   - After a successful scan, request for connection and await response.
   - Wait for the user to accept your request, and Voila! You have successfully connected to the sender!.

- Share, receive and enjoy !!.
</br>
</br>

# Install Project On Your Machine 🛠️
Assuming you already have [flutter](https://flutter.dev/) and git installed on your machine, To install this project you simply run:

```$bash
# Clone this repository
$ git clone https://github.com/kannel-outis/impulse.git

# Go into the repository
$ cd impulse

# Install packages
$ flutter pub get

# Run the app
$ flutter run
```
If you do not already have flutter installed on your machine, visit [https://flutter.dev/](https://flutter.dev/) to get started.

# Packages Used 📦
- [app_settings](https://pub.dev/packages/app_settings): Impulse uses app settings to open Wifi and Hotspot app settings.
- [barcode_widget](https://pub.dev/packages/barcode_widget): impulse uses barcode_widget to generate and display the QR code.
- [dartz](https://pub.dev/packages/dartz): fImpulse uses dartz for functional programming.
- [file_picker](https://pub.dev/packages/file_picker): Impulse uses the file_picker package for selecting file paths.
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod): Impulse uses flutter_riverpod for statemanagement and dependency injection across the app.
- [flutter_sharing_intent](https://pub.dev/packages/flutter_sharing_intent): Impulse uses this package for receiving files from another app for sharing.
- [flutter_svg](https://pub.dev/packages/flutter_svg): Impulse uses the flutter_svg package to render and display Svg vectors.
- [go_router](https://pub.dev/packages/go_router): Impulse uses go_router for navigation across screens in impulse app
- [hive](https://pub.dev/packages/hive): Impulse uses the hive package for local caching and storing.
- [hive_flutter](https://pub.dev/packages/hive_flutter): Impulse uses hive_flutter together with hive for local caching and storage support.
- [http](https://pub.dev/packages/http): Impulse uses http package to make HTTP requests.
- [impulse_utils](https://github.com/kannel-outis/impulse_utils.git):  impulse_utils offers some utility apis for Impulse. apis like file managerment apis, image compressions among others.
- [mime](https://pub.dev/packages/mime): impulse uses the mime package to get the mime type of files shared by impulse.
- [open_file](https://pub.dev/packages/open_file): Impulse uses open_file to open native default apps for viewing files.
- [path_drawing](https://pub.dev/packages/path_drawing): Impulse uses the path_drawing package for path manipulation and creation.
- [path_provider](https://pub.dev/packages/path_provider): Impulse uses the path_provider plugin for finding path locations on the filesystem.
- [permission_handler](https://pub.dev/packages/permission_handler): Impulse uses the permission_handler plugin for handling required permssions.
- [qr_code_scanner](https://pub.dev/packages/qr_code_scanner): Impulse uses the qr_code_scanner package to scan generated qr code.
- [riverpod](https://pub.dev/packages/riverpod): Impulse uses the riverpod  package together with flutter_riverpod to handle state management and dependency injection.
- [shared_preferences](https://pub.dev/packages/shared_preferences): Impulse uses the shared_preferences plugin to handle local caching and storage support.
- [uuid](https://pub.dev/packages/uuid): Impulse uses the uuid package to generate random uniques IDs.
<br/>
<br/>

# Contributions 🫱🏼‍🫲🏾
We welcome and appreciate contributions from anyone interested in improving Impulse Contributions can be by either
- Creating an issue about a bug or a feature that can/should be added.
- Creating a pull request for improvements or bugs you have fixed.

  #### Note: Before creating a pull request please make sure you have pulled and merged the latest changes from the DEV branch. 


<br/>
<br/>

# License 🍀

MIT License

Copyright (c) 2023 Enikuomehin Adejuwon

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
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
