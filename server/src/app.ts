import express from "express"
import cors from "cors"
import cookieParser from "cookie-parser"
import prisma from "./config/prisma.js"

const app = express()

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

app.get("/api/health", (_req, res) => {
  res.status(200).json({
    success: true,
    message: "RallyQ API is running",
  })
})

app.get("/api/health/database", async (_req, res) => {
  try {
    const playerCount = await prisma.player.count()

    res.status(200).json({
      success: true,
      database: "connected",
      playerCount,
    })
  } catch (error) {
    console.error("Database health check failed:", error)

    res.status(500).json({
      success: false,
      database: "disconnected",
      message: "Unable to connect to the database",
    })
  }
})

export default app
