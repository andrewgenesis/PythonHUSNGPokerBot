# Card class to represent a card.

# Stores a suit and a rank
# Abstraction:
#   Suit: (0-3)(C,D,H,S)
#   Rank: (2-14)(2,3,4,5,6,7,8,9,10,J,Q,K,A)
class Card:

    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank

    def getSuit(self):
        return self.suit

    def __eq__(self, other):
        return self.suit == other.suit and self.rank == other.rank
    
    def getRank(self):
        return self.rank

    def __str__(self):
        return "(" + str(self.suit) + ", " + str(self.rank) + ")"
