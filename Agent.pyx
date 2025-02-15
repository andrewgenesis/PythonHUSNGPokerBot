#!python
# cython: embedsignature=True, binding=True

import ray
from datetime import datetime
from Game import Game
from PokerUtils import PokerInfoSet, PlayerNode
from DecTree import DecTree
from Bot import hasPlayerNode, getPlayerNode, doRealtimeSearch

class Agent:

    def __init__(self, stackLevel):
        self.stackLevel = stackLevel
        self.lastPossHands = []

        DecTreeR = ray.remote(DecTree)
        decTree = DecTreeR.remote()
        ray.get(decTree.startAndLoad.remote(stackLevel))
                                         
        self.currTree = ray.get(decTree.getCurrTree.remote())
        print ("Agent nodes: " + str(len(self.currTree)))

    def setLastPossHands(self, possHands):
        self.lastPossHands = possHands

    def resetAgent(self):
        self.lastPossHands = []

    def getRealtimeAction(self, game):
        pokerInfoSet = game.getPokerInfoSet()

        nodeExists, playerNode = getPlayerNode(self.currTree, pokerInfoSet)
        playerNode.printPlayerNode()

        if pokerInfoSet.bettingRound == 0:
            action = playerNode.getWeightedAction()
        else:
            action = doRealtimeSearch(self.currTree, game, self.lastPossHands)

        if len(playerNode.getHands()) > 5:
            self.lastPossHands = playerNode.getHands()
        
        return action
