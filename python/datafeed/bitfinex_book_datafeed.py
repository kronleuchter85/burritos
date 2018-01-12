
from back.bookservice import BookService
from domain.bookevent import BookEvent
import websocket
import json
import datetime

class BitfinexBookDataFeed:

    _assetList = None
    _bookService = BookService()

    def __init__(self, assetList):
        self._assetList = assetList
        self._bookService.initialize()

        self.channels = {}
        self.bids = {}
        self.asks = {}
        self.lastbid = 0
        self.lastask = 0

        for asset in assetList:
            self._bookService.addTable("bitfinex_" + asset)



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

                if self.lastbid != self.bid(msg[0])[0]:
                    #cambió el ticker del bid
                    bid = self.bid(msg[0])
                    ask = self.ask(msg[0])
                    self.lastbid = bid[0]
                    print(self.channels[msg[0]] + " Bid:" + str(self.bid(msg[0])[0]) + " Ask:" + str(self.ask(msg[0])[0]))
                    b = BookEvent()
                    b.eventDate = datetime.datetime.now().date()
                    b.eventTime = datetime.datetime.now().time()

                    b.eventType = "BID"
                    b.eventPrice = self.lastbid
                    b.eventSize = bid[1]

                    b.bidPrice = bid[0]
                    b.bidSize = bid[1]
                    b.askPrice = ask[0]
                    b.askSize = ask[1]
                    self._bookService.addEvent("bitfinex_" + self.channels[msg[0]],b)

                if self.lastask != self.ask(msg[0])[0]:
                    #cambió el ticker del ask
                    bid = self.bid(msg[0])
                    ask = self.ask(msg[0])
                    self.lastask = ask[0]
                    print(self.channels[msg[0]] + " Bid:" + str(self.bid(msg[0])[0]) + " Ask:" + str(self.ask(msg[0])[0]))
                    b = BookEvent()
                    b.eventDate = datetime.datetime.now().date()
                    b.eventTime = datetime.datetime.now().time()

                    b.eventType = "ASK"
                    b.eventPrice = self.lastask
                    b.eventSize = ask[1]

                    b.bidPrice = bid[0]
                    b.bidSize = bid[1]
                    b.askPrice = ask[0]
                    b.askSize = ask[1]
                    self._bookService.addEvent("bitfinex_" + self.channels[msg[0]],b)
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
