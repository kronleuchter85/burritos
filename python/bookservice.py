from persistence import Persistence

class BookService:

    _persistence = Persistence()

    def initialize(self):
        self._persistence.initialize()

    def addEvent(self , asset , event):
        self._persistence.insert(asset , event)

    def getAll(self, asset):
        return self._persistence.getAll(asset)

    def addTables(self, tables):
        for t in tables:
        	self.addTable(t)

    def addTable(self , table):
        exist_table = self._persistence.existsTable(t)
        if not exist_table:
            self._persistence.createTable(t)
