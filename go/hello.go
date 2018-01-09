package main

import (
  "database/sql"
  "fmt"

  _ "github.com/lib/pq"
)

const (
  host     = "localhost"
  port     = 5432
  user     = "postgres"
  password = "postgres"
  dbname   = "ds"
)



func main() {

  psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
    "password=%s dbname=%s sslmode=disable",
    host, port, user, password, dbname)

  db , _ := sql.Open("postgres", psqlInfo)
  rows, _ := db.Query("SELECT event_type,event_price,event_size FROM nymex_future_gc_201712 LIMIT 10")

  for rows.Next(){
    var event_type string
    var event_price float32
    var event_size int
    rows.Scan(&event_type, &event_price , &event_size)
    fmt.Println(event_type , " " , event_price , " " , event_size)
  }

  defer rows.Close()
  defer db.Close()

  fmt.Println("Successfully connected!")
}
