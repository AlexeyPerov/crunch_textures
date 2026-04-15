# Check and resize textures to work with Crunch compression

![stability-stable](https://img.shields.io/badge/stability-stable-green.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

##

With this tool you can scan images (.png, .jpeg, .tga) across selected folders and detect which of them can work with Crunch compression.

It simply checks their dimensions to be multiple of 4 and suggests options for resizing.

Resizing is done via [image package](https://pub.dev/packages/image/example) with 4 options:
- linear interpolation
- cubic interpolation
- nearest interpolation
- or centering original image inside transparent one with the desired size (recommended one)

You can also:
- resize an original file (with or without a backup)
- resize to a copy
- resize to closest 'square' size

## Usage

At first select the folder to work with:

![plot](./screenshots/empty_window.png)

The tool finds all images there then indicating which are multiple of 4 and which are not

![plot](./screenshots/list.png)

Tapping on any of the images opens the panel where you can choose resize options

![plot](./screenshots/details.png)

You can also use batch operations

![plot](./screenshots/batch_popup.png)

Batch operation can fix either all textures or selected ones

![plot](./screenshots/batch_result.png)

## 
Supports light & dark themes:

![plot](./screenshots/settings_theme.png)

## Platforms

Works with MacOS and Windows.

Linux should work too (not tested). 

Just type: 
```bash
flutter create --platforms=linux .
```
to add its module to a project.

## How to build

[MacOS](https://retroportalstudio.medium.com/creating-dmg-file-for-flutter-macos-apps-e448ff1cb0f)

[Windows](https://retroportalstudio.medium.com/creating-exe-executable-file-for-flutter-desktop-apps-windows-ea7c338465e)