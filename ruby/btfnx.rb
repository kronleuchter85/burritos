gem 'json', '=1.8.6'
require 'rubygems'
require 'json'
require 'websocket-client-simple'
require 'pusher-client'
require 'bitfinex-rb'

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
    
    def bidvol
		begin
			self.bids.first[2]
		rescue
			puts "bidvolerror"
			return 0
		end
	end
    
    def askvol
		begin
			self.asks.first[2] * -1
		rescue
			puts "askvolerror"
			return 0
		end
	end

end

class CalcLine
    attr_accessor :profitcode, :ammountcode , :tickers , :code	
    
end


class Calculator
    attr_accessor :lines, :comm , :tickers	
	
	def profit(line, ammount, comm)		
		
		eval line.profitcode
	end
	
    def tradeammount(line)
        eval line.ammountcode
    end
    
	def btfxprofit(comm)
		ret = []
		lines.each{|k| 
			ret << [k.code,self.profit(k,100,comm),self.tradeammount(k)]		
		}
		return ret
	end

end

calc = Calculator.new
l1 = CalcLine.new
l1.code = "btc->xrp"
l1.profitcode = "ammount / (self.tickers['BTCUSD'].ask * (1 + comm)) / (self.tickers['XRPBTC'].ask * (1 + comm)) * (self.tickers['XRPUSD'].bid * (1 - comm))"
l1.ammountcode = "[self.tickers['BTCUSD'].askvol * self.tickers['BTCUSD'].ask, self.tickers['BTCUSD'].ask / self.tickers['XRPBTC'].askvol * self.tickers['XRPBTC'].ask ,self.tickers['XRPUSD'].bidvol * self.tickers['XRPUSD'].bid]"
l1.tickers = ["BTCUSD","XRPBTC","XRPUSD"]

l2 = CalcLine.new
l2.code = "xrp->btc"
l2.profitcode = "ammount / (self.tickers['XRPUSD'].ask * (1 + comm)) * (self.tickers['XRPBTC'].bid * (1 - comm)) * (self.tickers['BTCUSD'].bid * (1 - comm))"
l2.ammountcode = "[self.tickers['XRPUSD'].askvol * self.tickers['XRPUSD'].ask, self.tickers['XRPUSD'].ask * self.tickers['XRPBTC'].bidvol * self.tickers['XRPBTC'].bid ,self.tickers['BTCUSD'].bidvol * self.tickers['BTCUSD'].bid]"
l2.tickers = ["BTCUSD","XRPBTC","XRPUSD"]

l3 = CalcLine.new
l3.code = "btc->eth"
l3.profitcode = "ammount / (self.tickers['BTCUSD'].ask * (1 + comm)) / (self.tickers['ETHBTC'].ask * (1 + comm)) * (self.tickers['ETHUSD'].bid * (1 - comm))"
l3.ammountcode = "[self.tickers['BTCUSD'].askvol * self.tickers['BTCUSD'].ask,self.tickers['BTCUSD'].ask / self.tickers['ETHBTC'].askvol * self.tickers['ETHBTC'].ask ,self.tickers['ETHUSD'].bidvol * self.tickers['ETHUSD'].bid]"
l3.tickers = ["BTCUSD","ETHBTC","ETHUSD"]

l4 = CalcLine.new
l4.code = "eth->btc"
l4.profitcode = "ammount / (self.tickers['ETHUSD'].ask * (1 + comm)) * (self.tickers['ETHBTC'].bid * (1 - comm)) * (self.tickers['BTCUSD'].bid * (1 - comm))"
l4.ammountcode = "[self.tickers['ETHUSD'].askvol * self.tickers['ETHUSD'].ask, self.tickers['ETHUSD'].ask * self.tickers['ETHBTC'].bidvol * self.tickers['ETHBTC'].bid ,self.tickers['BTCUSD'].bidvol * self.tickers['BTCUSD'].bid]"
l4.tickers = ["BTCUSD","ETHBTC","ETHUSD"]

