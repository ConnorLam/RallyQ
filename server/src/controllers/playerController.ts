import type { Request, Response } from "express"
import { registerPlayerSchema } from "../schemas/playerSchema.js"
import { createPlayer } from "../services/playerService.js"

export const registerPlayer = async (req: Request, res: Response) => {
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

    res.status(201).json({
      success: true,
      player,
    })
  } catch (error) {
    if (error instanceof Error && error.message === "EMAIL_ALREADY_EXISTS") {
      res.status(409).json({
        success: false,
        message: "A player with that email already exists",
      })

      return
    }

    console.error("Player registration failed:", error)

    res.status(500).json({
      success: false,
      message: "Unable to register player",
    })
  }
}
