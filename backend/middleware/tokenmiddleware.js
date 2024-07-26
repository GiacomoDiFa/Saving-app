const jwt = require('jsonwebtoken')
const secretKey = process.env.JWT_SECRET

function authenticateJWT(req, res, next) {
  const token = req.cookies.token || req.headers['authorization']?.split(' ')[1]

  if (!token) return res.status(401).json({ message: 'Access Denied' })

  jwt.verify(token, secretKey, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid Token' })

    req.user = user // Salva l'utente decodificato nella richiesta
    next()
  })
}

module.exports = authenticateJWT
