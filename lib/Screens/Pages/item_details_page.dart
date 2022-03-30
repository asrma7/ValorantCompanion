import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/url_manager.dart';
import 'package:video_player/video_player.dart';

import '/Library/src/enums.dart';

class ItemDetailsPage extends StatefulWidget {
  final String itemId, displayName;
  final String? displayIcon, streamedVideo, titleText;
  final double? basePrice, discountedPrice, discountPercent;
  final ItemType itemType;
  const ItemDetailsPage({
    Key? key,
    required this.itemId,
    required this.itemType,
    required this.displayName,
    this.displayIcon,
    this.streamedVideo,
    this.basePrice,
    this.discountedPrice,
    this.discountPercent,
    this.titleText,
  }) : super(key: key);

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  ChewieController? _controller;
  final bool _isWindows = Platform.isWindows;

  @override
  void initState() {
    if (!_isWindows) {
      if (widget.streamedVideo != null && widget.streamedVideo!.isNotEmpty) {
        _controller = ChewieController(
          videoPlayerController: VideoPlayerController.network(
            widget.streamedVideo!,
          ),
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: true,
          showControlsOnInitialize: false,
          autoInitialize: true,
        );
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
      ),
      body: FutureBuilder(
        future: getItemPrice(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double price = snapshot.data as double;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                !_isWindows &&
                        widget.streamedVideo != null &&
                        widget.streamedVideo!.isNotEmpty
                    ? SizedBox(
                        height: (MediaQuery.of(context).size.width) / 16 * 9,
                        child: Chewie(
                          controller: _controller!,
                        ),
                      )
                    : Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(16.0),
                        child: widget.displayIcon != null
                            ? Image.network(
                                widget.displayIcon!,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                widget.titleText ?? 'No image available',
                                style: const TextStyle(fontSize: 20.0),
                              ),
                      ),
                Text(
                  widget.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.deepPurple),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Price: \$$price',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                widget.discountedPrice != null
                    ? Text(
                        'Discount on bundle: \$${widget.discountPercent?.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                _isWindows &&
                        widget.streamedVideo != null &&
                        widget.streamedVideo!.isNotEmpty
                    ? ElevatedButton(
                        onPressed: () {
                          Process.run("vlc", [widget.streamedVideo!]).then(
                            (ProcessResult results) {
                              if (kDebugMode) {
                                print(results.stdout);
                              }
                            },
                          );
                        },
                        child: const Text('Video'),
                      )
                    : Container(),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<double> getItemPrice() async {
    if (widget.basePrice != null) {
      return widget.basePrice!;
    }
    var response = await Dio().get(
      '${UrlManager.getSingleOfferUrl}/${widget.itemId}',
    );
    return response.data['cost']['valorantPointCost'].toDouble();
  }
}
