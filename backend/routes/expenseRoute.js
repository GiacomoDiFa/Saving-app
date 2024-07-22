const express = require('express')
const mongoose = require('mongoose')

const router = express.Router()

const Transaction = require('../model/Transaction') // Importa il tuo modello Transaction

const { authenticateToken } = require('../middleware/authMiddleware')

router.get('/monthly', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId

    const result = await Transaction.aggregate([
      {
        $match: {
          transactionType: 'expense',
          userId: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $group: {
          _id: { year: { $year: '$date' }, month: { $month: '$date' } },
          totalAmount: { $sum: '$amount' },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ])
    res.json(result)
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
          transactionType: 'expense',
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
          transactionType: 'expense',
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
