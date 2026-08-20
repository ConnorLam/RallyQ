import { randomInt } from "node:crypto"

const JOIN_CODE_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const JOIN_CODE_LENGTH = 6

export const generateJoinCode = (): string => {
  let joinCode = ""

  for (let i = 0; i < JOIN_CODE_LENGTH; i++) {
    const randomIndex = randomInt(0, JOIN_CODE_CHARACTERS.length)
    joinCode += JOIN_CODE_CHARACTERS[randomIndex]
  }

  return joinCode
}
