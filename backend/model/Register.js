const mongoose = require('mongoose')
const Schema = mongoose.Schema

const registerSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    transactions: [
      {
        transactionId: {
          type: Schema.Types.ObjectId,
          ref: 'Transaction',
        },
      },
    ],
  },
  {
    timestamps: true,
  }
)

module.exports = mongoose.model('Register', registerSchema)
