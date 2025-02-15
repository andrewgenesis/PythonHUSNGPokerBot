import random
from Game import Game
from PokerUtils import PokerInfoSet, PlayerNode

# Test Game
game = Game(0, False)

while not game.isFinished:
    pokerInfoSet = game.getPokerInfoSet()
    game.printCurrGameState()

    actions = pokerInfoSet.getActionChoices()
#    action = random.choice(actions)
    action = float(input ("Player Move. Input Action: "))
                                                                       
    print ("Action: " + str(action))
    game.doAction(action)
    print ("\n\n\n")

game.printCurrGameState()
print ("Dealer Payoff: " + str(game.getPayoffs()))
