#!python                                                                                                                          # cython: embedsignature=True, binding=True       

import random
from Game import Game
from PokerUtils import PokerInfoSet, PlayerNode
from Card import Card
from Agent import Agent
import ray

ray.init()

def startGame():
    STACK_LEVEL = 2
    agent = Agent(STACK_LEVEL)

    while True:
        agent.resetAgent()
        hand1 = list()
        hand2 = list()
        communityCards = list()

#        print("Dealer hand:")
#        for card in range(0,2):
#            suit = int(input("Suit (0-3): " ))
#            rank = int(input("Rank (2-14): "))
#            hand1.append(Card(suit, rank))
#
#        print("Nondealer2 hand:")
#        for card in range(0,2):
#            suit = int(input("Suit (0-3): " ))
#            rank = int(input("Rank (2-14): "))
#            hand2.append(Card(suit, rank))
#
#        print("Community cards (flop):")
#        for card in range(0,3):
#            suit = int(input("Suit (0-3): " ))
#            rank = int(input("Rank (2-14): "))
#            communityCards.append(Card(suit, rank))

        # Test Game
        game = Game(STACK_LEVEL, False)

#        game.communityCards = communityCards
#        game.bettingRound = 1
#        game.dealerPlayer.cards = hand1
#        game.nonDealerPlayer.cards = hand2

        while not game.getIsFinished():
            pokerInfoSet = game.getPokerInfoSet()
            game.printCurrGameState()

            if game.getPlayerToMove() == 1:
                action = float(input("Non Dealer Move. Input Action: "))
            else:
                print ("Look up action...")
                action = agent.getRealtimeAction(game)
                print ("Dealer Move. Input Action: " + str(action))

            game.doAction(action)

        game.printCurrGameState()
        print ("Payoffs: " + str(game.getPayoffs()) + "\n\n\n\n\n")
