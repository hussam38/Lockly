import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:graduation_project/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/utils/components.dart';
import 'package:graduation_project/utils/values_manager.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _transform;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )..addListener(() {
        setState(() {});
      });

    _transform = Tween<double>(begin: 2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    log("Disposed Admin Register Animation Controller");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: size.height,
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorManager.primarycolor, ColorManager.green],
            ),
          ),
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _transform.value,
              child: SafeArea(
                child: Container(
                  width: size.width * .9,
                  height: size.width * 1.3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSize.s14),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: AppPadding.p20),
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        textFormComponent(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.person,
                          onChanged: (value) {},
                          context: context,
                          hintText: 'Name',
                          validate: (value) {
                            return "";
                          },
                        ),
                        SizedBox(
                          height: size.width * .05,
                        ),
                        textFormComponent(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_rounded,
                          onChanged: (value) {},
                          context: context,
                          hintText: 'Email',
                          validate: (value) {
                            return "";
                          },
                        ),
                        SizedBox(
                          height: size.width * .05,
                        ),
                        textFormComponent(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.call,
                          onChanged: (value) {},
                          context: context,
                          hintText: 'Phone',
                          validate: (value) {
                            return "";
                          },
                        ),
                        SizedBox(
                          height: size.width * .05,
                        ),
                        textFormComponent(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: (value) {},
                          prefixIcon: Icons.lock,
                          suffixIcon: Icons.visibility,
                          context: context,
                          hintText: 'password',
                          isPassword: true,
                          validate: (value) {
                            return "";
                          },
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        buttonComponent(
                          'Register',
                          context,
                          2,
                          () {
                            HapticFeedback.mediumImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
