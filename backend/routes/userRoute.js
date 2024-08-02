const express = require('express')
const router = express.Router()
const jwt = require('jsonwebtoken')
require('dotenv').config()
const bcrypt = require('bcrypt')

const secretKey = process.env.JWT_SECRET

const User = require('../model/User')
const OTP = require('../model/Otp')
const {
  checkUserExists,
  hashPassword,
  authenticateUser,
  validateLoginData,
} = require('../middleware/UserMiddleware')

const otpGenerator = require('otp-generator')
const authenticateJWT = require('../middleware/tokenmiddleware')
const Label = require('../model/Label')

function generateToken(user) {
  const payload = {
    id: user._id,
    firstname: user.firstname,
    lastname: user.lastname,
    email: user.email,
    age: user.age,
    sex: user.sex,
  }
  return jwt.sign(payload, secretKey, { expiresIn: '1h' })
}

// Route to do signup with middleware
router.post('/signup', checkUserExists, hashPassword, async (req, res) => {
  const { firstname, lastname, email, password, age, sex, otp } = req.body
  if (!firstname || !lastname || !email || !password || !age || !sex || !otp) {
    return res.status(403).send({
      success: false,
      message: 'All Fields are required',
    })
  }

  //check if use already exists?
  const existingUser = await User.findOne({ email })
  if (existingUser) {
    return res.status(400).json({
      success: false,
      message: 'User already exists',
    })
  }

  // Find the most recent OTP for the email
  const response = await OTP.find({ email }).sort({ createdAt: -1 }).limit(1)
  console.log(response)
  if (response.length === 0) {
    // OTP not found for the email
    return res.status(400).json({
      success: false,
      message: 'The OTP is not valid',
    })
  } else if (otp !== response[0].otp) {
    // Invalid OTP
    return res.status(400).json({
      success: false,
      message: 'The OTP is not valid',
    })
  }
  const user = new User({
    firstname: firstname,
    lastname: lastname,
    email: email,
    password: password,
    age: age,
    sex: sex,
  })

  await user.save()

  const label = new Label({
    userId: user._id,
    label: 'Other',
    field: 'other',
  })

  await label.save()

  const token = generateToken(user)

  // Imposta il cookie con il token
  res.cookie('token', token, {
    httpOnly: true, // Il cookie non può essere accessibile tramite JavaScript sul client
    secure: process.env.NODE_ENV === 'production', // Il cookie viene inviato solo tramite connessioni HTTPS in produzione
    sameSite: 'Strict', // Impedisce l'invio del cookie con richieste cross-site
    maxAge: 3600000, // 1 ora in millisecondi
  })

  res.json({ message: 'Registration completed successfully' })
})

router.post('/login', validateLoginData, authenticateUser, async (req, res) => {
  const { email, password } = req.body
  if (!email) {
    res.status(401).end()
    return
  }
  try {
    const user = await User.findOne({ email: email })
    if (!user) {
      return res.status(404).json('Utente non trovato')
    }
    const passwordMatch = bcrypt.compareSync(password, user.password)
    if (!passwordMatch) {
      return res.status(404).json('Password non corretta')
    }

    // Genera il token JWT
    const token = generateToken(user)

    res.cookie('token', token, {
      httpOnly: true, // Il cookie non può essere accessibile tramite JavaScript sul client
      secure: process.env.NODE_ENV === 'production', // Imposta il flag secure in produzione
      sameSite: 'strict',
      maxAge: 3600000, // 1 ora in millisecondi
    })

    res.json({ message: 'Login successfully' })
  } catch (error) {
    res.status(401).json({ message: error.message })
  }
})

router.post('/logout', async (req, res) => {
  res.clearCookie('token')
  res.status(200).json({ message: 'Logout successful, cookie cleared' })
})

router.post('/sendotp', async (req, res) => {
  try {
    const { email } = req.body

    // Check if user is already present
    // Find user with provided email
    const checkUserPresent = await User.findOne({ email })
    // to be used in case of signup

    // If user found with provided email
    if (checkUserPresent) {
      // Return 401 Unauthorized status code with error message
      return res.status(401).json({
        success: false,
        message: `User is Already Registered`,
      })
    }

    var otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    })
    const result = await OTP.findOne({ otp: otp })
    console.log('Result is Generate OTP Func')
    console.log('OTP', otp)
    console.log('Result', result)
    while (result) {
      otp = otpGenerator.generate(6, {
        upperCaseAlphabets: false,
      })
    }
    const otpPayload = { email, otp }
    const otpBody = await OTP.create(otpPayload)
    console.log('OTP Body', otpBody)
    res.status(200).json({
      success: true,
      message: `OTP Sent Successfully`,
      otp,
    })
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message })
  }
})

router.get('/getuser', authenticateJWT, async (req, res) => {
  try {
    const user = await User.findById(req.user.id) // Ottieni l'utente dal database usando l'ID dal token

    if (!user) {
      return res.status(404).json({ message: 'User not found' })
    }

    const userData = {
      firstname: user.firstname,
      lastname: user.lastname,
      email: user.email,
      age: user.age,
      sex: user.sex,
    }

    res.json(userData)
  } catch (error) {
    res.status(500).json({ message: error.message })
  }
})

module.exports = router
