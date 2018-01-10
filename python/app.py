
from persistence import Persistence
import bookevent

class App:

	def greet(self, msg):
		print(msg)


def main():
	c = App()
	d = Persistence()
	d.initialize()
	#records = d.getAll_samples()
	records = d.getAll()

	if len(records) == 0:
		print('llamando a getAll_samples()')
		records = d.getAll_samples()
	else:
		print('llamando a getAll()')

	for r in records:
		print(r)
		bookEvent = bookevent.BookEvent.fromTuple(r)
		d.insert(bookEvent)
		#print(fromTuple(r))
		#d.insert(r)

	print('Done')

main()
