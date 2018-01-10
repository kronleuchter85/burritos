
from persistence import Persistence
import bookevent

def main():

	tablename = 'test_crypto1'

	d = Persistence()
	d.initialize()

	exist_table = d.existsTable(tablename)
	if not exist_table:
		d.createTable(tablename)

	records = d.getAll(tablename)

	if len(records) == 0:
		print('llamando a getAll_samples()')
		records = d.getAll_samples()
	else:
		print('llamando a getAll()')

	for r in records:
		print(r)
		bookEvent = bookevent.BookEvent.fromTuple(r)
		d.insert(tablename,bookEvent)

	print('Done')

main()
