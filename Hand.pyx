#!python
# cython: embedsignature=True, binding=True

from copy import deepcopy

# Compare two 7 card poker hands
# Return 0 if equal, 1 if hand1 wins, -1 if hand2 wins
def compareHands(hand1, hand2):
    hand1Suits = list()
    hand2Suits = list()
    for card in hand1:
        hand1Suits.append(card.getSuit())
    for card in hand2:
        hand2Suits.append(card.getSuit())

    hand1Suits = sorted(hand1Suits)
    hand2Suits = sorted(hand2Suits)
 
    hand1Ranks = list()
    hand2Ranks = list()
    for card in hand1:
        hand1Ranks.append(card.getRank())
    for card in hand2:
        hand2Ranks.append(card.getRank())

    hand1Ranks = sorted(hand1Ranks)
    hand2Ranks = sorted(hand2Ranks)

    # Remove duplicates to check for straight
    hand1RanksNoDup = list( dict.fromkeys(hand1Ranks))
    hand2RanksNoDup = list( dict.fromkeys(hand2Ranks))
    hand1Straight = False
    hand2Straight = False
    hand1StraightRanks = list()
    hand2StraightRanks = list()

    hand1Flush = False
    hand2Flush = False
    hand1FlushSuit = False
    hand2FlushSuit = False
    # Check for straight and flush in first 5 hand 1
    if len(hand1RanksNoDup) >= 5:
        if hand1RanksNoDup[4] - hand1RanksNoDup[0] == 4:
            hand1Straight = True
            hand1StraightRanks = hand1Ranks[0:4]
    if len(hand1Ranks) >= 5:
        if hand1Suits[0] == hand1Suits[4]:
             hand1Flush = True
             hand1FlushSuit = hand1Suits[0]
    # Check for straight in first 5 hand 2
    if len(hand2RanksNoDup) >= 5:
        if hand2RanksNoDup[4] - hand2RanksNoDup[0] == 4:
            hand2Straight = True
            hand2StraightRanks = hand2Ranks[0:4]
    if len(hand2Ranks) >= 5:
        if hand2Suits[0] == hand2Suits[4]:
             hand2Flush = True
             hand2FlushSuit = hand2Suits[0]
    # Check for straight in second 5 hand 1
    if len(hand1RanksNoDup) >= 6:
        if hand1RanksNoDup[5] - hand1RanksNoDup[1] == 4:
            hand1Straight = True
            hand1StraightRanks = hand1Ranks[1:5]
    if len(hand1Ranks) >= 6:
        if hand1Suits[1] == hand1Suits[5]:
             hand1Flush = True
             hand1FlushSuit = hand1Suits[1]
    # Check for straight in second 5 hand 2
    if len(hand2RanksNoDup) >= 6:
        if hand2RanksNoDup[5] - hand2RanksNoDup[1] == 4:
            hand2Straight = True
            hand2StraightRanks = hand2Ranks[1:5]
    if len(hand2Ranks) >= 6:
        if hand2Suits[1] == hand2Suits[5]:
             hand2Flush = True
             hand2FlushSuit = hand2Suits[1]
    # Check for straight in last 5 hand 1
    if len(hand1RanksNoDup) == 7:
        if hand1RanksNoDup[6] - hand1RanksNoDup[2] == 4:
            hand1Straight = True
            hand1StraightRanks = hand1Ranks[2:6]
    if len(hand1Ranks) >= 7:
        if hand1Suits[2] == hand1Suits[6]:
             hand1Flush = True
             hand1FlushSuit = hand1Suits[2]
    # Check for straight in last 5 hand 2
    if len(hand2RanksNoDup) == 7:
        if hand2RanksNoDup[6] - hand2RanksNoDup[2] == 4:
            hand2Straight = True
            hand2StraightRanks = hand2Ranks[2:6]
    if len(hand2Ranks) >= 7:
        if hand2Suits[2] == hand2Suits[6]:
             hand2Flush = True
             hand2FlushSuit = hand2Suits[2]

    # Check for straight flush
    hand1StraightFlush = hand1Straight and hand1Flush
    hand2StraightFlush = hand2Straight and hand2Flush
    if hand1StraightFlush or hand2StraightFlush:            
        if hand1StraightFlush and hand2StraightFlush:
            # Tie breaker with max card
            if max(hand1StraightRanks) > max(hand2StraightRanks):
                return 1
            if max(hand2StraightRanks) > max(hand1StraightRanks):
                return -1
            return 0
        else:            
            if hand1StraightFlush:
                return 1
            return -1

    # Check for 4 of a kind
    hand14k = matches(hand1Ranks, 4)
    hand24k = matches(hand2Ranks, 4)
    if hand14k or hand24k:
        if hand14k and hand24k:
            return breakTieMaxCard(hand1Ranks, hand2Ranks)
        else:
            if hand14k:
                return 1
            return -1

    # Check for full house
    hand1FH = matches(hand1Ranks, 3) and (matches(hand1Ranks, 2, matches(hand1Ranks, 3)))
    hand2FH = matches(hand2Ranks, 3) and (matches(hand2Ranks, 2, matches(hand2Ranks, 3)))
    if hand1FH or hand2FH:
        if hand1FH and hand2FH:
            # Tie breaker with three of a kind rank
            hand13Rank = maxMatches(hand1Ranks, 3)
            hand23Rank = maxMatches(hand2Ranks, 3)
            if hand13Rank > hand23Rank:
                return 1
            elif hand23Rank > hand13Rank:
                return -1
            else:
                # Tie breaker with pair rank
                hand1PairRank = maxMatches(hand1Ranks, 2, matches(hand1Ranks, 3))
                hand2PairRank = maxMatches(hand2Ranks, 2, matches(hand2Ranks, 3))
                if hand1PairRank > hand2PairRank:
                    return 1
                elif hand2PairRank > hand1PairRank:
                    return -1
                return 0
        else:
            if hand1FH:
                return 1
            return -1

    if hand1Flush or hand2Flush:
        if hand1Flush and hand2Flush:
            # Tie breaker with max card of the respective suit
            if maxSuited(hand1, hand1FlushSuit) > maxSuited(hand2, hand2FlushSuit):
                return 1
            if maxSuited(hand2, hand2FlushSuit) > maxSuited(hand1, hand1FlushSuit):
                return -1
            return 0
        else:
            if hand1Flush:
                return 1
            return -1
        
    if hand1Straight or hand2Straight:
        if hand1Straight and hand2Straight:
            # Tie breaker with max card of straight hand
            if max(hand1StraightRanks) > max(hand2StraightRanks):
                return 1
            if max(hand2StraightRanks) > max(hand1StraightRanks):
                return -1
            return 0
        else:
            if hand1Straight:
                return 1
            return -1
        

    hand13 = matches(hand1Ranks, 3)
    hand23 = matches(hand2Ranks, 3)
    if hand13 or hand23:
        if hand13 and hand23:
            # Tie breaker with 3 value
            if maxMatches(hand1Ranks, 3) > maxMatches(hand2Ranks, 3):
                return 1
            elif maxMatches(hand2Ranks, 3) > maxMatches(hand1Ranks, 3):
                return -1
            else:
                return breakTieMaxCard(hand1Ranks, hand2Ranks)
        else:
            if hand13:
                return 1
            return -1

    hand122 = matches(hand1Ranks, 2) and matches(hand1Ranks, 2, matches(hand1Ranks, 2))
    hand222 = matches(hand2Ranks, 2) and matches(hand2Ranks, 2, matches(hand2Ranks, 2))
    if hand122 or hand222:
        if hand122 and hand222:
            # Tie breaker with pair 1
            if matches(hand1Ranks, 2) > matches(hand2Ranks, 2):
                return 1
            elif matches(hand2Ranks, 2) > matches(hand1Ranks, 2):
                return -1
            else:
                # Tie breaker with pair 2
                if matches(hand1Ranks, 2, matches(hand1Ranks, 2)) > matches(hand2Ranks, 2, matches(hand2Ranks, 2)):
                    return 1
                elif matches(hand2Ranks, 2, matches(hand2Ranks, 2)) > matches(hand1Ranks, 2, matches(hand1Ranks, 2)):
                    return -1
                else:
                    return breakTieMaxCard(hand1Ranks, hand2Ranks)
        else:
            if hand122:
                return 1
            return -1

    hand12 = matches(hand1Ranks, 2)
    hand22 = matches(hand2Ranks, 2)
    if hand12 or hand22:
        if hand12 and hand22:
            # Tie breaker with pair
            if matches(hand1Ranks, 2) > matches(hand2Ranks, 2):
                return 1
            elif matches(hand2Ranks, 2) > matches(hand1Ranks, 2):
                return -1
            else:
                return breakTieMaxCard(hand1Ranks, hand2Ranks)
        else:
            if hand12:
                return 1
            return -1

    # Both hands high card, break "tie" with max card
    return breakTieMaxCard(hand1Ranks, hand2Ranks)

