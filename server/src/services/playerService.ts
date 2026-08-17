import bcrypt from "bcrypt"
import prisma from "../config/prisma.js"
import type { RegisterPlayerInput } from "../schemas/playerSchema.js"

export const createPlayer = async (input: RegisterPlayerInput) => {
  const existingPlayer = await prisma.player.findUnique({
    where: {
      email: input.email,
    },
  })

  if (existingPlayer) {
    throw new Error("EMAIL_ALREADY_EXISTS")
  }

  const passwordHash = await bcrypt.hash(input.password, 12)

  const player = await prisma.player.create({
    data: {
      firstName: input.firstName,
      lastName: input.lastName,
      email: input.email,
      passwordHash: passwordHash,
      skillLevel: input.skillLevel,
      rating: {
        create: {},
      },
    },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      skillLevel: true,
      rating: {
        select: {
          rating: true,
          matchesRated: true,
          isProvisional: true,
        },
      },
    },
  })

  return player
}
