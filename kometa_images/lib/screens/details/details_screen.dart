import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_utils;
import 'package:kometa_images/app/app.dart';
import 'package:kometa_images/app/repositories/settings_repository.dart';
import 'package:kometa_images/app/services/image_resize_service.dart';
import 'package:kometa_images/app/theme/theme_constants.dart';
import 'package:kometa_images/app/theme/themes.dart';
import 'package:kometa_images/screens/home/components/control_panel.dart';
import 'package:kometa_images/screens/home/components/top_panel_card.dart';
import 'package:path/path.dart' as pathUtils;
import 'package:proviso/proviso.dart';

class DetailsScreen extends StatefulWidget {
  final AssetInfo asset;

  const DetailsScreen({Key? key, required this.asset}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _inProgress = false;
  late ResizeMode _resizeMode;
  final ImageResizeService _resizeService = ImageResizeService();
  late AssetInfo _asset;
  bool _assetUpdated = false;

  _DetailsScreenState() {
    final savedIndex = getIt<SettingsRepository>().getInt('resize_mode');
    try {
      _resizeMode = ResizeMode.values[savedIndex];
    } catch (e) {
      logger.e(e);
      _resizeMode = ResizeMode.createResizedCopy;
    }
  }

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
  }

  @override
  Widget build(BuildContext context) {
    const smallTextStyle = const TextStyle(fontSize: 12.0);
    const smallGreenTextStyle =
        const TextStyle(fontSize: 12.0, color: Color(0xFF1F7C54));
    const commonTextStyle = const TextStyle(fontSize: 14.0);
    const mediumTextStyle = const TextStyle(fontSize: 15.0);
    const mediumGreenTextStyle =
        const TextStyle(fontSize: 15.0, color: Color(0xFF0D7147));
    const commonRedTextStyle =
        const TextStyle(fontSize: 14.0, color: Colors.redAccent);

    final path = _asset.file.path;

    final name = pathUtils.basename(_asset.file.path);
    final lastChanged = _asset.stat.changed;
    final size = _asset.size;
    final isPowerOfTwo = _asset.size.powerOfTwo;
    final isMultipleOfFour = _asset.size.multipleOfFour;

    final isMultipleOfFourWidth = _asset.size.multipleOfFourWidth;
    final isMultipleOfFourHeight = _asset.size.multipleOfFourHeight;
    const actionCellWidth = 170.0;
    const actionLabelHeight = 18.0;

    var totalWidth = MediaQuery.of(context).size.width;
    var totalHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: null,
        body: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                  child: TopPanelCard(
                      iconData: Icons.arrow_back_rounded,
                      color: Theme.of(context).cardColor,
                      onTap: () {
                        Navigator.pop(
                            context,
                            DetailsScreenResult(
                                updatedAsset: _assetUpdated ? _asset : null));
                      }),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: totalWidth - 100,
                      child: Text(
                        path,
                        style: commonTextStyle,
                        overflow: TextOverflow.clip,                      
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Last changed:', style: commonTextStyle),
                        SizedBox(width: 5.0),
                        Text(dateFormatter.format(lastChanged),
                            style: commonTextStyle),
                        SizedBox(width: 5.0),
                        Text(timeFormatter.format(lastChanged),
                            style: commonTextStyle),
                      ],
                    )
                  ],
                ),
                Spacer()
              ],
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text('Height:', style: commonTextStyle),
                          Text(size.height.toString(),
                              style: isMultipleOfFourHeight
                                  ? commonTextStyle
                                  : commonRedTextStyle),
                        ],
                      ),
                      SizedBox(width: 5),
                      Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.background,
                                width: 0.5),
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [heavyBoxShadow()],
                          ),
                          child: Image.file(File(path), fit: BoxFit.scaleDown)),
                      SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Multiple of 4: ' +
                                  (isMultipleOfFour ? "YES" : "NO"),
                              style: commonTextStyle),
                          SizedBox(height: 5),
                          ConditionWidget(
                            condition: !isMultipleOfFour,
                            widget: Text(
                                'Only textures for which both the width and the height are multiple of 4\ncan be compressed to Crunch format',
                                style: smallTextStyle,
                                maxLines: 2),
                          ),
                          SizedBox(height: 10),
                          Text('Power of 2: ' + (isPowerOfTwo ? "YES" : "NO"),
                              style: commonTextStyle)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(width: 80),
                      Text('Width: ', style: commonTextStyle),
                      Text(size.width.toString(),
                          style: isMultipleOfFourWidth
                              ? commonTextStyle
                              : commonRedTextStyle),
                    ],
                  ),
                  SizedBox(height: 5),
                  ConditionWidget(
                      condition: _inProgress,
                      widget: LinearProgressIndicator(),
                      fallback: SizedBox(height: 4)),
                  Divider(),
                  ConditionWidget(
                    condition: !isMultipleOfFour,
                    widget: Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Resize options',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              _modeCard()
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Please select an operation to perform:',
                              style: commonTextStyle),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Container(
                      width: totalWidth,
                      height: totalHeight - 470,
                      child: ListView.builder(
                          shrinkWrap: false,
                          scrollDirection: Axis.vertical,
                          itemCount: _asset.size.candidates.length +
                              (size.width != size.height ? 1 : 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (size.width != size.height &&
                                index == _asset.size.candidates.length) {
                              final side = size.width > size.height
                                  ? size.width
                                  : size.height;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 25),
                                        Text('${side}x$side'),
                                        Text('square'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: actionCellWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: actionLabelHeight,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('',
                                                style: smallGreenTextStyle),
                                          ),
                                        ),
                                        _copyCard(
                                            "Center inside a transparent image",
                                            false,
                                            () => _resizeToSquare(),
                                            width: actionCellWidth),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }

                          final reversedIndex =
                              _asset.size.candidates.length - index - 1;
                          var option = _asset.size.candidates[reversedIndex];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                              child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 25),
                                      Text(
                                          option.width.toString() +
                                              'x' +
                                              option.height.toString(),
                                          style: option.recommended
                                              ? mediumGreenTextStyle
                                              : mediumTextStyle),
                                      Text(option.description,
                                          style: option.recommended
                                              ? smallGreenTextStyle
                                              : smallTextStyle)
                                    ],
                                  ),
                                ),
                                _actionCell(
                                  visible: option.resizeTypesAvailable
                                      .contains(ResizeType.linear),
                                  buttonWidth: actionCellWidth,
                                  labelHeight: actionLabelHeight,
                                  onTap: () => _resize(option, ResizeType.linear),
                                  caption: 'Linear\nInterpolation',
                                ),
                                _actionCell(
                                  visible: option.resizeTypesAvailable
                                      .contains(ResizeType.cubic),
                                  buttonWidth: actionCellWidth,
                                  labelHeight: actionLabelHeight,
                                  onTap: () => _resize(option, ResizeType.cubic),
                                  caption: 'Cubic\nInterpolation',
                                ),
                                _actionCell(
                                  visible: option.resizeTypesAvailable
                                      .contains(ResizeType.nearest),
                                  buttonWidth: actionCellWidth,
                                  labelHeight: actionLabelHeight,
                                  onTap: () => _resize(option, ResizeType.nearest),
                                  caption: 'Nearest\nInterpolation',
                                ),
                                _actionCell(
                                  visible: option.resizeTypesAvailable
                                      .contains(ResizeType.centerWithAlpha),
                                  buttonWidth: actionCellWidth,
                                  labelHeight: actionLabelHeight,
                                  onTap: () => _resize(option, ResizeType.centerWithAlpha),
                                  caption: 'Center inside a transparent image',
                                  highlighted: true,
                                  label: 'Recommended',
                                )
                              ],
                            ),
                          );
                        }),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 8)
          ],
        ));
  }

  Widget _modeCard() {
    const commonTextStyle = const TextStyle(fontSize: 14.0);

    var actionTitle = "Create resized copy";

    if (_resizeMode == ResizeMode.resizeThisFileAndBackup) {
      actionTitle = "Resize this file and backup";
    } else if (_resizeMode == ResizeMode.resizeThisFile) {
      actionTitle = "Resize this file";
    }

    return InkWell(
      onTap: () => {
        setState(() {
          var index = _resizeMode.index;

          index++;
          if (index > 2) {
            index = 0;
          }

          _resizeMode = ResizeMode.values[index];
          getIt<SettingsRepository>().putInt('resize_mode', _resizeMode.index);
        })
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: 35.0,
        width: 220.0,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.background, width: 0.5),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [heavyBoxShadow()],
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 7.0),
                child: Text(actionTitle,
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

  Widget _copyCard(String caption, bool highlighted, Function onTap,
      {double width = 140.0}) {
    const commonTextStyle = const TextStyle(fontSize: 14.0);

    return InkWell(
      hoverColor: kPrimaryColor,
      onTap: () => {onTap()},
      child: Container(
        margin: EdgeInsets.all(1),
        height: 50.0,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
              color: highlighted
                  ? kPrimaryColor
                  : Theme.of(context).colorScheme.background,
              width: highlighted ? 1 : 0.5),
          color: Theme.of(context).cardColor,
          boxShadow: [highlighted ? commonBoxShadow() : slightBoxShadow()],
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 5.0, top: 4.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(caption,
                    style: commonTextStyle,
                    overflow: TextOverflow.fade,
                    maxLines: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCell({
    required bool visible,
    required double buttonWidth,
    required double labelHeight,
    required String caption,
    required VoidCallback onTap,
    bool highlighted = false,
    String? label,
  }) {
    if (!visible) {
      return SizedBox(width: buttonWidth + 2);
    }

    return SizedBox(
      width: buttonWidth + 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: labelHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label ?? '', style: const TextStyle(fontSize: 12.0, color: Color(0xFF1F7C54))),
            ),
          ),
          _copyCard(caption, highlighted, onTap, width: buttonWidth),
        ],
      ),
    );
  }

  void _resize(ResizeOption option, ResizeType type) async {
    await _runResizeOperation(option.width, option.height, type);
  }

  Future<void> _resizeToSquare() async {
    final side = _asset.size.width > _asset.size.height
        ? _asset.size.width
        : _asset.size.height;
    await _runResizeOperation(side, side, ResizeType.centerWithAlpha);
  }

  Future<void> _runResizeOperation(
      int width, int height, ResizeType type) async {
    if (_resizeMode == ResizeMode.resizeThisFile) {
      final confirmed = await _confirmOverwriteWithoutBackup();
      if (!confirmed) {
        return;
      }
    }

    setState(() {
      _inProgress = true;
    });

    final path = _asset.file.path;
    final result = await _resizeService.resize(ImageResizeRequest(
      sourcePath: path,
      width: width,
      height: height,
      resizeType: type,
      resizeMode: _resizeMode,
    ));

    if (!mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resize image: ${result.error}')));
    } else if (result.backupPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup at ${result.backupPath}')));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Resized ${result.outputPath}')));
    } else if (_resizeMode == ResizeMode.createResizedCopy) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Resized image copied to ${result.outputPath}')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Resized ${result.outputPath}')));
      await _refreshAssetAfterOverwrite(path);
    }

    setState(() {
      _inProgress = false;
    });
  }

  Future<bool> _confirmOverwriteWithoutBackup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm overwrite'),
          content: const Text(
              'This operation will overwrite the original file without creating a backup. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _refreshAssetAfterOverwrite(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final image = image_utils.decodeImage(bytes);

      if (image == null) {
        return;
      }

      final updatedStat = await FileStat.stat(path);
      final updatedSize = ImageSize(image.width, image.height);

      setState(() {
        _asset = AssetInfo(_asset.file, updatedStat, updatedSize);
        _assetUpdated = true;
      });
    } catch (e) {
      logger.e(e);
    }
  }
}

class DetailsScreenResult {
  final AssetInfo? updatedAsset;

  const DetailsScreenResult({this.updatedAsset});
}
