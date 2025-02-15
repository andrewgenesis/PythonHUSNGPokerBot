#!python
# cython: embedsignature=True, binding=True

import ray
import gzip
import json
from copy import deepcopy
from shutil import copyfile
from PokerUtils import PokerInfoSet, PlayerNode

class DecTree:
        
    def startAndLoad(self, stackLevel):
        self.stackLevel = stackLevel
        self.fileName = "strategy" + str(stackLevel)

        self.nodeMap = {} # Maps InfoSets to Nodes

        print ("Loading strategy.")
        try:
            self.loadStrategy()
        except:
            print ("No strategy.")

    def getCurrTree(self):
        return self.nodeMap
    
    def updateTree(self, pokerInfoSetString, playerNodeString):
        self.nodeMap[pokerInfoSetString] = playerNodeString

    def nodesCount(self):
        return len(self.nodeMap)
            
    # Save strategy as JSON file
    def saveStrategy(self):
        try:
            copyfile(self.fileName, self.fileName + ".back") # Backup file
        except:
            print ("Nothing to backup.")
            
        jsonStr = json.dumps(self.nodeMap) + "\n" # Convert to string
        jsonBytes = jsonStr.encode("utf-8") # Convert to bytes
        with gzip.GzipFile(self.fileName, "wb") as f:
            f.write(jsonBytes)
        print ("Saved!")
            
    # Load strategy from JSON file
    def loadStrategy(self):
        with gzip.GzipFile(self.fileName, "rb") as f:
            jsonBytes = f.read() # Get bytes
        jsonStr = jsonBytes.decode('utf-8') # Convert to string
        self.nodeMap = json.loads(jsonStr) # Convert to dict
        
        print ("Loaded nodes: " + str(len(self.nodeMap)))
