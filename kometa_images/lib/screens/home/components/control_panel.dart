import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kometa_images/app/app.dart';
import 'package:kometa_images/app/repositories/settings_repository.dart';
import 'package:kometa_images/app/services/image_resize_service.dart';
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
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  List<AssetInfo> _assets = List.empty();
  late TextEditingController _sourceController;
  late ScrollController _controller;
  final ImageResizeService _resizeService = ImageResizeService();

  bool _loading = false;
  int _filesProcessed = 0;
  int _totalFiles = 0;
  bool _nonMultipleOFourOnly = false;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _sourceController = TextEditingController();

    final repository = getIt<SettingsRepository>();
    _nonMultipleOFourOnly =
        repository.getBool('nonMultipleOFourOnly', defaultValue: false);

    final folder = repository.getString('target_folder');

    if (folder.isEmpty) {
      _assets = List.empty();
      _loading = false;
    } else {
      _loading = true;
      _totalFiles = 0;
      _filesProcessed = 0;
      _fillAssetsList(folder, false)
          .then((value) => assetsUpdated(folder, value));
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
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
          LinearProgressIndicator(),
        ],
      );
    }

    var totalWidth = MediaQuery.of(context).size.width;
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
                  child: Row(
                    children: [
                      Container(
                        width: totalWidth - 100,
                        child: TextFormField(
                          autocorrect: false,
                          readOnly: true,
                          controller: _sourceController,
                          decoration: textFieldStyle(
                              context,
                              _sourceController.text.isNotEmpty
                                  ? 'Assets in folder: ' +
                                      _assets.length.toString()
                                  : 'Select folder'),
                          validator: validateNonEmpty,
                          onTap: _onSelectFolderTap,
                        ),
                      )
                    ],
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
              ConditionWidget(
                  condition: _sourceController.text.length > 0,
                  widget: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: TextButton(                    
                        onPressed: () {
                          _sourceController.clear();
                          setState(() {
                            _assets = List.empty();
                          });
                        },
                        child: const Text('Reset')),
                  )),
              _modeCard(
                  'Non-multiple of 4: ' +
                      _assets
                          .where((asset) => !asset.size.multipleOfFour)
                          .length
                          .toString(),
                  _nonMultipleOFourOnly,
                  _modeSwitched),
              TextButton(
                onPressed: _assets.any((asset) => !asset.size.multipleOfFour)
                    ? _onFixAllInvalidTap
                    : null,
                child: const Text('Fix all invalid'),
              ),
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
                  ? Theme.of(context).colorScheme.primary
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
                SizedBox(width: 30.0),
                Tooltip(
                  message: 'Width and height are powers of two',
                  child: Text("Power of 2:", maxLines: 1, style: commonTextStyle),
                ),
                Tooltip(
                  message: isPowerOfTwo
                      ? 'Dimensions are valid power-of-two values'
                      : 'One or both dimensions are not power-of-two values',
                  child: MiniButton(
                      icon: isPowerOfTwo
                          ? Icons.check_outlined
                          : Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      pressed: () => _goToDetails(assetInfo)),
                ),
                SizedBox(width: 30.0),
                Tooltip(
                  message: 'Width and height are divisible by 4',
                  child:
                      Text("Multiple of 4:", maxLines: 1, style: commonTextStyle),
                ),
                Tooltip(
                  message: isMultipleOfFour
                      ? 'Dimensions are Crunch-compatible'
                      : 'One or both dimensions are not divisible by 4',
                  child: MiniButton(
                      icon: isMultipleOfFour
                          ? Icons.check_outlined
                          : Icons.close_rounded,
                      color: isMultipleOfFour ? Colors.green : Colors.red,
                      pressed: () => _goToDetails(assetInfo)),
                ),
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

  Future<void> _onFixAllInvalidTap() async {
    final invalidAssets =
        _assets.where((asset) => !asset.size.multipleOfFour).toList();

    if (invalidAssets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No invalid textures to process.')));
      return;
    }

    final options = await _showBatchOptionsDialog(invalidAssets.length);
    if (options == null || !mounted) {
      return;
    }

    await _runBatchResize(invalidAssets, options);
  }

  Future<_BatchResizeOptions?> _showBatchOptionsDialog(int filesCount) async {
    final repository = getIt<SettingsRepository>();
    final savedResizeTypeIndex = repository.getInt(
      'batch_resize_type',
      defaultValue: ResizeType.centerWithAlpha.index,
    );
    final savedResizeModeIndex = repository.getInt(
      'batch_resize_mode',
      defaultValue: ResizeMode.createResizedCopy.index,
    );

    ResizeType selectedType;
    ResizeMode selectedMode;

    try {
      selectedType = ResizeType.values[savedResizeTypeIndex];
    } catch (_) {
      selectedType = ResizeType.centerWithAlpha;
    }

    try {
      selectedMode = ResizeMode.values[savedResizeModeIndex];
    } catch (_) {
      selectedMode = ResizeMode.createResizedCopy;
    }

    bool dangerousConfirmed = false;

    final result = await showDialog<_BatchResizeOptions>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Fix all invalid'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Files to process: $filesCount'),
                  const SizedBox(height: 10),
                  const Text('Resize method: Use recommended size per file'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ResizeType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Interpolation'),
                    items: const [
                      DropdownMenuItem(
                          value: ResizeType.centerWithAlpha,
                          child: Text('Center inside a transparent img')),
                      DropdownMenuItem(
                          value: ResizeType.nearest, child: Text('Nearest')),
                      DropdownMenuItem(
                          value: ResizeType.linear, child: Text('Linear')),
                      DropdownMenuItem(
                          value: ResizeType.cubic, child: Text('Cubic')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ResizeMode>(
                    value: selectedMode,
                    decoration: const InputDecoration(labelText: 'Output mode'),
                    items: const [
                      DropdownMenuItem(
                          value: ResizeMode.createResizedCopy,
                          child: Text('Create resized copy')),
                      DropdownMenuItem(
                          value: ResizeMode.resizeThisFileAndBackup,
                          child: Text('Resize original + backup')),
                      DropdownMenuItem(
                          value: ResizeMode.resizeThisFile,
                          child: Text('Resize original')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setDialogState(() {
                        selectedMode = value;
                        if (selectedMode != ResizeMode.resizeThisFile) {
                          dangerousConfirmed = false;
                        }
                      });
                    },
                  ),
                  if (selectedMode == ResizeMode.resizeThisFile) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Warning: this overwrites original files without backup.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    CheckboxListTile(
                      value: dangerousConfirmed,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('I understand and want to continue'),
                      onChanged: (value) {
                        setDialogState(() {
                          dangerousConfirmed = value ?? false;
                        });
                      },
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedMode == ResizeMode.resizeThisFile &&
                        !dangerousConfirmed
                    ? null
                    : () {
                        repository.putInt('batch_resize_type', selectedType.index);
                        repository.putInt('batch_resize_mode', selectedMode.index);
                        Navigator.pop(
                          dialogContext,
                          _BatchResizeOptions(
                            interpolation: selectedType,
                            resizeMode: selectedMode,
                          ),
                        );
                      },
                child: const Text('Start'),
              ),
            ],
          );
        });
      },
    );

    return result;
  }

  Future<void> _runBatchResize(
      List<AssetInfo> assets, _BatchResizeOptions options) async {
    final progress = ValueNotifier<_BatchProgressState>(_BatchProgressState(
      total: assets.length,
      processed: 0,
      success: 0,
      failed: 0,
      currentFileName: '',
      cancelRequested: false,
    ));
    final failures = <_BatchFailure>[];

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ValueListenableBuilder<_BatchProgressState>(
          valueListenable: progress,
          builder: (context, state, __) {
            final ratio = state.total == 0 ? 0.0 : state.processed / state.total;
            return AlertDialog(
              title: const Text('Batch resize in progress'),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentFileName.isEmpty
                          ? 'Preparing...'
                          : 'Current: ${state.currentFileName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: ratio),
                    const SizedBox(height: 10),
                    Text('Processed: ${state.processed}/${state.total}'),
                    Text('Success: ${state.success}'),
                    Text('Failed: ${state.failed}'),
                    if (state.cancelRequested) ...[
                      const SizedBox(height: 10),
                      const Text('Stopping after current file...'),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state.cancelRequested
                      ? null
                      : () {
                          progress.value = state.copyWith(cancelRequested: true);
                        },
                  child: const Text('Cancel'),
                )
              ],
            );
          },
        );
      },
    );

    for (var index = 0; index < assets.length; index++) {
      final state = progress.value;
      if (state.cancelRequested) {
        break;
      }

      final asset = assets[index];
      final selectedOption = _recommendedOption(asset.size);

      if (selectedOption == null) {
        failures.add(_BatchFailure(asset.file.path, 'No recommended size found'));
        progress.value = state.copyWith(
          processed: state.processed + 1,
          failed: state.failed + 1,
          currentFileName: pathUtils.basename(asset.file.path),
        );
        continue;
      }

      final result = await _resizeService.resize(
        ImageResizeRequest(
          sourcePath: asset.file.path,
          width: selectedOption.width,
          height: selectedOption.height,
          resizeType: options.interpolation,
          resizeMode: options.resizeMode,
        ),
      );

      final latestState = progress.value;
      if (result.success) {
        progress.value = latestState.copyWith(
          processed: latestState.processed + 1,
          success: latestState.success + 1,
          currentFileName: pathUtils.basename(asset.file.path),
        );
      } else {
        failures
            .add(_BatchFailure(asset.file.path, result.error ?? 'Unknown error'));
        progress.value = latestState.copyWith(
          processed: latestState.processed + 1,
          failed: latestState.failed + 1,
          currentFileName: pathUtils.basename(asset.file.path),
        );
      }
    }

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    final finalState = progress.value;
    progress.dispose();

    if (!mounted) {
      return;
    }

    await _refreshAssets();

    await _showBatchResultDialog(
      successCount: finalState.success,
      failedCount: finalState.failed,
      failures: failures,
    );
  }

  ResizeOption? _recommendedOption(ImageSize size) {
    if (size.multipleOfFour) {
      return null;
    }

    for (final option in size.candidates) {
      if (option.recommended) {
        return option;
      }
    }

    if (size.candidates.isEmpty) {
      return null;
    }

    return size.candidates.last;
  }

  Future<void> _refreshAssets() async {
    final folder = _sourceController.text;
    if (folder.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _totalFiles = 0;
      _filesProcessed = 0;
    });

    final refreshedAssets = await _fillAssetsList(folder, true);
    if (!mounted) {
      return;
    }

    setState(() {
      _assets = refreshedAssets;
      _loading = false;
    });
  }

  Future<void> _showBatchResultDialog({
    required int successCount,
    required int failedCount,
    required List<_BatchFailure> failures,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Batch resize completed'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Success: $successCount'),
                Text('Failed: $failedCount'),
                if (failures.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Failed files:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: failures.length,
                      itemBuilder: (context, index) {
                        final failure = failures[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${pathUtils.basename(failure.path)} - ${failure.reason}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  )
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  Future _onSelectFolderTap() async {
    try {
      final folder = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder with textures',
      );

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
    } catch (e, st) {
      logger.e(e, st);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Folder picker failed to open: ${e.toString()}')));
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
          var imageSize = ImageSize(image!.width, image.height);

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
  late bool multipleOfFour;

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

class _BatchResizeOptions {
  final ResizeType interpolation;
  final ResizeMode resizeMode;

  const _BatchResizeOptions({
    required this.interpolation,
    required this.resizeMode,
  });
}

class _BatchFailure {
  final String path;
  final String reason;

  const _BatchFailure(this.path, this.reason);
}

class _BatchProgressState {
  final int total;
  final int processed;
  final int success;
  final int failed;
  final String currentFileName;
  final bool cancelRequested;

  const _BatchProgressState({
    required this.total,
    required this.processed,
    required this.success,
    required this.failed,
    required this.currentFileName,
    required this.cancelRequested,
  });

  _BatchProgressState copyWith({
    int? total,
    int? processed,
    int? success,
    int? failed,
    String? currentFileName,
    bool? cancelRequested,
  }) {
    return _BatchProgressState(
      total: total ?? this.total,
      processed: processed ?? this.processed,
      success: success ?? this.success,
      failed: failed ?? this.failed,
      currentFileName: currentFileName ?? this.currentFileName,
      cancelRequested: cancelRequested ?? this.cancelRequested,
    );
  }
}
