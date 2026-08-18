import type { ErrorRequestHandler } from "express"

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  console.error("Unhandled error:", err)

  res.status(500).json({
    success: false,
    message: "Internal server error",
  })
}
