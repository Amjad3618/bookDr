import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const int kZegoAppID = 1027414689;
const String kZegoAppSign =
    'c95ff708013e259b4fb3429aac01fa15b25fbd55b0d6a29f5a900a315f283700';

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
    if (kZegoAppID == 0 || kZegoAppSign.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Call'),
        ),
        body: const Center(
          child: Text('ZegoCloud credentials are missing'),
        ),
      );
    }

    return ZegoUIKitPrebuiltCall(
      appID: kZegoAppID,
      appSign: kZegoAppSign,
      userID: currentUserID,
      userName: currentUserName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}