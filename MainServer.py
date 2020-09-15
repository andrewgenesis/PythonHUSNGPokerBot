import os
import time
import tornado.web
import tornado.websocket
import tornado.ioloop
import json
import ray

from Game import Game
from Card import Card
from Agent import Agent
from DiscreteUtils import discretizeAction

# Starts websocket for communication with Chrome Extension

ray.init()

class MainHandler(tornado.websocket.WebSocketHandler):

    game = None
    usPosition = None
    stackLevel = -1

    currAgent = None
    agent0 = Agent(0)
    agent1 = Agent(1)
    agent2 = Agent(2)
    
    def open(self):
        print("Connected")

    def on_message(self, message):
        print ("Received: " + str(message))
        rec_message = json.loads(message)
        return_message = None

        needOppRaiseInfo = True

        if rec_message["type"] == "sendNewHand":
            currStackLevel = rec_message["stackLevel"]
            if currStackLevel == self.stackLevel:
                self.currAgent.resetAgent()
            else:
                if currStackLevel == 0:
                    self.currAgent = self.agent0
                elif currStackLevel == 1:
                    self.currAgent = self.agent1
                else:
                    self.currAgent = self.agent2

            self.stackLevel = currStackLevel

            self.game = Game(currStackLevel, True)

            self.usPosition = rec_message["usPosition"]
            card1 = Card(rec_message["cards"][0][0], rec_message["cards"][0][1])
            card2 = Card(rec_message["cards"][1][0], rec_message["cards"][1][1])
            if self.usPosition == 0:
                self.game.players[0].setCards(card1, card2)
                needOppRaiseInfo = False
            else:
                self.game.players[1].setCards(card1, card2)
                
        elif rec_message["type"] == "sendCommunityCards":
            if self.game == None:
                print ("Out of order error...")
                return

            allCards = rec_message["communityCards"]
            for card in allCards:
                communityCard = Card(card[0], card[1])
                self.game.communityCards.append(communityCard)

            if self.usPosition == 1:
                needOppRaiseInfo = False

        elif rec_message["type"] == "sendOppRaiseInfo":
            if self.game == None:
                print ("Out of order error...")
                return
            if rec_message["prevPot"] == 0:
                action = 0
            else:
                action = discretizeAction(rec_message["prevPot"], rec_message["oppRaise"])
            self.game.doAction(action)
            needOppRaiseInfo = False
        elif rec_message["type"] == "getFirstAction":
            if self.game == None:
                print ("Out of order error...")
                return
            needOppRaiseInfo = False

        if needOppRaiseInfo:
            return_message = { "type" : "getOppRaiseInfo" }
        else:
            time.sleep(2)
            self.game.printCurrGameState()
            action = self.currAgent.getRealtimeAction(self.game)
            return_message = { "type" : "doUsAction", "actionToDo" : action }
            if action == -1:
                action = 0 # If game continues the player did a call over fold
            self.game.doAction(action)

        print ("Returned: " + json.dumps(return_message))
        self.write_message(json.dumps(return_message))

    def on_close(self):
        print("Lost connection")

    def check_origin(self, origin):
        return True

application = tornado.web.Application([(r"/", MainHandler),])

if __name__ == "__main__":
    application.listen(1234)
    tornado.ioloop.IOLoop.instance().start()
