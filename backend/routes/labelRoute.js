const express = require('express')
const router = express.Router()

const { authenticateToken } = require('../middleware/authMiddleware')

const Label = require('../model/Label')
const User = require('../model/User')
const Transaction = require('../model/Transaction')

router.get('/getall', authenticateToken, async (req, res) => {
  try {
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }
    const labels = await Label.find({ userId: userId })
    res.status(200).json({ labels })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/add', authenticateToken, async (req, res) => {
  try {
    const { label, field } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const existLabel = await Label.find({ userId: userId, label: label })
    if (existLabel.length !== 0) {
      return res
        .status(404)
        .json({ message: 'No more label with the same name' })
    }

    const newLabel = new Label({
      userId: userId,
      label: label,
      field: field,
    })

    await newLabel.save()

    res.status(200).json({ message: 'Label created successfully', newLabel })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.post('/delete', authenticateToken, async (req, res) => {
  /*fare che se cancello una label, se è presente nelle transazioni dell'utente, allora 
  se non è già presente nelle label la label chiamata nan con field nan la crei e modifichi tutte le transazioni mettendo come labelid quella label specifica
  altrimenti se è gia presente eviti di crearla e cambi l'id solamente facendola "puntare" li*/
  try {
    const { label } = req.body
    const userId = req.userId
    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const labelToDelete = await Label.findOne({ userId: userId, label: label })

    if (!labelToDelete) {
      return res
        .status(404)
        .json({ message: 'Label not found or already deleted' })
    }

    const transactions = await Transaction.find({
      userId: userId,
      labelId: labelToDelete._id,
    })
    if (transactions.length > 0) {
      let nanLabel = await Label.findOne({ userId: userId, label: 'Other' })

      await Transaction.updateMany(
        { userId: userId, labelId: labelToDelete._id },
        { $set: { labelId: nanLabel._id } }
      )
    }
    await Label.deleteOne({ userId: userId, _id: labelToDelete._id })
    res.status(200).json({ message: 'Label deleted successfully' })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

router.put('/modify', authenticateToken, async (req, res) => {
  try {
    const { oldLabel, newLabel, newField } = req.body
    const userId = req.userId

    const user = await User.findById(userId)
    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const labelId = await Label.find({ label: oldLabel })

    const label = await Label.findOneAndUpdate(
      { _id: labelId, userId: userId },
      { label: newLabel, field: newField },
      { new: true }
    )
    if (!label) {
      return res.status(404).json({ message: 'Label not found' })
    }

    res.status(200).json({
      message: 'Label and associated transactions updated successfully',
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

module.exports = router
