import type { Request, Response } from "express"
import {
  registerPlayerSchema,
  loginPlayerSchema,
} from "../schemas/playerSchema.js"
import {
  createPlayer,
  loginPlayer,
  getPlayerById,
} from "../services/playerService.js"
import { generateToken } from "../utils/generateToken.js"
import { setAuthCookie } from "../utils/setAuthCookie.js"
import { clearAuthCookie } from "../utils/clearAuthCookie.js"

export const registerPlayerController = async (req: Request, res: Response) => {
  const validationResult = registerPlayerSchema.safeParse(req.body)

  if (!validationResult.success) {
    res.status(400).json({
      success: false,
      message: "Invalid registration data",
      errors: validationResult.error.issues,
    })
    return
  }

  try {
    const player = await createPlayer(validationResult.data)
    const token = generateToken(player.id)
    setAuthCookie(res, token)

    res.status(201).json({
      success: true,
      player,
    })
  } catch (err) {
    if (err instanceof Error && err.message === "EMAIL_ALREADY_EXISTS") {
      res.status(409).json({
        success: false,
        message: "A player with that email already exists",
      })
      return
    }

    console.error("Player registration failed:", err)

    res.status(500).json({
      success: false,
      message: "Unable to register player",
    })
  }
}

export const loginPlayerController = async (req: Request, res: Response) => {
  const validationResult = loginPlayerSchema.safeParse(req.body)

  if (!validationResult.success) {
    res.status(400).json({
      success: false,
      message: "Invalid login data",
      errors: validationResult.error.issues,
    })

    return
  }

  try {
    const player = await loginPlayer(validationResult.data)
    const token = generateToken(player.id)
    setAuthCookie(res, token)

    res.status(200).json({
      success: true,
      player,
    })
  } catch (err) {
    if (err instanceof Error && err.message === "INVALID_CREDENTIALS") {
      res.status(401).json({
        success: false,
        message: "Invalid email or password",
      })
      return
    }

    console.error("Player login failed:", err)

    res.status(500).json({
      success: false,
      message: "Unable to log in",
    })
  }
}

export const getCurrentPlayerController = async (
  req: Request,
  res: Response,
) => {
  if (!req.playerId) {
    res.status(401).json({ success: false, message: "Not authenticated" })
    return
  }

  try {
    const player = await getPlayerById(req.playerId)
    if (!player) {
      res.status(404).json({
        success: false,
        message: "Player not found",
      })
      return
    }
    res.status(200).json({
      success: true,
      player,
    })
  } catch (err) {
    console.error("Get current player failed:", err)
    res.status(500).json({
      success: false,
      message: "Unable to retrieve player",
    })
  }
}

export const logoutPlayerController = (_req: Request, res: Response) => {
  clearAuthCookie(res)
  res.status(200).json({
    success: true,
    message: "Logged out successfully",
  })
}
