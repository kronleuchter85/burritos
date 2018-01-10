from queries import QUERY_SELECT , QUERY_INSERT

import psycopg2


class Persistence:



	conn_string = "host='localhost' dbname='gtrader' user='postgres' password='postgres'"
	conn = None
	cursor = None



	def initialize(self):
		self.conn = psycopg2.connect(self.conn_string)
		self.cursor = self.conn.cursor()

	def getAll(self):
		self.cursor.execute(QUERY_SELECT)
		return self.cursor.fetchall()

	def insert(self , event):
		self.cursor.execute(QUERY_INSERT , event.getTuple())
		self.conn.commit()




	## Sample
	def getAll_samples(self):
		self.cursor.execute("select * from nymex_future_gc_201712 limit 10")
		return self.cursor.fetchall()
