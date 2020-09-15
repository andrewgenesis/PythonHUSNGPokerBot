from Card import Card
from Hand import compareHands

High9 = [Card(0, 3), Card(0, 9), Card(1, 2), Card(1, 4),
         Card(0, 6), Card(2, 7), Card(2, 8)]
HighAce = [Card(1, 2), Card(0, 5), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 1), Card(2, 8)]

Highs = [High9, HighAce]

for index1 in range(0, len(Highs)):
    assert(compareHands(Highs[index1], Highs[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Highs[index1], Highs[index2]) == 1)
        assert(compareHands(Highs[index2], Highs[index1]) == -1)

Pair3 = [Card(1, 2), Card(0, 3), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 14), Card(2, 8)]
Pair8 = [Card(1, 2), Card(0, 12), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 8), Card(2, 8)]
PairAce = [Card(1, 2), Card(0, 12), Card(1, 14), Card(1, 11),
         Card(0, 6), Card(2, 8), Card(2, 14)]
Pairs = [Pair3, Pair8, PairAce]

for index1 in range(0, len(Pairs)):
    assert(compareHands(Pairs[index1], Pairs[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Pairs[index1], Pairs[index2]) == 1)
        assert(compareHands(Pairs[index2], Pairs[index1]) == -1)
for Pair in Pairs:
    for High in Highs:
        assert(compareHands(Pair, High) == 1)
        assert(compareHands(High, Pair) == -1)
        
Trips3 = [Card(1, 2), Card(0, 3), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 3), Card(2, 8)]
Trips8 = [Card(1, 2), Card(0, 8), Card(1, 8), Card(1, 11),
         Card(0, 6), Card(2, 3), Card(2, 8)]
TripsAce = [Card(1, 14), Card(0, 9), Card(1, 3), Card(1, 11),
         Card(0, 14), Card(2, 14), Card(2, 12)]
Trips = [Trips3, Trips8, TripsAce]

