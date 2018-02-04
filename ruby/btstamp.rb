require 'rubygems'
require 'json'
require 'websocket-client-simple'
require 'pusher-client'

class BookSt
	attr_accessor :id, :symbol , :lines
	
	def newsnapshot(data)
		
	end
	
	def newevent(data)
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
	
	def bidvol
		begin
			self.bids.first[1].to_f
		rescue
			puts "bidvolerror"
			return 0
		end
	end
    
    def askvol
		begin
			self.asks.first[1].to_f
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
l1.profitcode = "ammount / (self.tickers['btcusd'].ask * (1 + comm)) / (self.tickers['xrpbtc'].ask * (1 + comm)) * (self.tickers['xrpusd'].bid * (1 - comm))"
l1.ammountcode = "[self.tickers['btcusd'].askvol * self.tickers['btcusd'].ask, self.tickers['btcusd'].ask / self.tickers['xrpbtc'].askvol * self.tickers['xrpbtc'].ask ,self.tickers['xrpusd'].bidvol * self.tickers['xrpusd'].bid]"
l1.tickers = ["btcusd","xrpbtc","xrpusd"]

l2 = CalcLine.new
l2.code = "xrp->btc"
l2.profitcode = "ammount / (self.tickers['xrpusd'].ask * (1 + comm)) * (self.tickers['xrpbtc'].bid * (1 - comm)) * (self.tickers['btcusd'].bid * (1 - comm))"
l2.ammountcode = "[self.tickers['xrpusd'].askvol * self.tickers['xrpusd'].ask, self.tickers['xrpusd'].ask * self.tickers['xrpbtc'].bidvol * self.tickers['xrpbtc'].bid ,self.tickers['btcusd'].bidvol * self.tickers['btcusd'].bid]"
l2.tickers = ["btcusd","xrpbtc","xrpusd"]

l3 = CalcLine.new
l3.code = "btc->eth"
l3.profitcode = "ammount / (self.tickers['btcusd'].ask * (1 + comm)) / (self.tickers['ethbtc'].ask * (1 + comm)) * (self.tickers['ethusd'].bid * (1 - comm))"
l3.ammountcode = "[self.tickers['btcusd'].askvol * self.tickers['btcusd'].ask,self.tickers['btcusd'].ask / self.tickers['ethbtc'].askvol * self.tickers['ethbtc'].ask ,self.tickers['ethusd'].bidvol * self.tickers['ethusd'].bid]"
l3.tickers = ["btcusd","ethbtc","ethusd"]

l4 = CalcLine.new
l4.code = "eth->btc"
l4.profitcode = "ammount / (self.tickers['ethusd'].ask * (1 + comm)) * (self.tickers['ethbtc'].bid * (1 - comm)) * (self.tickers['btcusd'].bid * (1 - comm))"
l4.ammountcode = "[self.tickers['ethusd'].askvol * self.tickers['ethusd'].ask, self.tickers['ethusd'].ask * self.tickers['ethbtc'].bidvol * self.tickers['ethbtc'].bid ,self.tickers['btcusd'].bidvol * self.tickers['btcusd'].bid]"
l4.tickers = ["btcusd","ethbtc","ethusd"]


calc.lines = [l1,l2,l3,l4]

win = false
wintime = Time.now
start = false
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


["xrpusd","xrpbtc","ethusd","ethbtc"].each{|x| 
	socket.subscribe('order_book_' + x)
	booksst[x] = BookSt.new
	booksst[x].symbol = x
	socket['order_book_' + x].bind('data') do |data|
		booksst[x].newevent(JSON.parse(data))
		#puts data
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
