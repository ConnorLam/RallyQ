import type { Response } from "express"

export const clearAuthCookie = (res: Response): void => {
  res.clearCookie("rallyq_token", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
  })
}
