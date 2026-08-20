import type { Request, Response } from "express"
import { createSessionSchema } from "../schemas/sessionSchema.js"
import { createSession } from "../services/sessionService.js"

export const createSessionController = async (req: Request, res: Response) => {
  const validationResult = createSessionSchema.safeParse(req.body)

  if (!validationResult.success) {
    res.status(400).json({
      success: false,
      message: "Invalid session data",
      errors: validationResult.error.issues,
    })
    return
  }

  if (!req.playerId) {
    res.status(401).json({
      success: false,
      message: "Not authenticated",
    })
    return
  }

  const session = await createSession(req.playerId, validationResult.data)

  res.status(201).json({
    success: true,
    session,
  })
}
