#!python
# cython: embedsignature=True, binding=True

from random import Random
from datetime import datetime
from copy import deepcopy
from Card import Card
from PokerUtils import PokerInfoSet
from DiscreteUtils import discretizeHand, discretizeCommunityCards
from Hand import compareHands

class GamePlayer():
    def __init__(self, stack):
        self.stack = stack
        self.cards = list()
        self.folded = False

    def isFolded(self):
        return self.folded

    def setFolded(self, folded):
        self.folded = folded

    def clearCards(self):
        self.cards = list()

    def setCards(self, card1, card2):
        self.clearCards()
        self.cards.append(card1)
        self.cards.append(card2)

    def getCards(self):
        return self.cards

    def subtractFromStack(self, amount):
        self.stack -= amount
        
    def addToStack(self, amount):
        self.stack += amount

    def getStack(self):
        return self.stack

# Simulates a HU NLTH game
class Game:
    def __init__(self, stackLevel, isRealtime):
        self.randomGen = Random()
        self.newSeed()
        self.INIT_STACK_SIZE = 1500
        
        if stackLevel == 0:
            self.SMALL_BLIND = 15
            self.BIG_BLIND = 30
        elif stackLevel == 1:
            self.SMALL_BLIND = 50
            self.BIG_BLIND = 100
        elif stackLevel == 2:
            self.SMALL_BLIND = 100
            self.BIG_BLIND = 200
        self.stackLevel = stackLevel
        self.isRealtime = isRealtime
        
        # Declare game state variables
        self.pot = 0
        self.isFinished = False

        self.deck = [] # Game deck of cards
        # Populate deck
        for suit in range(0, 4):
            for rank in range(2, 15):
                self.deck.append(Card(suit, rank))
                
        # Shuffle deck
        self.randomGen.shuffle(self.deck)
        
        self.communityCards = []

        self.players = []
        # Populate both players and deal them cards
        for playerIndex in range(0,2):
            playerToAdd = GamePlayer(self.INIT_STACK_SIZE)
            if not self.isRealtime:
                playerToAdd.setCards(self._getTopCard(), self._getTopCard())
            self.players.append(playerToAdd)

        self.dealerPlayer = self.players[0]
        self.nonDealerPlayer = self.players[1]
        self.bettingRound = 0
        self.roundActions = []
    
        # Post blinds (dealer player posts small blind, opponent posts big blind)
        self.dealerPlayer.subtractFromStack(self.SMALL_BLIND)
        self.pot += self.SMALL_BLIND
        self.nonDealerPlayer.subtractFromStack(self.BIG_BLIND)
        self.pot += self.BIG_BLIND    
        self.lastPotAddition = self.BIG_BLIND - self.SMALL_BLIND
        self.playerToMove = 0

    def setIsRealtime(self, isRealtime):
        self.isRealtime = isRealtime

    def newSeed(self):
        self.randomGen.seed(datetime.now()) # Seed RNG with current time

    def getIsFinished(self):
        return self.isFinished

    def getStackLevel(self):
        return self.stackLevel

    def getOppHand(self):
        return self.getNonMovingPlayer().getCards()

    def dealOppHands(self, hands):
        oppPlayer = self.getNonMovingPlayer()

        # Remove cards, add to deck
        for card in oppPlayer.getCards():
            self.deck.append(card)
        oppPlayer.clearCards()

        self.randomGen.shuffle(hands)
        self.randomGen.shuffle(self.deck)

        for hand in hands:
            isValid = False
            for card in hand:
                if card in self.deck:
                    isValid = False

            if isValid: # All cards in hand are in deck
                # Deal to non-main player
                oppPlayer.setCards(hand[0], hand[1])
                return

        # Deal random hand to non-main player (no hands were valid)
        oppPlayer.setCards(self._getTopCard(), self._getTopCard())

    def _getTopCard(self):
        return self.deck.pop(0)

    def getPokerInfoSet(self):
        currPlayer = self.players[self.playerToMove]

        playerHand = discretizeHand(currPlayer.getCards(), self.communityCards)
        communityHand = discretizeCommunityCards(self.communityCards)
        
        return PokerInfoSet(playerHand, communityHand, self.roundActions, self.bettingRound, self.stackLevel)

    def _drawCards(self):
        if not self.isRealtime:
            if self.bettingRound == 0:
                # Deal flop
                # print ("Deal flop")
                self.communityCards.append(self._getTopCard())
                self.communityCards.append(self._getTopCard())
                self.communityCards.append(self._getTopCard())
            elif self.bettingRound == 1 or self.bettingRound == 2:
                # Deal turn/river
                # print ("Deal turn/river")
                self.communityCards.append(self._getTopCard())

        # Reset last pot addition and round actions
        self.roundActions = []
        self.lastPotAddition = 0
        self.playerToMove = 1

        # Increment betting round
        self.bettingRound += 1

    def getPlayerToMove(self):
        return self.playerToMove

    def getMovingPlayer(self):
        return self.players[self.playerToMove]

    def getNonMovingPlayer(self):
        return self.players[(self.playerToMove + 1) % 2]

    def _doCall(self):
        currPlayer = self.getMovingPlayer()
        currPlayer.subtractFromStack(self.lastPotAddition)
        self.pot += self.lastPotAddition
        self.lastPotAddition = 0
        
    # Do a action for player to move
    def doAction(self, action):
        assert action != None

        called = False
        
        currPlayer = self.getMovingPlayer()        
        oppPlayer = self.getNonMovingPlayer()
        if action == -1: # Fold
            currPlayer.setFolded(True)
            oppPlayer.addToStack(self.pot)
            self.pot = 0
            self._setFinished(False)
        elif action == 0: # Call
            self._doCall()
            called = True
            self.roundActions.append(0)
        else:
            preCallPot = self.pot
            self._doCall()
            called = True
            raiseAmount = -1
            if currPlayer.getStack() > 0 and oppPlayer.getStack() > 0:
                called = False
                if action == -2:
                    raiseAmount = min(currPlayer.getStack(), oppPlayer.getStack())
                if action > 0:
                    raiseAmount = min(currPlayer.getStack(), oppPlayer.getStack(), action * preCallPot)

                self.lastPotAddition = raiseAmount
                currPlayer.subtractFromStack(raiseAmount)
                self.pot += raiseAmount
                self.roundActions.append(action)
        
        if called and (currPlayer.getStack() == 0 or oppPlayer.getStack() == 0):
            # A player called a raise and a player is all in, game is finished
            self._setFinished(True)
            return
        elif called and len(self.roundActions) > 1:
            # A previous action was called
            if self.bettingRound < 3:
                # Go to the next round if not river
                self._drawCards()
            else:
                # River, game finished
                self._setFinished(True)
            return

        # There was a raise or this is first call of round, so other player to move.
        self.playerToMove = (self.playerToMove + 1) % 2

    def _setFinished(self, showdown):
        if showdown:
            while self.bettingRound < 3:
                self._drawCards()
        self.isFinished = True

    def _doShowdown(self):
        player1Hand = self.players[0].getCards() + self.communityCards
        player2Hand = self.players[1].getCards() + self.communityCards

        winner = compareHands(player1Hand, player2Hand)
        if winner == 1:
            self.players[0].addToStack(self.pot)
        elif winner == -1:
            self.players[1].addToStack(self.pot)
        else:
            self.players[0].addToStack(self.pot / 2)
            self.players[1].addToStack(self.pot / 2)

    def getPayoffs(self):
        self._doShowdown()
        payoffs = []
        for currPlayer in self.players:
            payoffs.append(currPlayer.getStack() - self.INIT_STACK_SIZE)
        return payoffs

    def printCurrGameState(self):
        print ("Stack level: " + str(self.stackLevel))
        print ("Realtime?: " + str(self.isRealtime))
        print ("Pot: " + str(self.pot))
        print ("Last pot addition: " + str(self.lastPotAddition))
        print ("Finished? " + str(self.isFinished))
        print ("Community cards: ")
        for card in self.communityCards:
            print ("\t" + str(card))
        print ("Player 0: ")
        print ("\t" + str(self.players[0].getStack()))
        for card in self.players[0].getCards():
            print ("\t" + str(card))
        print ("Player 1: ")
        print ("\t" + str(self.players[1].getStack()))
        for card in self.players[1].getCards():
            print ("\t" + str(card))
        print ("Dealer player: " + str(self.dealerPlayer) + ", Non-Dealer player: " + str(self.nonDealerPlayer))
        print ("Betting round: " + str(self.bettingRound))
        print ("Round actions: " +str(self.roundActions))
