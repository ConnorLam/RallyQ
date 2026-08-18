import jwt, { type SignOptions } from "jsonwebtoken"

export const generateToken = (playerId: string): string => {
  const secretKey = process.env.JWT_SECRET
  const expiresIn = process.env.JWT_EXPIRES_IN ?? "7d"

  if (!secretKey) {
    throw new Error("JWT_SECRET_MISSING")
  }

  const payload = {
    playerId,
  }

  const options: SignOptions = {
    expiresIn: expiresIn as SignOptions["expiresIn"],
  }

  return jwt.sign(payload, secretKey, options)
}