# Input: cards = list of between 2 and 7 cards
# Output: best handCategory that these cards can make
def getHandCategory(cards):
    assert cards != None

    handRanks = []
    for card in cards:
        handRanks.append(card.getRank())
    handSuits = []
    for card in cards:
        handSuits.append(card.getSuit())

    sortedRanks = sorted(handRanks)
    sortedSuits = sorted(handSuits)

    if matches(handRanks, 4):
        return 1

    if matches(handRanks, 3) and (matches(handRanks, 2, matches(handRanks, 3))):
        return 2

    if matches(handRanks, 3):
        if maxMatches(handRanks, 3) >= 10:
            return 3 # >=10 3 of a kind
        else:
            return 4 # <10 3 of a kind

    if matches(handRanks, 2) and matches(handRanks, 2, matches(handRanks, 2)):
        if maxMatches(handRanks, 2) >= 10:
            return 5 # >=10 2 pair
        else:
            return 6 # <10 2 pair

    if matches(handRanks, 2):
        if maxMatches(handRanks, 2) >= 11:
            return 7 # Face pair
        elif maxMatches(handRanks, 2) >= 6:
            return 8 # >=6 <=10 pair
        else:
            return 9 # <6 pair

    if max(handRanks) >= 10:
        return 10 # >= 10 High Card
    return 11 # <10 High Card