for index1 in range(0, len(Trips)):
    assert(compareHands(Trips[index1], Trips[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Trips[index1], Trips[index2]) == 1)
        assert(compareHands(Trips[index2], Trips[index1]) == -1)
for Trip in Trips:
    for High in Highs:
        assert(compareHands(Trip, High) == 1)
        assert(compareHands(High, Trip) == -1)
for Trip in Trips:
    for Pair in Pairs:
        assert(compareHands(Trip, Pair) == 1)
        assert(compareHands(Pair, Trip) == -1)

Straight5 = [Card(1, 2), Card(0, 4), Card(1, 3), Card(1, 5),
         Card(0, 6), Card(2, 12), Card(2, 14)]
Straight8 = [Card(1, 7), Card(0, 4), Card(1, 8), Card(1, 5),
         Card(0, 6), Card(2, 12), Card(2, 14)]
StraightAce = [Card(1, 7), Card(0, 4), Card(1, 11), Card(1, 13),
         Card(0, 10), Card(2, 12), Card(2, 14)]
Straights = [Straight5, Straight8, StraightAce]

for index1 in range(0, len(Straights)):
    assert(compareHands(Straights[index1], Straights[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Straights[index1], Straights[index2]) == 1)
        assert(compareHands(Straights[index2], Straights[index1]) == -1)
for Straight in Straights:
    for High in Highs:
        assert(compareHands(Straight, High) == 1)
        assert(compareHands(High, Straight) == -1)
for Straight in Straights:
    for Pair in Pairs:
        assert(compareHands(Straight, Pair) == 1)
        assert(compareHands(Pair, Straight) == -1)
for Straight in Straights:
    for Trip in Trips:
        assert(compareHands(Straight, Trip) == 1)
        assert(compareHands(Trip, Straight) == -1)

Flush8 = [Card(0, 4), Card(0, 3), Card(1, 13), Card(1, 11),
         Card(0, 2), Card(0, 7), Card(0, 8)]
FlushAce = [Card(2, 13), Card(0, 3), Card(2, 13), Card(1, 11),
         Card(2, 13), Card(2, 14), Card(2, 8)]
Flushs = [Flush8, FlushAce]

for index1 in range(0, len(Flushs)):
    assert(compareHands(Flushs[index1], Flushs[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Flushs[index1], Flushs[index2]) == 1)
        assert(compareHands(Flushs[index2], Flushs[index1]) == -1)
for Flush in Flushs:
    for High in Highs:
        assert(compareHands(Flush, High) == 1)
        assert(compareHands(High, Flush) == -1)
for Flush in Flushs:
    for Pair in Pairs:
        assert(compareHands(Flush, Pair) == 1)
        assert(compareHands(Pair, Flush) == -1)
for Flush in Flushs:
    for Trip in Trips:
        assert(compareHands(Flush, Trip) == 1)
        assert(compareHands(Trip, Flush) == -1)
for Flush in Flushs:
    for Straight in Straights:
        assert(compareHands(Flush, Straight) == 1)
        assert(compareHands(Straight, Flush) == -1)
        
Full32 = [Card(1, 3), Card(0, 3), Card(1, 3), Card(1, 11),
         Card(0, 2), Card(2, 2), Card(2, 12)]
Full36 = [Card(1, 3), Card(0, 3), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 6), Card(2, 12)]
FullAce8 = [Card(1, 14), Card(0, 14), Card(1, 8), Card(1, 11),
         Card(0, 6), Card(2, 8), Card(2, 14)]
FullAceQueen = [Card(1, 14), Card(0, 14), Card(1, 12), Card(1, 11),
         Card(0, 6), Card(2, 12), Card(2, 14)]
Fulls = [Full32, Full36, FullAce8, FullAceQueen]

for index1 in range(0, len(Fulls)):
    assert(compareHands(Fulls[index1], Fulls[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Fulls[index1], Fulls[index2]) == 1)
        assert(compareHands(Fulls[index2], Fulls[index1]) == -1)
for Full in Fulls:
    for High in Highs:
        assert(compareHands(Full, High) == 1)
        assert(compareHands(High, Full) == -1)
for Full in Fulls:
    for Pair in Pairs:
        assert(compareHands(Full, Pair) == 1)
        assert(compareHands(Pair, Full) == -1)
for Full in Fulls:
    for Trip in Trips:
        assert(compareHands(Full, Trip) == 1)
        assert(compareHands(Trip, Full) == -1)
for Full in Fulls:
    for Straight in Straights:
        assert(compareHands(Full, Straight) == 1)
        assert(compareHands(Straight, Full) == -1)
for Full in Fulls:
    for Flush in Flushs:
        assert(compareHands(Full, Flush) == 1)
        assert(compareHands(Flush, Full) == -1)

Quads3 = [Card(1, 3), Card(0, 3), Card(1, 3), Card(1, 11),
         Card(0, 6), Card(2, 3), Card(2, 8)]
QuadsAce = [Card(1, 14), Card(0, 8), Card(1, 14), Card(1, 11),
         Card(0, 6), Card(2, 14), Card(2, 14)]
Quads = [Quads3, QuadsAce]

for index1 in range(0, len(Quads)):
    assert(compareHands(Quads[index1], Quads[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(Quads[index1], Quads[index2]) == 1)
        assert(compareHands(Quads[index2], Quads[index1]) == -1)
for Quad in Quads:
    for High in Highs:
        assert(compareHands(Quad, High) == 1)
        assert(compareHands(High, Quad) == -1)
for Quad in Quads:
    for Pair in Pairs:
        assert(compareHands(Straight, Pair) == 1)
        assert(compareHands(Pair, Straight) == -1)
for Quad in Quads:
    for Trip in Trips:
        assert(compareHands(Quad, Trip) == 1)
        assert(compareHands(Trip, Quad) == -1)
for Quad in Quads:
    for Full in Fulls:
        assert(compareHands(Quad, Full) == 1)
        assert(compareHands(Full, Quad) == -1)
for Quad in Quads:
    for Flush in Flushs:
        assert(compareHands(Quad, Flush) == 1)
        assert(compareHands(Flush, Quad) == -1)
for Quad in Quads:
    for Straight in Straights:
        assert(compareHands(Quad, Straight) == 1)
        assert(compareHands(Straight, Quad) == -1)

StraightFlush8 = [Card(1, 7), Card(1, 4), Card(1, 8), Card(1, 5),
         Card(1, 6), Card(2, 12), Card(2, 14)]
StraightFlushAce = [Card(1, 7), Card(0, 4), Card(2, 11), Card(2, 13),
         Card(2, 10), Card(2, 12), Card(2, 14)]
StraightFlushes = [StraightFlush8, StraightFlushAce]

for index1 in range(0, len(StraightFlushes)):
    assert(compareHands(StraightFlushes[index1], StraightFlushes[index1]) == 0)
    for index2 in range(0, index1):
        assert(compareHands(StraightFlushes[index1], StraightFlushes[index2]) == 1)
        assert(compareHands(StraightFlushes[index2], StraightFlushes[index1]) == -1)
for SF in StraightFlushes:
    for High in Highs:
        assert(compareHands(SF, High) == 1)
        assert(compareHands(High, SF) == -1)
for SF in StraightFlushes:
    for Pair in Pairs:
        assert(compareHands(SF, Pair) == 1)
        assert(compareHands(Pair, SF) == -1)
for SF in StraightFlushes:
    for Trip in Trips:
        assert(compareHands(SF, Trip) == 1)
        assert(compareHands(Trip, SF) == -1)
for SF in StraightFlushes:
    for Full in Fulls:
        assert(compareHands(SF, Full) == 1)
        assert(compareHands(Full, SF) == -1)
for SF in StraightFlushes:
    for Flush in Flushs:
        assert(compareHands(SF, Flush) == 1)
        assert(compareHands(Flush, SF) == -1)
for SF in StraightFlushes:
    for Straight in Straights:
        assert(compareHands(SF, Straight) == 1)
        assert(compareHands(Straight, SF) == -1)
for SF in StraightFlushes:
    for Quad in Quads:
        assert(compareHands(SF, Quad) == 1)
        assert(compareHands(Quad, SF) == -1)
