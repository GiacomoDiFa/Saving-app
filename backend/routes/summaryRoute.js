const express = require('express')
const mongoose = require('mongoose')

const router = express.Router()

const { authenticateToken } = require('../middleware/authMiddleware')
const Label = require('../model/Label')
const Transaction = require('../model/Transaction')
const User = require('../model/User')

/*La summary route è sempre a livello mensile*/
router.post('/fundamentals', authenticateToken, async (req, res) => {
  /*devo recuperare dalle transazioni del mese che passo 
    tutti quelle di cui la label, tramite la labelid ha la 
    field fundamentals e il tipo di transazione è expense*/
  try {
    const { yearMonth } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const startDate = new Date(yearMonth)
    const endDate = new Date(yearMonth)
    endDate.setMonth(endDate.getMonth() + 1)

    const fundamentalsLabels = await Label.find({
      userId: userId,
      field: 'fundamentals',
    })

    const fundamentalsLabelsIds = fundamentalsLabels.map((label) => label._id)

    if (
      !Array.isArray(fundamentalsLabelsIds) ||
      !fundamentalsLabelsIds.length
    ) {
      return res
        .status(404)
        .json({ message: 'No fundamental labels found for the user' })
    }

    const transactions = await Transaction.find({
      userId: userId,
      labelId: { $in: fundamentalsLabelsIds },
      transactionType: 'expense',
      date: {
        $gte: startDate,
        $lt: endDate,
      },
    })
    const totalAmount = transactions.reduce(
      (sum, transaction) => sum + transaction.amount,
      0
    )
    res.json(totalAmount)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/fun', authenticateToken, async (req, res) => {
  try {
    const { yearMonth } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const startDate = new Date(yearMonth)
    const endDate = new Date(yearMonth)
    endDate.setMonth(endDate.getMonth() + 1)

    const fundamentalsLabels = await Label.find({
      userId: userId,
      field: 'fun',
    })

    const fundamentalsLabelsIds = fundamentalsLabels.map((label) => label._id)

    if (
      !Array.isArray(fundamentalsLabelsIds) ||
      !fundamentalsLabelsIds.length
    ) {
      return res
        .status(404)
        .json({ message: 'No fun labels found for the user' })
    }

    const transactions = await Transaction.find({
      userId: userId,
      labelId: { $in: fundamentalsLabelsIds },
      transactionType: 'expense',
      date: {
        $gte: startDate,
        $lt: endDate,
      },
    })
    const totalAmount = transactions.reduce(
      (sum, transaction) => sum + transaction.amount,
      0
    )
    res.json(totalAmount)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/futureyou', authenticateToken, async (req, res) => {
  try {
    const { yearMonth } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const startDate = new Date(yearMonth)
    const endDate = new Date(yearMonth)
    endDate.setMonth(endDate.getMonth() + 1)

    const fundamentalsLabels = await Label.find({
      userId: userId,
      field: 'future you',
    })

    const fundamentalsLabelsIds = fundamentalsLabels.map((label) => label._id)

    if (
      !Array.isArray(fundamentalsLabelsIds) ||
      !fundamentalsLabelsIds.length
    ) {
      return res
        .status(404)
        .json({ message: 'No future you labels found for the user' })
    }

    const transactions = await Transaction.find({
      userId: userId,
      labelId: { $in: fundamentalsLabelsIds },
      transactionType: 'expense',
      date: {
        $gte: startDate,
        $lt: endDate,
      },
    })
    const totalAmount = transactions.reduce(
      (sum, transaction) => sum + transaction.amount,
      0
    )
    res.json(totalAmount)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.get('/nan', authenticateToken, async (req, res) => {
  try {
    const { yearMonth } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const startDate = new Date(yearMonth)
    const endDate = new Date(yearMonth)
    endDate.setMonth(endDate.getMonth() + 1)

    const fundamentalsLabels = await Label.find({
      userId: userId,
      field: 'nan',
    })

    const fundamentalsLabelsIds = fundamentalsLabels.map((label) => label._id)

    if (
      !Array.isArray(fundamentalsLabelsIds) ||
      !fundamentalsLabelsIds.length
    ) {
      return res
        .status(404)
        .json({ message: 'No nan labels found for the user' })
    }

    const transactions = await Transaction.find({
      userId: userId,
      labelId: { $in: fundamentalsLabelsIds },
      transactionType: 'expense',
      date: {
        $gte: startDate,
        $lt: endDate,
      },
    })
    const totalAmount = transactions.reduce(
      (sum, transaction) => sum + transaction.amount,
      0
    )
    res.json(totalAmount)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

module.exports = router
