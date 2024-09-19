import 'package:animated_login/animation_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Artboard? riveArtBoard;
  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerLookLeft;
  late RiveAnimationController controllerLookRight;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String testEmail = "dina@gmail.com";
  String testPassword = "123456";
  final passwordFocusNode = FocusNode();

  bool isLookingLeft = false;
  bool isLookingRight = false;

  void removeAllControllers() {
    riveArtBoard?.artboard.removeController(controllerIdle);
    riveArtBoard?.artboard.removeController(controllerHandsUp);
    riveArtBoard?.artboard.removeController(controllerHandsDown);
    riveArtBoard?.artboard.removeController(controllerLookLeft);
    riveArtBoard?.artboard.removeController(controllerLookRight);
    riveArtBoard?.artboard.removeController(controllerSuccess);
    riveArtBoard?.artboard.removeController(controllerFail);
    isLookingLeft = false;
    isLookingRight = false;
  }

  void addSpecificAnimationAction(RiveAnimationController<dynamic> neededAnimationAction) {
    removeAllControllers();
    riveArtBoard?.artboard.addController(neededAnimationAction);
  }

  @override
  void dispose() {
    passwordFocusNode.removeListener;
    super.dispose();
  }




  void checkForPasswordFocusNodeToChangeAnimationState() {
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        addSpecificAnimationAction(controllerHandsUp);
      } else if (!passwordFocusNode.hasFocus) {
        addSpecificAnimationAction(controllerHandsDown);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controllerIdle = SimpleAnimation(AnimationEnum.idle.name);
    controllerHandsUp = SimpleAnimation(AnimationEnum.Hands_up.name);
    controllerHandsDown = SimpleAnimation(AnimationEnum.hands_down.name);
    controllerLookRight = SimpleAnimation(AnimationEnum.Look_down_right.name);
    controllerLookLeft = SimpleAnimation(AnimationEnum.Look_down_left.name);
    controllerSuccess = SimpleAnimation(AnimationEnum.success.name);
    controllerFail = SimpleAnimation(AnimationEnum.fail.name);

    loadRiveFileWithItsStates();

    checkForPasswordFocusNodeToChangeAnimationState();
  }

  void loadRiveFileWithItsStates() {
    rootBundle.load('assets/login_animation.riv').then(
          (data) {
        final file = RiveFile.import(data);
        final artBoard = file.mainArtboard;
        artBoard.addController(controllerIdle);
        setState(() {
          riveArtBoard = artBoard;
        });
      },
    );
  }

  void validateEmailAndPassword() {
    Future.delayed(const Duration(seconds: 1), () {
      if (formKey.currentState!.validate()) {
        addSpecificAnimationAction(controllerSuccess);
      } else {
        addSpecificAnimationAction(controllerFail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Animated Login'),
      centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric( horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(
                height: 250.h,
                child: riveArtBoard == null
                    ? const SizedBox.shrink()
                    : Rive(
                  artboard: riveArtBoard!,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      validator: (value) =>
                      value != testEmail ? "Wrong email" : null,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            value.length < 16 &&
                            !isLookingLeft) {
                          addSpecificAnimationAction(controllerLookLeft);
                        } else if (value.isNotEmpty &&
                            value.length > 16 &&
                            !isLookingRight) {
                          addSpecificAnimationAction(controllerLookRight);
                        }
                      },
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      focusNode: passwordFocusNode,
                      validator: (value) =>
                      value != testPassword ? "Wrong password" : null,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          passwordFocusNode.unfocus();
                          validateEmailAndPassword();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}