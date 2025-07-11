import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardViewer extends StatefulWidget {
  final String deckId;
  FlashcardViewer({required this.deckId});

  @override
  _FlashcardViewerState createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends State<FlashcardViewer> {
  int currentIndex = 0;
  List cards = [];
  bool _isLoading = true;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    fetchDeck();
  }

  void fetchDeck() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .get();
      setState(() {
        cards = List.from(doc['cards']);
        cards.shuffle();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load deck"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void markAsKnown() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Marked as known"),
        backgroundColor: Colors.green,
      ),
    );
    nextCard();
  }

  void markAsUnknown() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Marked as unknown"),
        backgroundColor: Colors.orange,
      ),
    );
    nextCard();
  }

  void nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
      if (cardKey.currentState != null && !cardKey.currentState!.isFront) {
        cardKey.currentState!.toggleCard();
      }
    });
  }

  void _confirmDeleteDeck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Deck"),
        content: Text("Are you sure you want to delete this deck?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _deleteDeck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteDeck() async {
    Navigator.of(context).pop(); // Close dialog
    try {
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deck deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(); // Go back after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete deck"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flashcards",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00796B),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete Deck',
            onPressed: _confirmDeleteDeck,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
              ),
            )
          : cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning,
                          size: 60, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No cards in this deck',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${currentIndex + 1}/${cards.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      FlipCard(
                        key: cardKey,
                        direction: FlipDirection.HORIZONTAL,
                        front: Card(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cards[currentIndex]['question'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00796B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Tap to reveal answer',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        back: Card(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            padding: EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cards[currentIndex]['answer'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.clear, color: Colors.white),
                            label: Text("Unknown"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            onPressed: markAsUnknown,
                          ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text("Known"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00796B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                            onPressed: markAsKnown,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}