import { Router } from "express"
import { createSessionController } from "../controllers/sessionController.js"
import { protect } from "../middleware/protect.js"

const router = Router()

router.post("/", protect, createSessionController)

export default router
