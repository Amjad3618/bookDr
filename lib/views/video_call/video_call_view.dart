

// lib/views/video_call/video_call_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Thin wrapper around Zego's prebuilt one-on-one video call widget.
// Keeps appID/appSign in ONE place (ZegoConfig) so no other screen has to
// know or repeat those values — they just push VideoCallView with a
// callID + the current user's id/name.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../core/constants/zegoconfigs.dart';


class VideoCallView extends StatelessWidget {
  final String callID;
  final String currentUserID;
  final String currentUserName;

  const VideoCallView({
    super.key,
    required this.callID,
    required this.currentUserID,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    if (ZegoConfig.appID == 0 || ZegoConfig.appSign.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call')),
        body: const Center(
          child: Text('ZegoCloud credentials are missing'),
        ),
      );
    }

    return ZegoUIKitPrebuiltCall(
      appID: ZegoConfig.appID,
      appSign: ZegoConfig.appSign,
      userID: currentUserID,
      userName: currentUserName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}