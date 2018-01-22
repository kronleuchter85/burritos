
from back.bookservice import BookService
from domain.bookevent import BookEvent
import websocket
import json
import datetime
import time
import base64
import hashlib
from collections import OrderedDict

class DeribitBookDataFeed:

    _assetList = None
    _bookService = BookService()

    def __init__(self, assetList, key, secret):
        self.key = key
        self.secret = secret

        self._assetList = assetList
        self._bookService.initialize()

        for asset in assetList:
            self._bookService.addTable("deribit_" + asset.replace("-", "_"))

    def onMessage(self,ws, message):
        msg = json.loads(message)
        if "success" in msg:
            print (msg["message"])
        if "notifications" in msg:
            result = msg["notifications"][0]["result"]

            for bid in result["bids"]:
                print(result["instrument"] + " Bid:" + str(bid["price"]) + " Ask:" + str(result["asks"][0]["price"]))
                b = BookEvent()
                b.eventDate = datetime.datetime.now().date()
                b.eventTime = datetime.datetime.now().time()

                b.eventType = "BID"
                b.eventPrice = bid["price"]
                b.eventSize = bid["quantity"]

                b.bidPrice = bid["price"]
                b.bidSize = bid["quantity"]
                b.askPrice = result["asks"][0]["price"]
                b.askSize = result["asks"][0]["quantity"]
                self._bookService.addEvent("deribit_" + result["instrument"].replace("-", "_"), b)

            for ask in result["asks"]:
                print(result["instrument"] + " Bid:" + str(result["bids"][0]["price"]) + " Ask:" + str(ask["price"]))
                b = BookEvent()
                b.eventDate = datetime.datetime.now().date()
                b.eventTime = datetime.datetime.now().time()

                b.eventType = "ASK"
                b.eventPrice = ask["price"]
                b.eventSize = ask["quantity"]

                b.bidPrice = result["bids"][0]["price"]
                b.bidSize = result["bids"][0]["quantity"]
                b.askPrice = ask["price"]
                b.askSize = ask["quantity"]
                self._bookService.addEvent("deribit_" + result["instrument"].replace("-", "_"), b)


    def onError(self,ws, error):
        print (error)

    def onClose(self,ws):
        print ("### closed ###")

    def onOpen(self,ws):
        print ("### opened ###")
        action = "/api/v1/private/subscribe"
        for asset in self._assetList:
            arguments = {"instrument": [asset], "event": ["order_book"]}
            signature = self.generate_signature(action, arguments)
            ws.send(json.dumps({"action": action, "arguments": arguments ,"sig": signature }))

    def generate_signature(self, action, data):
        tstamp = int(time.time()* 1000)
        signature_data = {
            '_': tstamp,
            '_ackey': self.key,
            '_acsec': self.secret,
            '_action': action
        }
        signature_data.update(data)
        sorted_signature_data = OrderedDict(sorted(signature_data.items(), key=lambda t: t[0]))

        def converter(data):
            key = data[0]
            value = data[1]
            if isinstance(value, list):
                return '='.join([str(key), ''.join(value)])
            else:
                return '='.join([str(key), str(value)])

        items = map(converter, sorted_signature_data.items())

        signature_string = '&'.join(items)

        sha256 = hashlib.sha256()
        sha256.update(signature_string.encode("utf-8"))
        sig = self.key + "." + str(tstamp) + "."
        sig += base64.b64encode(sha256.digest()).decode("utf-8")
        return sig
