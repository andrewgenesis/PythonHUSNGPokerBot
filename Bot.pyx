#!python
# cython: embedsignature=True, binding=True

import ray
import pickle
import random
import os
from copy import deepcopy
from datetime import datetime
from Game import Game
from PokerUtils import PokerInfoSet, PlayerNode
from DecTree import DecTree

from Card import Card

def doTrainingFunct(decTree, stackLevel):
    iterations = 0
    currTree = {}
    updatedNodes = []
    while True:
        print ("Iteration #" + str(iterations))
        if iterations % 100 == 0:
            if iterations != 0:
                # Update main tree with updates
                futures = []
                for toUpdate in updatedNodes:
                    futures.append(decTree.updateTree.remote(toUpdate, currTree[toUpdate]))
                ray.get(futures)

                updatedNodes = []

                # Save tree
                print ("Saving (DO NOT CANCEL) #" + str(iterations/2000))
                ray.get(decTree.saveStrategy.remote())

            # Get updated tree (including other processes updates)
            currTree = ray.get(decTree.getCurrTree.remote())

        startSearch(currTree, updatedNodes, None, None, False, stackLevel)

        iterations += 1

doTraining = ray.remote(doTrainingFunct)

def startSearch(currTree, updatedNodes, game, mainPlayer, isRealtime, stackLevel):
#    print ("Start search...")
#    game.printCurrGameState()

    if not isRealtime:
        game = Game(stackLevel, False)

        # Debug code for single hand testing
        #     game.dealerPlayer.cards = [Card(0,2), Card(1, 7)]
        #     game.nonDealerPlayer.cards = [Card(3,14), Card(2,14)]
        
        # Choose random 'main player'
        mainPlayer = random.randrange(0, 2)

    resultStrategy = _doSearch(currTree, updatedNodes, game, isRealtime, mainPlayer, True)

    if isRealtime:
        return resultStrategy
    

def _doSearch(currTree, updatedNodes, game, isRealtime, mainPlayer, isEntrance):
    if game.getIsFinished():
        return game.getPayoffs()

    pokerInfoSet = game.getPokerInfoSet()            
    nodeExisted, playerNode = getPlayerNode(currTree, pokerInfoSet)

    playerToMove = game.getPlayerToMove()
    isMainPlayer = (playerToMove == mainPlayer)
    
    actions = pokerInfoSet.getActionChoices()
    strategy = playerNode.getStrategy()

    if not isMainPlayer: # Run against a random and a blueprint action to promote exploration
        randGameCopy = deepcopy(game)
        randGameCopy.doAction(random.choice(actions))
        bpGameCopy = deepcopy(game)
        bpGameCopy.doAction(playerNode.getWeightedAction())
        randPayoffs = _doSearch(currTree, updatedNodes, randGameCopy, isRealtime, mainPlayer, False)
        bpPayoffs = _doSearch(currTree, updatedNodes, bpGameCopy, isRealtime, mainPlayer, False)
        return [randPayoffs[0] * .1 + bpPayoffs[0] * .9, randPayoffs[1] * .1 + bpPayoffs[1] * .9]

    strategy = playerNode.getStrategy()
    oppHand = game.getOppHand()

    actionExpectedPayoffs = []
    nodeExpectedPayoffs = [0,0]
    for actionIndex in range(len(actions)):
        action = actions[actionIndex]
        gameCopy = deepcopy(game)
        gameCopy.doAction(action)

        actionPayoffs = _doSearch(currTree, updatedNodes, gameCopy, isRealtime, mainPlayer, False)

        actionExpectedPayoffs.append(actionPayoffs)
        nodeExpectedPayoffs[0] = nodeExpectedPayoffs[0] + actionPayoffs[0] * strategy[actionIndex]
        nodeExpectedPayoffs[1] = nodeExpectedPayoffs[1] + actionPayoffs[1] * strategy[actionIndex]

    # Compute CFR
    for actionIndex in range(len(actions)):
        regret = actionExpectedPayoffs[actionIndex][playerToMove] - nodeExpectedPayoffs[playerToMove]
        playerNode.updateRegret(actionIndex, regret)

    if isRealtime:
        if isEntrance:
            # Realtime entrance, return the strategy calculated
            playerNode.printPlayerNode()
            return playerNode.getStrategy()
    else:
        # This hand is a possibility for the node
        playerNode.addHand(oppHand)

        # Save node into tree and updated nodes list
        setPlayerNode(currTree, pokerInfoSet, playerNode)
        updatedNodes.append(pokerInfoSet.getString())

    return nodeExpectedPayoffs

def getPlayerNode(currTree, pokerInfoSet):
    if pokerInfoSet.getString() in currTree:
        return True, toUtil(currTree[pokerInfoSet.getString()])
    else:
        return False, PlayerNode(pokerInfoSet.getActionChoices())

def hasPlayerNode(currTree, pokerInfoSet):
    if pokerInfoSet.getString() in currTree:
        return True
    else:
        return False

def setPlayerNode(currTree, pokerInfoSet, playerNode):
    currTree[pokerInfoSet.getString()] = playerNode.getString()

def toUtil(string):
    return pickle.loads(string.encode('latin1'))

def startBotTraining():
    random.seed(datetime.now())
    ray.init()
    
    stackLevel = 0 # 0, 1, or 2. Manual switch for training, lookup in seperate files for speed increase
    DecTreeR = ray.remote(DecTree)
    decTree = DecTreeR.remote()
    ray.get(decTree.startAndLoad.remote(stackLevel))
    
    workers = 8
    futures = list()
    for i in range(workers):
        futures.append(doTraining.remote(decTree, stackLevel))
    ray.get(futures)

def realtimeSearch(currTree, game):
    currStrategy = startSearch(currTree, [], game, game.getPlayerToMove(), True, game.getStackLevel())
    return currStrategy

doRealtime = ray.remote(realtimeSearch)

def doRealtimeSearch(currTree, game, possHands):
    actions = game.getPokerInfoSet().getActionChoices()
    
    futures = []
    for i in range(10):
        gameCopy = deepcopy(game)
        gameCopy.newSeed()
        gameCopy.setIsRealtime(False)
        gameCopy.dealOppHands(possHands)
        futures.append(doRealtime.remote(currTree, gameCopy))

    calculatedStrategy = None
    for future in futures:
        currStrategy = ray.get(future)
        if calculatedStrategy == None:
            calculatedStrategy = currStrategy
        else:
            for count in range(len(currStrategy)):
                calculatedStrategy[count] += currStrategy[count]

    bestAction = None
    maxStrategyValue = 0
    for index in range(0, len(calculatedStrategy)):
        currAction = actions[index]
        currStrategy = calculatedStrategy[index]
        if currStrategy > maxStrategyValue:
            maxStrategyValue = currStrategy
            bestAction = currAction

    print ("Strategy: " + str(calculatedStrategy))
            
    return bestAction
