/* Require */
const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const cookieParser = require('cookie-parser')
const app = express()

/* Database */
const dbConfig = require('./db')

/* Route */
const userRoute = require('./routes/userRoute')
const labelRoute = require('./routes/labelRoute')
const transactionRoute = require('./routes/transactionRoute')
const incomeRoute = require('./routes/incomeRoute')
const expenseRoute = require('./routes/expenseRoute')
const summaryRoute = require('./routes/summaryRoute')

/* App use */
app.use(
  cors({
    origin: '*',
    credentials: true, // Abilita l'invio di cookie attraverso le origini
  })
)
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(bodyParser.json())
app.use(cookieParser())

/* App use route */
app.use('/api/user', userRoute)
app.use('/api/label', labelRoute)
app.use('/api/transaction', transactionRoute)
app.use('/api/income', incomeRoute)
app.use('/api/expense', expenseRoute)
app.use('/api/summary', summaryRoute)

/* Port and App Listen */
const port = process.env.PORT || 5000
app.listen(port, () => console.log(`Server is running on port: ${port}`))
