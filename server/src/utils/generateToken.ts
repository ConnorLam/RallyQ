import jwt, { type SignOptions } from "jsonwebtoken"
import { env } from "../config/env.js"

export const generateToken = (playerId: string): string => {
  const payload = {
    playerId,
  }

  const options: SignOptions = {
    expiresIn: `${env.AUTH_SESSION_DAYS}d` as SignOptions["expiresIn"],
  }

  return jwt.sign(payload, env.JWT_SECRET, options)
}
