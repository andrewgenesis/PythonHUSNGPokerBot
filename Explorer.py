import ray
import random
import pickle
from PokerUtils import PokerInfoSet, PlayerNode
from DecTree import DecTree

# Train until ~150 per starting hand

def toUtil(string):
    return pickle.loads(string.encode('latin1'))

ray.init()

STACK_LEVEL = 0

DecTreeR = ray.remote(DecTree)
decTree = DecTreeR.remote()
ray.get(decTree.startAndLoad.remote(STACK_LEVEL))

currTree = ray.get(decTree.getCurrTree.remote())

found = 0
for pokerInfoSetStr, playerNodeStr in currTree.items():
    pokerInfoSet = toUtil(pokerInfoSetStr)
    playerNode = toUtil(playerNodeStr)

    if pokerInfoSet.bettingRound == 0 and len(pokerInfoSet.roundActions) == 0:
        print (playerNode.exploreCount)
        found += 1

print ("\n\n\nFound: " + str(found))
