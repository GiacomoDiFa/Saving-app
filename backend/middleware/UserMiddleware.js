const bcrypt = require('bcrypt')
const User = require('../model/User')

// Middleware to verify if the user already exist
const checkUserExists = async (req, res, next) => {
  const { email } = req.body
  const userExist = await User.findOne({ email: email })
  if (userExist) {
    return res.status(400).json({ message: 'User already signed up' })
  }
  next()
}

// Middleware to hash the password
const hashPassword = (req, res, next) => {
  req.body.password = bcrypt.hashSync(req.body.password, 10)
  next()
}

const validateLoginData = (req, res, next) => {
  const { email, password } = req.body
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' })
  }
  next()
}

const authenticateUser = async (req, res, next) => {
  const { email, password } = req.body
  try {
    const user = await User.findOne({ email: email })
    if (!user) {
      return res.status(404).json('User not found')
    }
    const passwordMatch = bcrypt.compareSync(password, user.password)
    if (!passwordMatch) {
      return res.status(401).json('Password wrong')
    }
    req.user = user // Passa l'utente alla prossima funzione middleware
    next()
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
}

module.exports = {
  checkUserExists,
  hashPassword,
  validateLoginData,
  authenticateUser,
}
