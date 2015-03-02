import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:firebase/firebase.dart' as f;
import 'package:core_elements/core_overlay.dart';
import 'package:woven/src/client/app.dart';
import 'package:woven/config/config.dart';
import 'package:core_elements/core_input.dart';
import 'package:woven/src/shared/model/user.dart';
import 'package:woven/src/shared/shared_util.dart';
import 'package:woven/src/client/util.dart';
import '../welcome/welcome.dart';
import 'package:core_elements/core_icon_button.dart';
import 'package:core_elements/core_animation.dart';

import 'package:woven/src/shared/routing/routes.dart';
import 'package:woven/src/shared/response.dart';

@CustomTag('sign-in-dialog')
class SignInDialog extends PolymerElement {
  SignInDialog.created() : super.created();

  @published App app;
  @published bool opened = false;
  var animation = new CoreAnimation();
  var processing = false;


  final fRoot = new f.Firebase(config['datastore']['firebaseLocation']);

  CoreOverlay get overlay => $['dialog-overlay'];
  CoreInput get username => $['username'];
  CoreInput get password => $['password'];
  CoreIconButton get submitButton => $['submit'];

  DateTime get now => new DateTime.now().toUtc();

  /**
   * Toggle the overlay.
   */
  toggleOverlay() => overlay.toggle();

  /**
   * Submit the form and choose what to do.
   */
  submit(Event e) {
    e.preventDefault();
    doSignIn();
  }

  /**
   * Handle sign in.
   */
  doSignIn() {
    if (username.value.trim().isEmpty || password.value.trim().isEmpty) {
      window.alert("Your username and password, please.");
      return false;
    }

    // Disable button and add activity indicator animation.
    toggleProcessingIndicator();

    // Check credentials and sign the user in server side.
    HttpRequest.request(
        Routes.signIn.toString(),
        method: 'POST',
        sendData: JSON.encode({'username': username.value, 'password': password.value}))
    .then((HttpRequest request) {
      // Set up the response as an object.
      Response response = Response.fromJson(JSON.decode(request.responseText));
      if (response.success) {
        // Set up the user.
        UserModel user = UserModel.fromJson(response.data);
        app.user = user;
        // Mark as new so the welcome pops up.
        app.user.isNew = true;
        toggleProcessingIndicator();
        overlay.toggle();
      } else {
        toggleProcessingIndicator();
        window.alert("We don't recognize you. Try again.");
      }
    });
  }

  toggleProcessingIndicator() {
    if (processing) {
      submitButton.classes.remove('disabled');
      animation.cancel();
      processing = false;
    } else {
      submitButton.classes.add('disabled');
      animation.duration = 300;
      animation.iterations = 'Infinity';
      animation.easing = 'ease-in';
      animation.keyframes = [
          {'background-color': 'rgb(64, 136, 214)'},
          {'background-color': 'rgb(73, 168, 255)'},
          {'background-color': 'rgb(64, 136, 214)'}
      ];
      animation.target = submitButton;
      animation.play();
      processing = true;
    }
  }

  toggleSignUp() {
    WelcomeDialog welcome = document.querySelector('woven-app').shadowRoot.querySelector('welcome-dialog');
    this.toggleOverlay();
    welcome.toggleOverlay();
  }

  signInWithFacebook() {
    toggleProcessingIndicator();
    app.signInWithFacebook();
  }

  attached() {
    //
  }
}

