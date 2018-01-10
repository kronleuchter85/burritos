
class BookEvent:

    eventDate = None
    eventTime = None

    eventType = None
    eventPrice = None
    eventSize = None

    bidPrice = None
    bidSize = None
    askPrice = None
    askSize = None


    @staticmethod
    def fromTuple(t):

        (_,eventDate,eventTime,eventType,eventPrice,
            eventSize,bidPrice,bidSize,askPrice,askSize) = t

        b = BookEvent()
        b.eventDate = eventDate
        b.eventTime = eventTime

        b.eventType = eventType
        b.eventPrice = eventPrice
        b.eventSize = eventSize

        b.bidPrice = bidPrice
        b.bidSize = bidSize
        b.askPrice = askPrice
        b.askSize = askSize

        return b


    def getTuple(self):
        return (self.eventDate,self.eventTime,self.eventType,self.eventPrice,
            self.eventSize,self.bidPrice,self.bidSize,self.askPrice,self.askSize)
