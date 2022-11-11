import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';

import '../widgets/chat/messages.dart';
import '../widgets/chat/new_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _isConfetti = false;
  var _isStars = false;
  ConfettiController confettiController;
  ConfettiController starController;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    starController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    confettiController.dispose();
    starController.dispose();
    super.dispose();
  }

  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('chat').add(
      {
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      },
    );
    _controller.clear();
    if (_isConfetti) {
      confettiController.play();
    }
    if (_isStars) {
      starController.play();
    }
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('FlutterChat'),
            actions: [
              DropdownButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'confetti',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.celebration,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('Send With Confetti'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'stars',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('Send With Stars'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'nothing',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.stop,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('No Animation'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'logout',
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text('Logout'),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (itemIdentifier) {
                  if (itemIdentifier == 'logout') {
                    FirebaseAuth.instance.signOut();
                  } else if (itemIdentifier == 'confetti') {
                    // display confetti
                    setState(() {
                      _isConfetti = true;
                      _isStars = false;
                    });
                  } else if (itemIdentifier == 'stars') {
                    // display stars
                    setState(() {
                      _isStars = true;
                      _isConfetti = false;
                    });
                  } else if (itemIdentifier == 'nothing') {
                    // should send with no animation
                    setState(() {
                      _isStars = false;
                      _isConfetti = false;
                    });
                  }
                },
              ),
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Messages(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                              labelText: 'Send a message...'),
                          onChanged: (value) {
                            setState(() {
                              _enteredMessage = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        color: Theme.of(context).primaryColor,
                        icon: const Icon(
                          Icons.send,
                        ),
                        onPressed: _enteredMessage.trim().isEmpty
                            ? null
                            : _sendMessage,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: confettiController,
          shouldLoop: false,
          blastDirectionality:
              BlastDirectionality.explosive, // make this come from the top
          numberOfParticles: 50,
        ),
        ConfettiWidget(
          confettiController: starController,
          shouldLoop: false,
          blastDirectionality:
              BlastDirectionality.explosive, // make this come from the top
          numberOfParticles: 50,
          createParticlePath: drawStar, // makes it so that stars shoot out
        )
      ],
    );
  }
}
