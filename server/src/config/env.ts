import "dotenv/config"
import { z } from "zod"

const envSchema = z.object({
  DATABASE_URL: z.string("Must be a string").min(1, "missing DATABASE_URL"),
  JWT_SECRET: z.string("Must be a string").min(1, "missing JWT_SECRET"),
  AUTH_SESSION_DAYS: z.coerce.number().int().positive().default(7),
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),
  PORT: z.coerce.number().int().positive().default(5000),
})

export const env = envSchema.parse(process.env)
