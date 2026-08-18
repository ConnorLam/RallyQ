import type { Response } from "express"
import { env } from "../config/env.js"

export const setAuthCookie = (res: Response, token: string): void => {
  res.cookie("rallyq_token", token, {
    httpOnly: true,
    secure: env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: env.AUTH_SESSION_DAYS * 24 * 60 * 60 * 1000,
  })
}
