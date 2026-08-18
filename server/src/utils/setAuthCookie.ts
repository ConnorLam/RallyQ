import type { Response } from "express"

export const setAuthCookie = (res: Response, token: string): void => {

    res.cookie("rallyq_token", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: 7 * 24 * 60 * 60 * 1000, //7 days in milliseconds
    })

}
