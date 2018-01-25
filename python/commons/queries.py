
QUERY_SELECT = "select * from @tableName limit 10"
QUERY_INSERT = "insert into @tableName" + \
	"(event_date,event_time,event_type,event_price,event_size,bid_price,bid_size,ask_price,ask_size) " + \
	"values (%s , %s , %s , %s , %s , %s , %s , %s , %s)"

QUERY_CREATE_TABLE = "Create TABLE @tableName" +\
    "(" +\
       "entry_id  BIGSERIAL PRIMARY KEY," +\
        "event_date date NOT NULL," +\
        "event_time time without time zone NOT NULL," +\
        "event_type character(10)," +\
        "event_price numeric," +\
        "event_size integer," +\
        "ask_price numeric," +\
        "ask_size integer," +\
        "bid_price numeric," +\
        "bid_size integer" +\
    ")"

QUERY_CHECK_IF_EXISTS = "select exists(select relname from pg_class where lower(relname)=lower('@tableName'))"
