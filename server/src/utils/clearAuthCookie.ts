import type { Response } from "express"
import { env } from "../config/env.js"

export const clearAuthCookie = (res: Response): void => {
  res.clearCookie("rallyq_token", {
    httpOnly: true,
    secure: env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
  })
}