# Returns rank if number of matching cards is found
# Cards can not be of rank excluded
def matches(ranks, number, excluded=None):
    for rank in ranks:
        if ranks.count(rank) == number and rank != excluded:
            return rank
    return None

# Returns max rank if number of matching cards is found
def maxMatches(ranks, number, excluded=None):
    maxRank = None
    for rank in ranks:
        if ranks.count(rank) == number and (maxRank == None or rank > maxRank) and rank != excluded:
            maxRank = rank
    return maxRank

# Returns max card rank of cards with suit
def maxSuited(hand, suit):
    maxRank = None
    for card in hand:
        if card.getSuit() == suit and (maxRank == None or card.getRank() > maxRank):
            maxRank = card.getRank()
    return maxRank

# Break a tie with a max card
def breakTieMaxCard(hand1Ranks, hand2Ranks):
    # Tie breaker with remaining max card
    hand1RanksCopy = deepcopy(hand1Ranks)
    hand2RanksCopy = deepcopy(hand2Ranks)
    maxHand1 = 0
    maxHand2 = 0
    while maxHand1 == maxHand2 and (len(hand1RanksCopy) >= 0 or len(hand2RanksCopy) >= 0):
        if len(hand1RanksCopy) == 0 and len(hand2RanksCopy) != 0:
            return -1
        if len(hand2RanksCopy) == 0 and len(hand1RanksCopy) != 0:
            return 1
        if len(hand1RanksCopy) == 0 and len(hand2RanksCopy) == 0:
            return 0
        
        maxHand1 = max(hand1RanksCopy)
        maxHand2 = max(hand2RanksCopy)

        hand1RanksCopy.remove(maxHand1)
        hand2RanksCopy.remove(maxHand2)

        if maxHand1 > maxHand2:
            return 1
        if maxHand2 > maxHand1:
            return -1
    return 0

# Returns lowest amount of suited of cards needed for a flush
def getFlushCategory(cards):
    assert cards != None

    handSuits = []
    for card in cards:
        handSuits.append(card.getSuit())
    sortedCards = sorted(handSuits)
    
    suits = [0,1,2,3]
    maxSuited = 0
    for suit in suits:
        suitCount = sortedCards.count(suit)
        if suitCount > maxSuited:
            maxSuited = suitCount
    
    cardsForFlush = 5 - maxSuited
    return cardsForFlush

# Returns
#     Amount of cards needed for a straight (0, 2, or 3)
#     If one card, amount of straights possible (4 or 5)
#         5 buckets
def getStraightCategory(cards):
    assert cards != None

    handRanks = []
    for card in cards:
        handRanks.append(card.getRank())
    sortedCards = sorted(handRanks)

    # Possible straights (Where Ace is 1):
    # 14-5, 2-6, 3-7, 4-8, 5-9, 6-10, 7-11, 8-12, 9-13, 10-1
    # Outs needed for each possible straight
    outsNeededList  = [5,5,5,5,5,5,5,5,5,5]
    # Cards 2 - 14, 1 if in hand otherwise 0
    uniqueCards = [0,0,0,0,0,0,0,0,0,0,0,0,0] 

    for card in sortedCards:
        uniqueCards[card - 2] = 1

    # Check 14-5 (A-5)
    outsNeeded = 5
    if uniqueCards[12] == 1:
        outsNeeded = outsNeeded - 1
    for i in range(0,3):
        if uniqueCards[i] == 1:
            outsNeeded = outsNeeded - 1
    outsNeededList[9] = outsNeeded

    # Check rest
    for startPos in range(9):
        outsNeeded = 5
        for i in range(startPos, startPos + 5):
            if uniqueCards[i] == 1:
                outsNeeded = outsNeeded - 1
        outsNeededList[startPos] = outsNeeded

    minOutsNeeded = min(outsNeededList)
    if minOutsNeeded == 1:
        straightsCount = outsNeededList.count(minOutsNeeded)
        if straightsCount == 1:
            return 4
        else:
             return 5
    if minOutsNeeded < 3:
        return minOutsNeeded
    return 3
