import { Router } from "express"
import {
  loginPlayerController,
  registerPlayerController,
  getCurrentPlayerController,
  logoutPlayerController,
} from "../controllers/playerController.js"
import { protect } from "../middleware/protect.js"

const router = Router()

router.post("/register", registerPlayerController)
router.post("/login", loginPlayerController)
router.get("/me", protect, getCurrentPlayerController)
router.post("/logout", logoutPlayerController)

export default router
