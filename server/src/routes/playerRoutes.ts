import { Router } from "express"
import { loginPlayerController, registerPlayerController } from "../controllers/playerController.js"

const router = Router()

router.post("/register", registerPlayerController)
router.post("/login", loginPlayerController)

export default router
