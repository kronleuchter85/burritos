
from back.bookservice import BookService

import websocket


class DataFeed:

    _feedName = None
    _bookService = BookService()

    def __init__(self, name):
        self._feedName = name

    def initialize(self,asset):
        # se crea la tabla para el asset en caso de no existir
        _bookService.addTable(asset)

    def onMessage(self,ws, message):
        print (message)

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
