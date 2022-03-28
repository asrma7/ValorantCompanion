import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:valorant_companion/Library/src/url_manager.dart';
import 'package:video_player/video_player.dart';

import '../Library/src/enums.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId, displayName, displayIcon, streamedVideo;
  final double? basePrice, discountedPrice, discountPercent;
  final ItemType itemType;
  const ItemDetailsScreen({
    Key? key,
    required this.itemId,
    required this.itemType,
    required this.displayName,
    required this.displayIcon,
    required this.streamedVideo,
    this.basePrice,
    this.discountedPrice,
    this.discountPercent,
  }) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  ChewieController? _controller;

  @override
  void initState() {
    _controller = ChewieController(
      videoPlayerController: VideoPlayerController.network(
        widget.streamedVideo,
      ),
      aspectRatio: 16 / 9,
      autoPlay: false,
      looping: false,
      autoInitialize: true,
    );
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
                widget.streamedVideo.isNotEmpty
                    ? SizedBox(
                        height: (MediaQuery.of(context).size.width) / 16 * 9,
                        child: Chewie(
                          controller: _controller!,
                        ),
                      )
                    : Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(16.0),
                        child: Image.network(
                          widget.displayIcon,
                          fit: BoxFit.contain,
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
