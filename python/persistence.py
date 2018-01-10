from queries import QUERY_SELECT , QUERY_INSERT ,QUERY_CREATE_TABLE , QUERY_CHECK_IF_EXISTS

import psycopg2


class Persistence:

	conn_string = "host='localhost' dbname='gtrader' user='postgres' password='postgres'"
	conn = None
	cursor = None


	def initialize(self):
		self.conn = psycopg2.connect(self.conn_string)
		self.cursor = self.conn.cursor()

	def createTable(self , tablename):
		query = QUERY_CREATE_TABLE.replace('@tableName' , tablename)
		self.cursor.execute(query)
		self.conn.commit()

	def getAll(self , tablename):
		query = QUERY_SELECT.replace('@tableName' , tablename)
		self.cursor.execute(query)
		return self.cursor.fetchall()

	def insert(self , tablename , event):
		query = QUERY_INSERT.replace('@tableName' , tablename)
		self.cursor.execute(query , event.getTuple())
		self.conn.commit()

	def existsTable(self , tablename):
		query = QUERY_CHECK_IF_EXISTS.replace('@tableName' , tablename)
		self.cursor.execute(query)
		return self.cursor.fetchone()[0]

	## Sample
	def getAll_samples(self):
		self.cursor.execute("select * from nymex_future_gc_201712 limit 10")
		return self.cursor.fetchall()
