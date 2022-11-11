import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './message_bubble.dart';

class Messages extends StatelessWidget {
  void _tapped(dynamic output) async {
    FirebaseFirestore.instance.collection('chat').doc(output).delete();
  }

  Widget buildContainer() {
    return IconButton(icon: const Icon(Icons.delete));
  }

  @override
  Widget build(BuildContext context) {
    // gets the current user
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.docs;
        return ListView.builder(
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) =>
                //IconButton(icon: const Icon(Icons.delete))
                //onTap: () => _tapped(chatDocs[index].id),

                Column(
                    crossAxisAlignment: chatDocs[index]['userId'] == user.uid
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      MessageBubble(
                        chatDocs[index]['text'],
                        chatDocs[index]['userId'],
                        chatDocs[index]['userId'] == user.uid,
                        key: ValueKey(chatDocs[index].id),
                      ),
                      if (chatDocs[index]['userId'] == user.uid)
                        IconButton(
                          iconSize: 20,
                          icon: new Icon(Icons.delete),
                          onPressed: () {
                            _tapped(chatDocs[index].id);
                          },
                        ),
                    ]));
      },
    );
  }
}
