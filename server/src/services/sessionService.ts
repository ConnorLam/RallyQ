import prisma from "../config/prisma.js"
import type { CreateSessionInput } from "../schemas/sessionSchema.js"
import { generateJoinCode } from "../utils/generateJoinCode.js"

const MAX_JOIN_CODE_ATTEMPTS = 5

const generateAvailableJoinCode = async (): Promise<string> => {
  for (let i = 0; i < MAX_JOIN_CODE_ATTEMPTS; i += 1) {
    const generatedCode = generateJoinCode()
    const existingCode = await prisma.openPlaySession.findUnique({
      where: {
        joinCode: generatedCode,
      },
      select: {
        id: true,
      },
    })
    if (!existingCode) {
      return generatedCode
    }
  }

  throw new Error("JOIN_CODE_GENERATION_FAILED")
}

export const createSession = async (
  createdById: string,
  input: CreateSessionInput,
) => {
  const joinCode = await generateAvailableJoinCode()

  return prisma.openPlaySession.create({
    data: {
      createdById,
      name: input.name,
      description: input.description,
      joinCode,
      startsAt: new Date(input.startsAt),
      endsAt: input.endsAt ? new Date(input.endsAt) : null,
      hosts: {
        create: {
          playerId: createdById,
          role: "OWNER",
        },
      },
      courts: {
        create: input.courts.map((court) => ({
          courtNumber: court.courtNumber,
          name: court.name,
        })),
      },
    },
    select: {
      id: true,
      createdById: true,
      name: true,
      description: true,
      joinCode: true,
      startsAt: true,
      endsAt: true,
      status: true,
      createdAt: true,
      updatedAt: true,
      hosts: {
        select: {
          id: true,
          playerId: true,
          role: true,
          assignedAt: true,
        },
      },
      courts: {
        orderBy: {
          courtNumber: "asc",
        },
        select: {
          id: true,
          courtNumber: true,
          name: true,
          status: true,
          createdAt: true,
          updatedAt: true,
        },
      },
    },
  })
}
