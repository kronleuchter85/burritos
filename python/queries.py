
QUERY_SELECT = "select * from test_cryptocurrency limit 10"
QUERY_INSERT = "insert into test_cryptocurrency" + \
	"(event_date,event_time,event_type,event_price,event_size,bid_price,bid_size,ask_price,ask_size) " + \
	"values (%s , %s , %s , %s , %s , %s , %s , %s , %s)"
