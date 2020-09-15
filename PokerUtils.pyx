#!python
# cython: embedsignature=True, binding=True

import random
import pickle
from datetime import datetime

def toUtil(string):
    return pickle.loads(string.encode('latin1'))

class PokerInfoSet():
    # Player hand (Pre flop: rank 1, suit 1, rank 2, suit 2, After flop: Bucketed)
    # Community hand (Bucketed)
    # Betting round (calculated from community cards)
    # Round Actions (list of actions that have been made this betting round, alternating players)
    # Action choices (list of actions that can be chosen)
    # Stack level (0 = deep stacked (? BBs), 1 = mid stacked (? BBs), 2 = short stacked (? BBs))
    def __init__(self, playerHand, communityHand, roundActions, bettingRound, stackLevel):
        self.playerHand = playerHand
        self.communityHand = communityHand
        self.roundActions = roundActions
        self.bettingRound = bettingRound
        self.stackLevel = stackLevel

        noFold = (len(roundActions) == 0 or roundActions[len(roundActions) - 1] == 0) # Can't fold if first move or if opponent checks to us
        
        # Generate action choices
        if len(roundActions) <= 2:
            if self.bettingRound <= 1: # Pre or post flop
                if noFold:
                    self.actionChoices = [-2, 0, 0.5, 1, 2, 5]
                else:
                    self.actionChoices = [-2, -1, 0, 0.5, 1, 2, 5]
            else: # Post turn or post river
                if noFold:
                    self.actionChoices = [-2, 0, 0.5, 1]
                else:
                    self.actionChoices = [-2, -1, 0, 0.5, 1]
        elif len(roundActions) <= 4: # Second raising round
            if noFold:
                self.actionChoices = [-2, 0, 0.5, 1]
            else:
                self.actionChoices = [-2, -1, 0, 0.5, 1]
        else: # Third raising round or later
            if noFold:
                self.actionChoices = [0]
            else:
                self.actionChoices = [-1, 0]

    def printInfoSet(self):
        print("Player hand: " + str(self.playerHand))
        print("Community hand: " + str(self.communityHand))
        print("Betting round: " + str(self.bettingRound))
        print("Round actions: " + str(self.roundActions))
        print("Stack level: " + str(self.stackLevel))

    def getString(self):
        return pickle.dumps(self).decode('latin1')

    def getActionChoices(self):
        return self.actionChoices

class PlayerNode():
    # Action num (# of possible actions from this state)
    # Possible hands (20 most recent hands seen by visitors to this node)
    # Parallel arrays:
    #   Actions (actual discretized action) (for lookup with parallel arrays)
    #   Regret sum (loss vector for each strategy)
    #   Strategy (weight vector for each action)
    #   Explore count (counts times each actions CFR was updated)
    def __init__(self, actions):
        random.seed(datetime.now()) # Seed RNG with current time  

        self.actionNum = len(actions)
        self.actions = actions

        self.possHands = [] # Store last 20 hands played

        self.regretSum = []
        self.strategy = []
        self.exploreCount = []
        for action in actions:
            self.regretSum.append(0.0)
            self.strategy.append(0.0)
            self.exploreCount.append(0)

    def printPlayerNode(self):
        print ("Actions: " + str(self.actions))
        print ("Strategy: " + str(self.getStrategy()))
        print ("Regret Sum: " + str(self.regretSum))
        print ("Explores: " + str(self.exploreCount))
        print ("Poss hands: " + str(len(self.possHands)))
#        for hand in self.possHands:
#            print ("[")
#            for card in hand:
#                print (str(card))
#            print ("]")
        
    def getBestAction(self):
        strategy = self.getStrategy()
        bestAction = None
        maxStrategyValue = 0
        for index in range(0, len(strategy)):
            currAction = self.actions[index]
            currStrategy = strategy[index]
            if currStrategy > maxStrategyValue:
                maxStrategyValue = currStrategy
                bestAction = currAction

        return bestAction

    # Get current strategy (Regret-Matching)
    def getStrategy(self):
        normalizingSum = 0.0;
        for actionIndex in range(0, self.actionNum):
            if self.regretSum[actionIndex] > 0:
                self.strategy[actionIndex] = self.regretSum[actionIndex]
            else:
                self.strategy[actionIndex] = 0
            normalizingSum += self.strategy[actionIndex]
            
        for actionIndex in range(0, self.actionNum):
            if normalizingSum > 0:
                self.strategy[actionIndex] /= normalizingSum
            else:
                self.strategy[actionIndex] = 1.0 / self.actionNum
            
        return self.strategy

    # Get action based on strategy weights randomly
    def getWeightedAction(self):
        return random.choices(population=self.actions, weights=self.getStrategy())[0]
    
    # Get cumulative counterfactual regret of the specified action     
    def getRegretSum(self, actionIndex):
        return self.regretSum[actionIndex]

    # Update cumulative counterfactual regret
    def updateRegret(self, actionIndex, value):
        self.exploreCount[actionIndex] += 1
        weightedValue = value * min(self.exploreCount[actionIndex], 1000)
        self.regretSum[actionIndex] += weightedValue

    def getActionNum(self):
        return self.actionNum

    def getString(self):
        return pickle.dumps(self).decode('latin1')

    def addHand(self, hand):
        if hand not in self.possHands:
            if len(self.possHands) >= 20:
                self.possHands.pop()
            self.possHands.append(hand)

    def getHands(self):
        return self.possHands
