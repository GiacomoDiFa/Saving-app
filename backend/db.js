require('dotenv').config()
const mongoose = require('mongoose')
mongoose.set('strictQuery', false)
const uri = process.env.MONGO_CONNECTION
mongoose.connect(uri, { useUnifiedTopology: true, useNewUrlParser: true })
var connection = mongoose.connection
connection.on('error', () => {
  console.log('MongoDB connection failed')
})
connection.on('connected', () => {
  console.log('MongoDB connection succesfull')
})
module.exports = mongoose
