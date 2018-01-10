
from decimal import *
from bookservice import BookService
import datetime
import bookevent

# Se necesitan tuplas del tipo
#
# (1, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 669000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37)
# (2, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 728000), 'BID       ', Decimal('1274.2'), 25, Decimal('1274.2'), 25, Decimal('1274.3'), 37)
# (3, datetime.date(2017, 10, 31), datetime.time(8, 11, 34, 773000), 'ASK       ', Decimal('1274.3'), 37, Decimal('1274.2'), 25, Decimal('1274.3'), 37)

def main():

	tablename = 'test_crypto1'
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
		bookEvent = bookevent.BookEvent.fromTuple(r)
		d.addEvent(tablename,bookEvent)

	print('Done')

main()
