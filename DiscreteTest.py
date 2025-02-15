from DiscreteUtils import discretizeHand, discretizeCommunityCards, discretizeAction
from Game import Game
from Card import Card

print ("Pot: 100")
for bet in range(-1, 1200):
    action = discretizeAction(100, bet)
    print ("Bet: " + str(bet) + "; Action: " + str(action))

handDict = {}
handSet = set()
# Simulation tests
for count in range(0, 1000):
    game = Game(0, False)
    game.doAction(0)
    game.doAction(0)
    game.doAction(0)
    game.doAction(0)
#    game.doAction(0)
#    game.doAction(0)
    print ("Community Cards: ")
    for card in game.communityCards:
        print (card)
    for player in game.players:
        hand = player.getCards()
        print ("Hand: ")
        for card in hand:
            print (card)
       handBucket = discretizeHand(hand, game.communityCards)
        communityBucket = discretizeCommunityCards(game.communityCards)
        print ("Hand Bucket: " + str(handBucket))
#        Collision viewing
#        if handBucket in handDict:
#            oldHand = handDict[handBucket]
#            if oldHand != hand:
#                print ("COLLISION!")
#                print ("Bucket: " + str(handBucket))
#                print ("Hand: ")
#                for card in hand:                                                                                               
#                    print (card)
#                print ("Old Hand: ")
#                for card in oldHand:
#                    print (card)
        else:
            handDict[handBucket] = hand
        handSet.add(handBucket)
print ("Hands found: " + str(len(handSet)))

# Unit tests

# River:
discretizeHand([Card(0,1), Card(0,2)], [Card(0,3), Card(0,4), Card(0,5)])