l5 = CalcLine.new
l5.code = "btc->iot"
l5.profitcode = "ammount / (self.tickers['BTCUSD'].ask * (1 + comm)) / (self.tickers['IOTBTC'].ask * (1 + comm)) * (self.tickers['IOTUSD'].bid * (1 - comm))"
l5.ammountcode = "[self.tickers['BTCUSD'].askvol * self.tickers['BTCUSD'].ask, self.tickers['IOTUSD'].ask * self.tickers['IOTBTC'].askvol * self.tickers['IOTBTC'].ask ,self.tickers['IOTUSD'].bidvol * self.tickers['IOTUSD'].bid]"
l5.tickers = ["BTCUSD","IOTBTC","IOTUSD"]

l6 = CalcLine.new
l6.code = "iot->btc"
l6.profitcode = "ammount / (self.tickers['IOTUSD'].ask * (1 + comm)) * (self.tickers['IOTBTC'].bid * (1 - comm)) * (self.tickers['BTCUSD'].bid * (1 - comm))"
l6.ammountcode = "[self.tickers['IOTUSD'].askvol * self.tickers['IOTUSD'].ask, self.tickers['IOTUSD'].ask * self.tickers['IOTBTC'].bidvol * self.tickers['IOTBTC'].bid ,self.tickers['BTCUSD'].bidvol * self.tickers['BTCUSD'].bid]"
l6.tickers = ["BTCUSD","IOTBTC","IOTUSD"]





calc.lines = [l1,l2,l3,l4,l5,l6]

# calc.lines = {"btc->xrp":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['XRPBTC'].bid * (1 + comm)) * (self.tickers['XRPUSD'].ask * (1 - comm))", "xrp->btc":"ammount / (self.tickers['XRPUSD'].bid * (1 + comm)) * (self.tickers['XRPBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" }
# calc.lines.merge!({"btc->eth":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['ETHBTC'].bid * (1 + comm)) * (self.tickers['ETHUSD'].ask * (1 - comm))", "eth->btc":"ammount / (self.tickers['ETHUSD'].bid * (1 + comm)) * (self.tickers['ETHBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
# calc.lines.merge!({"btc->IOT":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['IOTBTC'].bid * (1 + comm)) * (self.tickers['IOTUSD'].ask * (1 - comm))", "IOT->btc":"ammount / (self.tickers['IOTUSD'].bid * (1 + comm)) * (self.tickers['IOTBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
# calc.lines.merge!({"btc->LTC":"ammount / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['LTCBTC'].bid * (1 + comm)) * (self.tickers['LTCUSD'].ask * (1 - comm))", "LTC->btc":"ammount / (self.tickers['LTCUSD'].bid * (1 + comm)) * (self.tickers['LTCBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm))" })
# calc.lines.merge!({"xrp->usd->btc":"ammount * (self.tickers['XRPUSD'].ask * (1 - comm)) / (self.tickers['BTCUSD'].bid * (1 + comm)) / (self.tickers['XRPBTC'].ask * (1 + comm))", "xrp->btc->usd":"ammount * (self.tickers['XRPBTC'].ask * (1 - comm)) * (self.tickers['BTCUSD'].ask * (1 - comm)) / (self.tickers['XRPUSD'].bid * (1 + comm))" })





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




# Bitfinex::Client.configure do |conf|
  # # add `secret` and `api_key` if you need to access authenticated endpoints.
  # conf.secret = "JWQuldIfX7rnbmvXjsSV25biql4L7nUaTvbscWUgbNi"
  # conf.api_key = "TdFf5yDW59N7zW2hVcUHf6EG7psULXBLSvIt7ynM6yI"

  # # uncomment if you want to use version 2 of the API
  # # which is opt-in at the moment
  # #
  # # conf.use_api_v2
# end

# client = Bitfinex::Client.new
# puts client.balances





loop do
  input = gets
  case input
  when "chan\n"
	puts channels
  when "all\n"
	#tickers.each{|k,x| puts x.lastline.to_s}
  when "bt\n"
	books.each{|k,x| puts(x.symbol + ": bid:" + x.bid.to_s + " ask:" + x.ask.to_s + "(" + x.bidvol.to_s + "|" + x.askvol.to_s + ")")}
	puts calc.btfxprofit(0.002)
  when "book\n"
	puts books.to_s
  when "start\n"
	start = true

  end
end

