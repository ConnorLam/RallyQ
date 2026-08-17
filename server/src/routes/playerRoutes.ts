import { Router } from "express"
import { registerPlayer } from "../controllers/playerController.js"

const router = Router()

router.post("/register", registerPlayer)

export default router
