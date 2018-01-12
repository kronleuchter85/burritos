
from datafeed.bitfinex_book_datafeed import BitfinexBookDataFeed
from back.bookservice import BookService
from domain.bookevent import BookEvent
import websocket
import datetime
import json
from decimal import *

# Se necesitan tuplas del tipo
#
# (1, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 669000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37)
# (2, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 728000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37)
# (3, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 773000), 'ASK       ', Decimal('1274.3'), 37, Decimal('1274.2'), 25, Decimal('1274.3'), 37)

def test_service():

	tablename = 'test_crypto2'
	records = [
		(1, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 669000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37),
		(2, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 728000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37),
		(3, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 773000), 'ASK       ', Decimal('1274.3'), 37, Decimal('1274.2'), 25, Decimal('1274.3'), 37)
	]

	d = BookService()
	d.initialize()
	d.addTables([tablename])


	for r in records:
		print(r)
		bookEvent = BookEvent.fromTuple(r)
		d.addEvent(tablename,bookEvent)

	print('Done')


def test_data_feed():
    datafeed = BitfinexBookDataFeed('btcusd')
    #
    ws = websocket.WebSocketApp("wss://api.bitfinex.com/ws/2",
        on_message = datafeed.onMessage,
        on_error = datafeed.onError,
        on_close = datafeed.onClose)

    ws.on_open = datafeed.onOpen
    ws.run_forever()




test_data_feed()

#test_service()
