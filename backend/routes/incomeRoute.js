const express = require('express')
const mongoose = require('mongoose')

const router = express.Router()

const Transaction = require('../model/Transaction') // Importa il tuo modello Transaction

const { authenticateToken } = require('../middleware/authMiddleware')

router.post('/monthly', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId
    const { yearMonth } = req.body

    // Verifica che yearMonth sia fornito e valido
    if (!yearMonth || !/^\d{4}-\d{2}-\d{2}$/.test(yearMonth)) {
      return res
        .status(400)
        .json({ error: 'Invalid yearMonth format. Expected YYYY-MM-DD.' })
    }

    const [year, month] = yearMonth.split('-').map(Number)

    // Imposta la data di inizio e di fine del mese
    const startDate = new Date(Date.UTC(year, month - 1, 1))
    const endDate = new Date(Date.UTC(year, month, 1))

    const result = await Transaction.aggregate([
      {
        $match: {
          transactionType: 'income',
          userId: new mongoose.Types.ObjectId(userId),
          date: {
            $gte: startDate,
            $lt: endDate,
          },
        },
      },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
        },
      },
    ])

    res.json(result.length > 0 ? result[0].totalAmount : 0)
  } catch (error) {
    res.status(500).send(error.message)
  }
})

router.get('/label', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId
    const result = await Transaction.aggregate([
      {
        $match: {
          transactionType: 'income',
          userId: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $lookup: {
          from: 'labels', // Nome della collection Label
          localField: 'labelId',
          foreignField: '_id',
          as: 'labelDetails',
        },
      },
      {
        $unwind: '$labelDetails',
      },
      {
        $group: {
          _id: '$labelDetails.label', // Raggruppa per il nome della label
          totalAmount: { $sum: '$amount' },
        },
      },
      { $sort: { _id: 1 } },
      {
        $project: {
          _id: 0,
          label: '$_id',
          totalAmount: 1,
        },
      },
    ])
    res.json(result)
  } catch (error) {
    res.status(500).send(error.message)
  }
})

router.get('/yearly', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId
    const result = await Transaction.aggregate([
      {
        $match: {
          transactionType: 'income',
          userId: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $group: {
          _id: { year: { $year: '$date' } },
          totalAmount: { $sum: '$amount' },
        },
      },
      { $sort: { '_id.year': 1 } },
    ])

    res.json(result)
  } catch (error) {
    res.status(500).send(error.message)
  }
})

module.exports = router
