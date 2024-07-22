const mongoose = require('mongoose')
const Schema = mongoose.Schema

const labelSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    field: {
      type: String,
      enum: ['fundamentals', 'fun', 'future you', 'nan'],
      required: true,
    },
  },
  {
    timestamps: true,
  }
)

labelSchema.index({ userId: 1, label: 1 }, { unique: true })

module.exports = mongoose.model('Label', labelSchema)
