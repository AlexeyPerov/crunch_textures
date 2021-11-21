import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kometa_images/app/app.dart';
import 'package:kometa_images/app/repositories/settings_repository.dart';
import 'package:kometa_images/app/theme/theme_constants.dart';
import 'package:kometa_images/app/theme/themes.dart';
import 'package:kometa_images/common/utilities/navigator_utilities.dart';
import 'package:kometa_images/screens/details/details_screen.dart';
import 'package:kometa_images/screens/settings/settings_screen.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as pathUtils;
import 'package:proviso/proviso.dart';

import 'top_panel_card.dart';
import 'mini_button.dart';
import 'misc.dart';

class ControlPanel extends StatefulWidget {
  ControlPanel({Key key}) : super(key: key);

  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  List<AssetInfo> _assets = List.empty();
  TextEditingController _sourceController;
  ScrollController _controller;

  bool _loading = false;
  int _filesProcessed;
  int _totalFiles;

  bool _nonMultipleOFourOnly;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _sourceController = TextEditingController();

    final repository = getIt<SettingsRepository>();

    _nonMultipleOFourOnly =
        repository.getBool('nonMultipleOFourOnly', defaultValue: false);

    var folder = repository.getString('target_folder');

    if (folder == null || folder.isEmpty) {
      _assets = List.empty();
      _loading = false;
    } else {
      _loading = true;
      _totalFiles = 0;
      _filesProcessed = 0;
      _fillAssetsList(folder, false)
          .then((value) => {assetsUpdated(folder, value)});
    }
  }

  void assetsUpdated(String folder, List<AssetInfo> assets) {
    setState(() {
      _assets = assets;

      if (_assets.isNotEmpty) {
        _sourceController.text = folder;
      }

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      var loadingText = "";

      if (_totalFiles > 0) {
        loadingText = _filesProcessed.toString() + "/" + _totalFiles.toString();
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(loadingText,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontWeight: FontWeight.bold)),
          LinearProgressIndicator(),
        ],
      );
    }

    var totalHeight = MediaQuery.of(context).size.height;
    var headerHeight = 100.0;

    return ListView(
      children: <Widget>[
        SizedBox(height: 5.0),
        Container(
          height: headerHeight,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                child: TopPanelCard(
                    iconData: Icons.settings,
                    color: Theme.of(context).cardColor,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => SettingsScreen()));
                    }),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 5, right: 30.0, top: 15.0),
                  child: TextFormField(
                    autocorrect: false,
                    readOnly: true,
                    controller: _sourceController,
                    decoration: textFieldStyle(
                        context,
                        _sourceController.text.isNotEmpty
                            ? 'Assets in folder: ' + _assets.length.toString()
                            : "Select folder"),
                    validator: validateNonEmpty,
                    onTap: _onSelectFolderTap,
                  ),
                ),
              ),
            ],
          ),
        ),
        ConditionWidget(
          condition: _assets.length > 0,
          widget: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(children: [
              _modeCard(
                  // 'Non multiple of 4 [%4]: ' + _assets.where((asset) => !asset.size.multipleOfFour).length.toString() + '\nAll: ' + _assets.length.toString(),
                  'Non-multiple of 4: ' +
                      _assets
                          .where((asset) => !asset.size.multipleOfFour)
                          .length
                          .toString(),
                  _nonMultipleOFourOnly,
                  _modeSwitched)
            ]),
          ),
        ),
        Divider(thickness: 0.5),
        Container(
          height: totalHeight - headerHeight - 20,
          child: _buildAssetsList(_nonMultipleOFourOnly
              ? _assets
                  .where((asset) => !asset.size.multipleOfFour)
                  .toList(growable: false)
              : _assets),
        )
      ],
    );
  }

  void _modeSwitched() {
    _nonMultipleOFourOnly = !_nonMultipleOFourOnly;
    getIt<SettingsRepository>()
        .putBool('nonMultipleOFourOnly', _nonMultipleOFourOnly);
  }

  Widget _modeCard(String title, bool selected, Function onTapSetState) {
    const commonTextStyle = const TextStyle(fontSize: 14.0);

    return InkWell(
      onTap: () => {
        setState(() {
          onTapSetState();
        })
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: 35.0,
        width: 180.0,
        decoration: BoxDecoration(
          border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primaryVariant
                  : Theme.of(context).colorScheme.background,
              width: 0.5),
          color: selected ? kPrimaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [selected ? heavyBoxShadow() : slightBoxShadow()],
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 7.0),
                child: Text(title,
                    style: commonTextStyle,
                    overflow: TextOverflow.fade,
                    maxLines: 2),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsList(List<AssetInfo> list) {
    return FadingEdgeScrollView.fromScrollView(
      child: ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: list.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == list.length) {
            return SizedBox(height: 80);
          }

          var log = list[index];
          return Container(
              padding: EdgeInsets.only(bottom: 20),
              child: _assetCard(context, log));
        },
      ),
    );
  }

  Widget _assetCard(BuildContext context, AssetInfo assetInfo) {
    const titleTextStyle =
        const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
    const commonTextStyle = const TextStyle(fontSize: 14.0);
    const commonRedTextStyle =
        const TextStyle(fontSize: 14.0, color: Colors.redAccent);

    final path = assetInfo.file.path;
    final name = pathUtils.basename(path);
    final lastChanged = assetInfo.stat.changed;
    final sizeObj = assetInfo.size;

    final isPowerOfTwo = sizeObj.powerOfTwo;
    final isMultipleOfFour = sizeObj.multipleOfFour;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      padding:
          EdgeInsets.only(left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [commonBoxShadow()]),
      child: InkWell(
        onTap: () => _goToDetails(assetInfo),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: titleTextStyle),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.topLeft,
              child: Text(path,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: commonTextStyle),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(dateFormatter.format(lastChanged), style: commonTextStyle),
                SizedBox(width: 5.0),
                Text(timeFormatter.format(lastChanged), style: commonTextStyle),
                Spacer(),
                Row(
                  children: [
                    Text(sizeObj.width.toString(),
                        maxLines: 1,
                        style: assetInfo.size.multipleOfFourWidth
                            ? commonTextStyle
                            : commonRedTextStyle),
                    Text("x", maxLines: 1, style: commonTextStyle),
                    Text(sizeObj.height.toString(),
                        maxLines: 1,
                        style: assetInfo.size.multipleOfFourHeight
                            ? commonTextStyle
                            : commonRedTextStyle),
                  ],
                ),
                SizedBox(width: 10.0),
                Text("^2:", maxLines: 1, style: commonTextStyle),
                MiniButton(
                    icon: isPowerOfTwo
                        ? Icons.check_outlined
                        : Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    pressed: () => _goToDetails(assetInfo)),
                SizedBox(width: 30.0),
                Text("%4:", maxLines: 1, style: commonTextStyle),
                MiniButton(
                    icon: isMultipleOfFour
                        ? Icons.check_outlined
                        : Icons.close_rounded,
                    color: isMultipleOfFour ? Colors.green : Colors.red,
                    pressed: () => _goToDetails(assetInfo)),
              ],
            ),
            SizedBox(height: 5),
            ConditionWidget(
                condition: !isMultipleOfFour,
                widget: Row(
                  children: [
                    Spacer(),
                    Text(sizeObj.getCandidatesDescription(),
                        style: commonTextStyle),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _goToDetails(AssetInfo asset) {
    NavigatorUtilities.pushWithNoTransition(
        context, (_, __, ___) => DetailsScreen(asset: asset));
  }

  Future _onSelectFolderTap() async {
    try {
      var folder = await FilePicker.platform.getDirectoryPath();

      if (folder != null && folder.isNotEmpty) {
        setState(() {
          _loading = true;
          _totalFiles = 0;
          _filesProcessed = 0;
        });

        getIt<SettingsRepository>().putString("target_folder", folder);

        var newAssets = await _fillAssetsList(folder, true);

        setState(() {
          _assets = newAssets;
          _sourceController.text = folder;
          _loading = false;
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<AssetInfo>> _fillAssetsList(
      String folder, bool outputErrors) async {
    var newAssets = List<AssetInfo>.empty(growable: true);

    try {
      var dir = Directory(folder);

      logger.i('Opening directory: ' + folder);

      var files = dir.listSync(recursive: true).toList(growable: false);

      logger.i('Files found: ' + files.length.toString());

      var images = files
          .where((file) =>
              file is File &&
              imageExtensions.contains(pathUtils.extension(file.path)))
          .toList(growable: false);

      logger.i('Images found: ' + images.length.toString());

      var i = 0;

      setState(() {
        _totalFiles = images.length;
      });

      for (var fileEntry in images) {
        var file = fileEntry as File;

        try {
          var bytes = await file.readAsBytes();
          var image = decodeImage(bytes);
          var imageSize = ImageSize(image.width, image.height);

          var stat = await FileStat.stat(fileEntry.path);

          newAssets.add(AssetInfo(fileEntry, stat, imageSize));
        } catch (e) {
          if (outputErrors) logger.e(e);
        }

        i++;

        setState(() {
          _filesProcessed = i;
        });
      }
    } catch (e) {
      if (outputErrors) logger.e(e);
    }

    newAssets.sort((x1, x2) => pathUtils
        .basename(x1.file.path)
        .compareTo(pathUtils.basename(x2.file.path)));

    return newAssets;
  }
}

var imageExtensions = [".png", ".jpg", ".jpeg", ".tga"];

class AssetInfo {
  final FileSystemEntity file;
  final FileStat stat;
  final ImageSize size;

  AssetInfo(this.file, this.stat, this.size);
}

class ImageSize {
  final int width;
  final int height;

  final bool powerOfTwo;
  final bool multipleOfFourWidth;
  final bool multipleOfFourHeight;
  bool multipleOfFour;

  List<ResizeOption> candidates = List.empty(growable: true);

  ImageSize(this.width, this.height)
      : powerOfTwo = isPowerOfTwo(width) && isPowerOfTwo(height),
        multipleOfFourWidth = isMultipleOfFour(width),
        multipleOfFourHeight = isMultipleOfFour(height) {
    multipleOfFour = multipleOfFourHeight && multipleOfFourWidth;

    if (!multipleOfFour) {
      final lw = getPreviousMultipleOfFour(width);
      final gw = getNextMultipleOfFour(width);

      final lh = getPreviousMultipleOfFour(height);
      final gh = getNextMultipleOfFour(height);

      if (!multipleOfFourWidth && !multipleOfFourHeight) {
        candidates.add(ResizeOption(lw, lh, '', false, commonResizeTypes));
        candidates.add(ResizeOption(gw, lh, '', false, commonResizeTypes));
        candidates.add(ResizeOption(lw, gh, '', false, commonResizeTypes));
        candidates
            .add(ResizeOption(gw, gh, 'enlarge', true, enlargeResizeTypes));
      } else if (!multipleOfFourWidth) {
        candidates.add(ResizeOption(lw, height, '', false, commonResizeTypes));
        candidates
            .add(ResizeOption(gw, height, 'enlarge', true, enlargeResizeTypes));
      } else {
        candidates.add(ResizeOption(width, lh, '', false, commonResizeTypes));
        candidates
            .add(ResizeOption(width, gh, 'enlarge', true, enlargeResizeTypes));
      }
    }
  }

  String getCandidatesDescription() {
    var description = "Resize options:";

    for (var option in candidates) {
      description +=
          " [" + option.width.toString() + "x" + option.height.toString() + "]";
    }

    return description;
  }
}

class ResizeOption {
  final int width;
  final int height;
  final String description;
  final bool recommended;
  final List<ResizeType> resizeTypesAvailable;

  ResizeOption(this.width, this.height, this.description, this.recommended,
      this.resizeTypesAvailable);
}

final commonResizeTypes = [
  ResizeType.nearest,
  ResizeType.linear,
  ResizeType.cubic
];
final enlargeResizeTypes = [
  ResizeType.centerWithAlpha,
  ResizeType.nearest,
  ResizeType.linear,
  ResizeType.cubic
];

enum ResizeType { nearest, linear, cubic, centerWithAlpha }

extension ParseToString on ResizeType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

bool isPowerOfTwo(int x) {
  return (x != 0) && ((x & (x - 1)) == 0);
}

bool isMultipleOfFour(int x) {
  return x != 0 && x % 4 == 0;
}

int getPreviousMultipleOfFour(int x) {
  var y = x;
  while (!isMultipleOfFour(y)) {
    y--;
  }

  return y;
}

int getNextMultipleOfFour(int x) {
  var y = x;
  while (!isMultipleOfFour(y)) {
    y++;
  }

  return y;
}
