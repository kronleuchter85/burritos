require 'rubygems'
require 'json'
require 'websocket-client-simple'
require 'pusher-client'

class BookSt
	attr_accessor :id, :symbol , :lines
	
	def newsnapshot (data)
		
	end
	
	def newevent (data)
		self.lines = data		
	end
	
	def asks
		lines["asks"]
	end
	
	def bids
		lines["bids"]
	end
	
	def ask
		begin
			self.asks.first.first.to_f
		rescue
			puts "askerror"
			return 100000000
		end
	end
	
	def bid
		begin
			self.bids.first.first.to_f
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
calc.lines = {"btc->xrp":"ammount / (self.tickers['btcusd'].bid * (1 + comm)) / (self.tickers['xrpbtc'].bid * (1 + comm)) * (self.tickers['xrpusd'].ask * (1 - comm))", "xrp->btc":"ammount / (self.tickers['xrpusd'].bid * (1 + comm)) * (self.tickers['xrpbtc'].ask * (1 - comm)) * (self.tickers['btcusd'].ask * (1 - comm))" }
start = false
win = false
wintime = Time.now

booksst = {}
PusherClient.logger.level = Logger::FATAL
socket = PusherClient::Socket.new("de504dc5763aeef9ff52")


socket.connect(true) # Connect asynchronously


socket.subscribe('order_book')
booksst["btcusd"] = BookSt.new
booksst["btcusd"].symbol = "btcusd"
socket['order_book'].bind('data') do |data|
	booksst["btcusd"].newevent(JSON.parse(data))
	if start
			prof = calc.btfxprofit(0.0025)
			if prof.any?{|x| x[1] > 100}
				wintime = Time.now if !win
				win = true
				
				puts Time.now.to_s + "::0.002:" + prof.select{|x| x[1] > 100}.to_s
			else
				puts ((Time.now - wintime) * 1000.0).to_s + "::0.002:WC:" + prof.to_s if win
				win = false if win
			end
		end
	
	#puts JSON.parse(data)["bids"].first.to_s + "::" + JSON.parse(data)["asks"].first.to_s
end


["xrpusd","xrpbtc"].each{|x| 
	socket.subscribe('order_book_' + x)
	booksst[x] = BookSt.new
	booksst[x].symbol = x
	socket['order_book_' + x].bind('data') do |data|
		booksst[x].newevent(JSON.parse(data))
		if start
			prof = calc.btfxprofit(0.0025)
			if prof.any?{|x| x[1] > 100}
				wintime = Time.now if !win
				win = true
				
				puts Time.now.to_s + "::0.002:" + prof.select{|x| x[1] > 100}.to_s
			else
				puts ((Time.now - wintime) * 1000.0).to_s + "::0.002:WC:" + prof.to_s if win
				win = false if win
			end
		end
		#puts JSON.parse(data)["bids"].first.to_s + "::" + JSON.parse(data)["asks"].first.to_s
	end
}
calc.tickers = booksst

#socket.bind('data') do |data|
#  puts data
#end



loop do
  input = gets
  case input
  when "chan\n"
	puts channels
  when "all\n"
	#tickers.each{|k,x| puts x.lastline.to_s}
  when "bt\n"
	booksst.each{|k,x| puts(x.symbol + ": bid:" + x.bid.to_s + " ask:" + x.ask.to_s)}
	puts calc.btfxprofit(0.002)
  when "book\n"
	puts books.to_s
  when "start\n"
	start = true

  end
end