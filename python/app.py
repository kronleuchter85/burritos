
from dependency import Dependency

class Principal:

	def greet(self, msg):
		print(msg)


def main():
	c = Principal()
	d = Dependency()
	c.greet('hello world!!')
	d.do_something('hello world 2')
	
main()