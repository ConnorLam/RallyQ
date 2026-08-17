import { z } from "zod"

export const registerPlayerSchema = z.object({
  firstName: z.string().trim().min(1, "First name is required"),
  lastName: z.string().trim().min(1, "Last name is required"),
  email: z.string().trim().toLowerCase().pipe(z.email("Invalid email address")),
  password: z.string().min(8, "Password must be at least 8 characters"),
  skillLevel: z.enum(["BEGINNER", "INTERMEDIATE", "ADVANCED", "ELITE"]),
})

// for testing
// const result = registerPlayerSchema.safeParse({
//   firstName: "",
//   lastName: " Lam ",
//   email: " CONNOR@EXAMPLE.COM ",
//   password: "password123",
//   skillLevel: "ADVANCED",
// })

// console.log(result)
// npx tsx src/schemas/playerSchema.ts

export type RegisterPlayerInput = z.infer<typeof registerPlayerSchema>
