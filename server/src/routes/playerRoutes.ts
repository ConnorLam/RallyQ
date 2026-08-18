import { Router } from "express"
import { loginPlayerController, registerPlayer } from "../controllers/playerController.js"

const router = Router()

router.post("/register", registerPlayer)
router.post("/login", loginPlayerController)

export default router
