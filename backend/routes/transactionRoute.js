const express = require('express')
const router = express.Router()

const { authenticateToken } = require('../middleware/authMiddleware')

const Transaction = require('../model/Transaction')
const Label = require('../model/Label')
const User = require('../model/User')

router.get('/getall', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }
    const transactions = await Transaction.find({ userId: userId })
    res.status(200).json({ transactions })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.get(
  '/getfiltered/:labelId/:month/:year',
  authenticateToken,
  async (req, res) => {
    try {
      const userId = req.userId

      // Converti i parametri in valori null se sono stringhe 'null', altrimenti mantieni il valore
      let labelId = req.params.labelId !== 'null' ? req.params.labelId : null
      const month =
        req.params.month !== 'null' ? parseInt(req.params.month) : null
      const year = req.params.year !== 'null' ? parseInt(req.params.year) : null

      // Costruisci il filtro in base ai valori dei parametri
      const filter = { userId: userId }

      if (labelId !== null) {
        filter.labelId = labelId
      }

      if (month !== null && year !== null) {
        // Calcola la data di inizio e fine del mese
        const startDate = new Date(year, month - 1, 1) // month - 1 perché JavaScript considera i mesi da 0 a 11
        const endDate = new Date(year, month, 0) // Ultimo giorno del mese

        // Aggiungi un giorno per includere tutto il giorno finale
        endDate.setDate(endDate.getDate() + 1)

        // Aggiungi la clausola per filtrare per data
        filter.date = { $gte: startDate, $lt: endDate }
      } else if (month !== null) {
        // Se è specificato solo il mese, filtriamo per tutto il mese corrente dell'anno corrente
        const year = new Date().getFullYear()
        const startDate = new Date(year, month - 1, 1) // Mese corrente dell'anno corrente
        const endDate = new Date(year, month, 0) // Ultimo giorno del mese corrente

        // Aggiungi un giorno per includere tutto il giorno finale
        endDate.setDate(endDate.getDate() + 1)

        filter.date = { $gte: startDate, $lt: endDate }
      } else if (year !== null) {
        // Se è specificato solo l'anno, filtriamo per tutto l'anno corrispondente
        const startDate = new Date(year, 0, 1) // Inizio dell'anno specificato
        const endDate = new Date(year + 1, 0, 1) // Inizio dell'anno successivo

        filter.date = { $gte: startDate, $lt: endDate }
      }

      // Esegui la query usando il filtro costruito
      const transactions = await Transaction.find(filter)

      // Ritorna le transazioni trovate
      res.json(transactions)
    } catch (error) {
      res.status(500).json({ message: error.message })
    }
  }
)

router.post('/add', authenticateToken, async (req, res) => {
  try {
    const { label, transactionType, amount, description } = req.body
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }
    const existLabel = await Label.findOne({ userId: userId, label: label })
    if (!existLabel) {
      return res.status(404).json({ message: 'Label not found' })
    }
    const labelId = existLabel._id

    const newTransaction = new Transaction({
      userId: userId,
      labelId: labelId,
      transactionType: transactionType,
      amount: amount,
      description: description,
      date: Date.now(),
    })

    await newTransaction.save()

    res.status(200).json({ message: 'Transaction created successfully' })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/modify', authenticateToken, async (req, res) => {
  try {
    const { transactionId, label, transactionType, amount, description, date } =
      req.body
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }
    const result = await Transaction.replaceOne(
      { _id: transactionId },
      {
        _id: transactionId,
        userId: userId,
        labelId: label,
        transactionType: transactionType,
        amount: amount,
        description: description,
        date: date,
      }
    )
    if (result) {
      return res
        .status(200)
        .json({ message: 'Transaction modified succesfully' })
    } else {
      return res
        .status(404)
        .json({ message: 'Impossible to modify the transaction' })
    }
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/delete', authenticateToken, async (req, res) => {
  try {
    const { transactionId } = req.body
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }
    const result = await Transaction.findOne({
      userId: userId,
      _id: transactionId,
    })
    if (result) {
      await Transaction.deleteOne({ userId: userId, _id: transactionId })
      res.status(200).json({ message: 'Transaction deleted successfully' })
    } else {
      res.status(500).json({ error: error.message })
    }
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

module.exports = router
