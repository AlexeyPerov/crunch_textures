import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kometa_images/app/app.dart';
import 'package:kometa_images/app/theme/theme_constants.dart';
import 'package:kometa_images/app/theme/themes.dart';
import 'package:kometa_images/screens/home/components/control_panel.dart';
import 'package:kometa_images/screens/home/components/top_panel_card.dart';
import 'package:kometa_images/screens/home/home_screen.dart';
import 'package:image/image.dart' as imageUtils;
import 'package:path/path.dart' as pathUtils;
import 'package:proviso/proviso.dart';

class DetailsScreen extends StatefulWidget {
  final AssetInfo asset;

  DetailsScreen({@required this.asset});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _inProgress = false;

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

    final path = widget.asset.file.path;

    final name = pathUtils.basename(widget.asset.file.path);
    final lastChanged = widget.asset.stat.changed;
    final size = widget.asset.size;
    final isPowerOfTwo = widget.asset.size.powerOfTwo;
    final isMultipleOfFour = widget.asset.size.multipleOfFour;

    final isMultipleOfFourWidth = widget.asset.size.multipleOfFourWidth;
    final isMultipleOfFourHeight = widget.asset.size.multipleOfFourHeight;

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
                        HomeScreenNavigation.navigate(context);
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
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      path,
                      style: commonTextStyle,
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
              padding: const EdgeInsets.only(left: 20.0),
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
                                'Only textures for which both the width and the height are multiple of 4 can be compressed to Crunch format',
                                style: smallTextStyle),
                          ),
                          SizedBox(height: 10),
                          Text('Power of 2: ' + (isPowerOfTwo ? "YES" : "NO"),
                              style: commonTextStyle)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 15),
                  ConditionWidget(
                      condition: _inProgress,
                      widget: LinearProgressIndicator(),
                      fallback: SizedBox(height: 4)),
                  Divider(),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Text(
                      'Resize options',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 35.0),
                    child: Container(
                      width: totalWidth,
                      height: totalHeight - 350,
                      child: ListView.builder(
                          shrinkWrap: false,
                          scrollDirection: Axis.vertical,
                          itemCount: widget.asset.size.candidates.length,
                          itemBuilder: (BuildContext context, int index) {
                            final reversedIndex =
                                widget.asset.size.candidates.length - index - 1;
                            var option =
                                widget.asset.size.candidates[reversedIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15),
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
                                  ConditionWidget(
                                    condition: option.resizeTypesAvailable
                                        .contains(ResizeType.linear),
                                    widget: Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: _copyCard(
                                          "Copy & Resize",
                                          "Linear",
                                          false,
                                          () => _resize(
                                              option, ResizeType.linear)),
                                    ),
                                  ),
                                  ConditionWidget(
                                    condition: option.resizeTypesAvailable
                                        .contains(ResizeType.cubic),
                                    widget: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: _copyCard(
                                          "Copy & Resize",
                                          "Cubic",
                                          false,
                                          () => _resize(
                                              option, ResizeType.cubic)),
                                    ),
                                  ),
                                  ConditionWidget(
                                    condition: option.resizeTypesAvailable
                                        .contains(ResizeType.nearest),
                                    widget: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: _copyCard(
                                          "Copy & Resize",
                                          "Nearest",
                                          false,
                                          () => _resize(
                                              option, ResizeType.nearest)),
                                    ),
                                  ),
                                  ConditionWidget(
                                    condition: option.resizeTypesAvailable
                                        .contains(ResizeType.centerWithAlpha),
                                    widget: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: _copyCard(
                                          "Copy & Resize",
                                          "Add alpha to sides",
                                          true,
                                          () => _resize(option,
                                              ResizeType.centerWithAlpha)),
                                    ),
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
            Spacer()
          ],
        ));
  }

  Widget _copyCard(
      String title, String caption, bool highlighted, Function onTap) {
    const commonTextStyle = const TextStyle(fontSize: 14.0);
    const captionTextStyle = const TextStyle(fontSize: 12.0);

    return InkWell(
      hoverColor: kPrimaryColor,
      onTap: () => {onTap()},
      child: Container(
        margin: EdgeInsets.all(1),
        height: 45.0,
        width: 150.0,
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
                    maxLines: 1),
                SizedBox(height: 3),
                Text(title,
                    style: captionTextStyle,
                    overflow: TextOverflow.fade,
                    maxLines: 1)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resize(ResizeOption option, ResizeType type) async {
    setState(() {
      _inProgress = true;
    });

    final path = widget.asset.file.path;
    final typeStr = type.toShortString();
    final destSizeStr =
        option.width.toString() + "x" + option.height.toString();
    final msg = "Resize " + path + " to " + destSizeStr + " as " + typeStr;

    logger.i(msg);
    final pathNoExtension = pathUtils.withoutExtension(path);
    final extension = pathUtils.extension(path);
    final destination = pathNoExtension +
        "_autoresize_" +
        destSizeStr +
        "_" +
        typeStr +
        extension;
    logger.i("Destination: " + destination);

    try {
      var file = widget.asset.file as File;

      var bytes = await file.readAsBytes();
      var image = imageUtils.decodeImage(bytes);

      imageUtils.Image resultImage;

      switch (type) {
        case ResizeType.nearest:
          resultImage = imageUtils.copyResize(image,
              width: option.width,
              height: option.height,
              interpolation: imageUtils.Interpolation.nearest);
          break;
        case ResizeType.linear:
          resultImage = imageUtils.copyResize(image,
              width: option.width,
              height: option.height,
              interpolation: imageUtils.Interpolation.linear);
          break;
        case ResizeType.cubic:
          resultImage = imageUtils.copyResize(image,
              width: option.width,
              height: option.height,
              interpolation: imageUtils.Interpolation.cubic);
          break;
        case ResizeType.centerWithAlpha:
          final tempImage = imageUtils.Image(option.width, option.height);
          final blankImage =
              imageUtils.fill(tempImage, imageUtils.getColor(0, 0, 0, 0));
          resultImage = imageUtils.copyInto(blankImage, image,
              blend: false, center: true);
          break;
      }

      List<int> resultingBytes;

      if (extension == ".jpg" || extension == ".jpeg") {
        resultingBytes = imageUtils.encodeJpg(resultImage);
      } else if (extension == ".tga") {
        resultingBytes = imageUtils.encodeTga(resultImage);
      } else {
        resultingBytes = imageUtils.encodePng(resultImage);
      }

      await File(destination).writeAsBytes(resultingBytes);

      final snackBar =
          SnackBar(content: Text('Image copied to ' + destination));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      logger.e(e);
    }

    setState(() {
      _inProgress = false;
    });
  }
}
