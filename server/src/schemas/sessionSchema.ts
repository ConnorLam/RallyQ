import { z } from "zod"

const courtSchema = z.object({
  courtNumber: z.number().int().positive(),
  name: z.string().trim().min(1).optional(),
})

export const createSessionSchema = z
  .object({
    name: z.string().trim().min(1, "Name is required"),
    description: z.string().trim().optional(),
    startsAt: z.iso.datetime(),
    endsAt: z.iso.datetime().optional(),
    courts: z.array(courtSchema).min(1, "At least one court is required"),
  })
  .superRefine((data, ctx) => {
    const startTime = new Date(data.startsAt).getTime()
    if (data.endsAt) {
      const endTime = new Date(data.endsAt).getTime()
      if (endTime <= startTime) {
        ctx.addIssue({
          code: "custom",
          path: ["endsAt"],
          message: "End time must be after start time",
        })
      }
    }
    const seenCourtNumbers = new Set<number>()
    data.courts.forEach((court, index) => {
      if (seenCourtNumbers.has(court.courtNumber)) {
        ctx.addIssue({
          code: "custom",
          path: ["courts", index, "courtNumber"],
          message: "Court numbers must be unique",
        })
      }
      seenCourtNumbers.add(court.courtNumber)
    })
  })

export type CreateSessionInput = z.infer<typeof createSessionSchema>
