import type { NextFunction, Request, Response } from "express"
import jwt from "jsonwebtoken"
import { env } from "../config/env.js"

export const protect = (req: Request, res: Response, next: NextFunction) => {
  const token = req.cookies.rallyq_token

  if (!token) {
    res.status(401).json({ message: "Token is missing" })
    return
  }

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET)
    if (
      typeof decoded !== "object" ||
      decoded === null ||
      typeof decoded.playerId !== "string" ||
      decoded.playerId.length === 0
    ) {
      res.status(401).json({ message: "Not authorized, invalid token" })
      return
    }
    req.playerId = decoded.playerId
    next()
  } catch {
    res.status(401).json({
      message: "Not authorized, token failed",
    })
  }
}
