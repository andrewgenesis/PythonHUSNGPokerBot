#!python
# cython: embedsignature=True, binding=True
from Hand import getHandCategory, getFlushCategory, getStraightCategory

def discretizeAction(potSize, raiseSize):
    raisePercent = float(raiseSize)/potSize
    if raiseSize == -1:
        return raiseSize
    if raisePercent < 0.05:
        return 0
    if raisePercent > 10:
        return -2

    allowedRaises = [0, 0.5, 1, 2, 5, 8]
    return getClosestInList(raisePercent, allowedRaises)            

def getClosestInList(targetValue, closeList):
    closest = None
    minDistance = -1
    for currElement in closeList:
        currDistance = abs(targetValue - currElement)
        if minDistance == -1 or currDistance < minDistance:
            closest = currElement
            minDistance = currDistance
    return closest

# Returns Hand Category, Flush Category, Straight Category
def discretizeCommunityCards(communityCards):
    if not communityCards:
        return None
    
    handCategory = getHandCategory(communityCards)
    flushCategory = getFlushCategory(communityCards)
    straightCategory = getStraightCategory(communityCards)

    return handCategory * 100 + flushCategory * 10 + straightCategory

# Returns
#   Preflop: Rank 1, Rank 2, Onsuit/Offsuit (325 buckets)
#   Postflop and Postturn: Hand Category, Flush Category, Straight Category
#   River: Hand Category, Has Flush, Has Straight (44 buckets)
def discretizeHand(heldCards, communityCards):
    assert heldCards != None
    bettingRound = 0
    
    if communityCards:
        if len(communityCards) == 3:
            bettingRound = 1
        elif len(communityCards) == 4:
            bettingRound = 2
        elif len(communityCards) == 5:
            bettingRound = 3
        
    if bettingRound == 0:
        # Preflop
        sameSuit = 1
        if heldCards[0].getSuit() == heldCards[1].getSuit():
            sameSuit = 2
        return heldCards[0].getRank() * 1000 + heldCards[1].getRank() * 10 + sameSuit
    
    allCards = (heldCards + communityCards)
    handCategory = getHandCategory(allCards)
    flushCategory = getFlushCategory(allCards)
    straightCategory = getStraightCategory(allCards)

#    print ("Hand cat: " + str(handCategory))
#    print ("Flush cat: " + str(flushCategory))
#    print ("Straight category: " + str(straightCategory))
    
    if bettingRound == 1 or bettingRound == 2:
        # Post flop or Post turn
        return handCategory * 100 + flushCategory * 10 + straightCategory
    if bettingRound == 3:
        # River
        hasFlush = 1
        if flushCategory == 0:
            hasFlush = 2
        hasStraight = 1
        if straightCategory == 0:
            hasStraight = 2
        return handCategory * 100 + hasFlush * 10 + hasStraight
