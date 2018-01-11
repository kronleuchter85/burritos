
import websocket



def on_message(ws, message):
    print (message)

def on_error(ws, error):
    print (error)

def on_close(ws):
    print ("### closed ###")

#def on_open(ws):
    #def run(*args):
    #    for i in range(30000):
    #        time.sleep(1)
    #        ws.send("Hello %d" % i)
    #    time.sleep(1)
    #    ws.close()
    #    print "thread terminating..."
    #thread.start_new_thread(run, ())

def main():
    #
    ws = websocket.WebSocketApp("wss://api.bitfinex.com/ws/2",
    #ws = websocket.WebSocketApp("wss://api2.bitfinex.com:3000/ws",
        on_message = on_message,
        on_error = on_error,
        on_close = on_close)
    ws.run_forever()

main()
