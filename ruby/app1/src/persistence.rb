

require 'pg'


puts 'abriendo conexion'
conn = PG.connect( dbname: 'gtrader' , user: 'postgres' , password: 'postgres')

puts 'ejecutando query'
conn.exec( "SELECT * FROM nymex_future_gc_201712 limit 10" ) do |result|

  result.each do |row|
  
    puts row 
		#%
      #row.values_at('procpid', 'usename', 'current_query')
  end
end
