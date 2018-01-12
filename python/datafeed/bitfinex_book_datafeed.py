
from back.bookservice import BookService

import websocket
import json

class BitfinexBookDataFeed:

    _assetList = None
    _bookService = BookService()

    def __init__(self, assetList):
        self._assetList = assetList
        for asset in assetList:
            #self.initialize("bitfinex_" + asset)
            self            
        self.channels = {}
        self.bids = {}
        self.asks = {}
        self.lastbid = 0
        self.lastask = 0

    def initialize(self,asset):
        # se crea la tabla para el asset en caso de no existir
        self._bookService.initialize()
        self._bookService.addTable(asset)

    def onMessage(self,ws, message):
        
        msg = eval(message)
        if msg.__class__ == {}.__class__:
            if msg["event"] == "subscribed":
                self.channels[msg["chanId"]] = msg["pair"]
                self.bids[msg["chanId"]] = []
                self.asks[msg["chanId"]] = []
            print(msg["event"])
        if msg.__class__ == [].__class__:
            if len(msg[1]) == 3:
                if msg[1][1] == 0:
                    #sacar de la lista
                    if msg[1][2] > 0:
                        #es un bid
                        self.bids[msg[0]] = [x for x in self.bids[msg[0]] if x[0] != msg[1][0]]
                    else:
                        #es un ask
                        self.asks[msg[0]] = [x for x in self.asks[msg[0]] if x[0] != msg[1][0]]
                else:
                    if msg[1][2] > 0:
                        #es un bid
                        self.bids[msg[0]].append(msg[1])
                    else:
                        #es un ask
                        self.asks[msg[0]].append(msg[1])
                if self.lastbid != self.bid(msg[0])[0] or self.lastask != self.ask(msg[0])[0]:
                    #cambió el ticker
                    self.lastbid = self.bid(msg[0])[0]
                    self.lastask = self.ask(msg[0])[0]
                    print(self.channels[msg[0]] + " Bid:" + str(self.bid(msg[0])[0]) + " Ask:" + str(self.ask(msg[0])[0]))
            else:
                    #es un snapshot
                    self.bids[msg[0]] = [x for x in msg[1] if x[2] > 0]
                    self.asks[msg[0]] = [x for x in msg[1] if x[2] < 0]
                    self.lastbid = self.bid(msg[0])[0]
                    self.lastask = self.ask(msg[0])[0]
            
            
		
        


        # se recibe el evento que puede ser
        # _un Tick (BID o ASK del libro )
        # _un Trade

        # Paso 1:
        # en base al evento se crea un objeto BookEvent
        # event = BookEvent()
        # event.eventType = ...
        # event.eventPrice = ...

        # Paso 2:
        # se llama al servicio
        # self._bookService.addEvent(event)
        #

    def onError(self,ws, error):
        print (error)

    def onClose(self,ws):
        print ("### closed ###")

    def onOpen(self,ws):
        print ("### opened ###")
        for asset in self._assetList:
            ws.send(json.dumps({"event":"subscribe", "channel":"book", "pair":asset}))
        
    def bid(self,chan):
        return(sorted(self.bids[chan], key=lambda x: x[0], reverse=True)[0])
    def ask(self,chan):
        return(sorted(self.asks[chan], key=lambda x: x[0], reverse=False)[0])
