import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart'; // Import the FlipCard package

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
  
  // Use GlobalKey<FlipCardState> to control the FlipCard.
  // This is the correct way to interact with the FlipCard's state programmatically.
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
        cards.shuffle(); // Shuffle cards once loaded
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load deck"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void markAsKnown() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Marked as known"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    nextCard();
  }

  void markAsUnknown() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Marked as unknown"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    nextCard();
  }

  void nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
      // After moving to the next card, ensure the FlipCard is showing its front.
      // We check if it's currently showing the back and then toggle it.
      if (cardKey.currentState != null && !cardKey.currentState!.isFront) {
        cardKey.currentState!.toggleCard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flashcards",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF00796B),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                      Icon(
                        Icons.warning,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No cards in this deck',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Card Counter
                      Text(
                        '${currentIndex + 1}/${cards.length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Flashcard with Flip Animation
                      FlipCard(
                        key: cardKey, // Assign the key here
                        direction: FlipDirection.HORIZONTAL, // or VERTICAL
                        // When the card is built with a new currentIndex, it defaults to the front.
                        // The toggleCard() in nextCard() ensures it's always front-facing.
                        front: Card(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 180), // Added minHeight for consistent size
                            padding: EdgeInsets.all(32),
                            alignment: Alignment.center, // Center text vertically and horizontally
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
                                // This text is optional, but helps guide the user
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
                            width: double.infinity,
                            constraints: BoxConstraints(minHeight: 180), // Added minHeight for consistent size
                            padding: EdgeInsets.all(32),
                            alignment: Alignment.center, // Center text vertically and horizontally
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

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.clear, color: Colors.white),
                            label: Text(
                              "Unknown",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onPressed: markAsUnknown,
                          ),
                          SizedBox(width: 20),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text(
                              "Known",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00796B), // Changed to match app bar color for "Known"
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
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