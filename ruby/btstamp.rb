require 'rubygems'
require 'json'
require 'websocket-client-simple'
require 'pusher-client'

class Book
	attr_accessor :id, :symbol , :lines
	
	def newsnapshot (data)
		#puts data[1].to_s
		self.lines = data[1]
	end
	
	def newevent (data)
		#puts data[1..3].to_s
		if data[2] == 0
			self.lines.delete_if {|x| x[0] == data[1]}
		else
			self.lines << data[1..3]
		end
		
	end
	
	def asks
		lines.select{|x| x[2] < 0 and x[1] != 0}.sort{|x,y| x[0] <=> y[0]}
	end
	
	def bids
		lines.select{|x| x[2] > 0 and x[1] != 0}.sort{|x,y| y[0] <=> x[0]}
	end
	
	def ask
		begin
			self.asks.first.first
		rescue
			puts "askerror"
			return 100000000
		end
	end
	
	def bid
		begin
			self.bids.first.first
		rescue
			puts "biderror"
			return 0
		end
	end

end

class Calculator
    attr_accessor :lines, :comm , :tickers	
	
	def profit(line, ammount, comm)		
		
		eval self.lines[line]
	end
	
	def btfxprofit(comm)
		ret = []
		lines.each{|k,x| 
			ret << [k.to_s,self.profit(k,100,comm)]		
		}
		return ret
	end

end

calc = Calculator.new
calc.lines = {"btc->xrp":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['XRPBTC'].bid * (1 + comm)) * (self.tickers['XRPUSD'].ask * (1 - comm))", "xrp->btc":"ammount / (self.tickers['XRPUSD'].bid * (1 + comm)) * (self.tickers['XRPBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" }
calc.lines.merge!({"btc->eth":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['ETHBTC'].bid * (1 + comm)) * (self.tickers['ETHUSD'].ask * (1 - comm))", "eth->btc":"ammount / (self.tickers['ETHUSD'].bid * (1 + comm)) * (self.tickers['ETHBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
calc.lines.merge!({"btc->IOT":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['IOTBTC'].bid * (1 + comm)) * (self.tickers['IOTUSD'].ask * (1 - comm))", "IOT->btc":"ammount / (self.tickers['IOTUSD'].bid * (1 + comm)) * (self.tickers['IOTBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
calc.lines.merge!({"btc->LTC":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['LTCBTC'].bid * (1 + comm)) * (self.tickers['LTCUSD'].ask * (1 - comm))", "LTC->btc":"ammount / (self.tickers['LTCUSD'].bid * (1 + comm)) * (self.tickers['LTCBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
calc.lines.merge!({"xrp->usd->btc":"ammount * (self.tickers['XRPUSD'].ask * (1 - comm)) / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['XRPBTC'].ask * (1 + comm))", "xrp->btc->usd":"ammount * (self.tickers['XRPBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm)) / (self.tickers['XRPUSD'].bid * (1 + comm))" })





ws = WebSocket::Client::Simple.connect 'wss://api.bitfinex.com/ws'

last = ""
channels = {}
books = {}
win = false
start = false
wintime = Time.now
#socket = PusherClient::Socket.new("de504dc5763aeef9ff52")
#PusherClient.logger = Logger.new(STDOUT)
#socket.connect(true) # Connect asynchronously
#socket.subscribe('order_book')

#socket.bind('globalevent') do |data|
#  puts data
#end

#socket['order_book'].bind('data') do |data|
# puts JSON.parse(data)["bids"].first.to_s + "::" + JSON.parse(data)["asks"].first.to_s
#end

ws.on :message do |msg|
  data = eval msg.to_s  
  #puts data.to_s
  if data.class.to_s == "Hash"	
	case data[:event]
	
	when "info"
	
	when "subscribed"		
		channels[data[:chanId]] = data[:pair]
		books[data[:pair]] = Book.new
		books[data[:pair]].symbol = data[:pair]
		calc.tickers = books
		puts "Subscribed: " + data[:pair]
	else
		
	end
  else if data.class.to_s == "Array"
		
	if data.length == 2 	
		puts "new snap" if data[1] != "hb"
		books[channels[data[0]]].newsnapshot data if data[1] != "hb"
		
		
	else if data.length == 4
		books[channels[data[0]]].newevent data
		if start
			prof = calc.btfxprofit(0.002)
			if prof.any?{|x| x[1] > 100}
				wintime = Time.now if !win
				win = true
				
				puts Time.now.to_s + "::0.002:" + prof.select{|x| x[1] > 100}.to_s
			else
				puts ((Time.now - wintime) * 1000.0).to_s + "::0.002:WC:" + prof.to_s if win
				win = false if win
			end
		end
	end
	end
  else
  
  end
  
end
end

ws.on :open do  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "XRPUSD"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "BTCUSD"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "XRPBTC"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "ETHUSD"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "ETHBTC"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "IOTUSD"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "IOTBTC"}
  ws.send a.to_json
 
  a = {"event" => "subscribe", "channel" => "book", "pair" => "LTCUSD"}
  ws.send a.to_json
  
  a = {"event" => "subscribe", "channel" => "book", "pair" => "LTCBTC"}
  ws.send a.to_json
  
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
  exit 1
end






loop do
  input = gets
  case input
  when "chan\n"
	puts channels
  when "all\n"
	#tickers.each{|k,x| puts x.lastline.to_s}
  when "bt\n"
	books.each{|k,x| puts(x.symbol + ": bid:" + x.bid.to_s + " ask:" + x.ask.to_s)}
	puts calc.btfxprofit(0.002)
  when "book\n"
	puts books.to_s
  when "start\n"
	start = true

  end
end
