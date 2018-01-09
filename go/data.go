import ( "code.google.com/p/go.net/websocket")

ws, _ := websocket.Dial("wss://api.bitfinex.com/ws", "", "")
if err != nil {
    return err
}
