/*
  Warnings:

  - Added the required column `ratingProcessedAt` to the `Match` table without a default value. This is not possible if the table is not empty.
  - Added the required column `actualScore` to the `RatingHistory` table without a default value. This is not possible if the table is not empty.
  - Added the required column `expectedScore` to the `RatingHistory` table without a default value. This is not possible if the table is not empty.
  - Added the required column `kFactor` to the `RatingHistory` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Match" ADD COLUMN     "ratingProcessedAt" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "winningSide" "MatchSideName";

-- AlterTable
ALTER TABLE "RatingHistory" ADD COLUMN     "actualScore" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "expectedScore" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "kFactor" INTEGER NOT NULL;

-- CreateIndex
CREATE INDEX "PlayerRating_rating_idx" ON "PlayerRating"("rating");

-- CreateIndex
CREATE INDEX "RatingHistory_playerRatingId_createdAt_idx" ON "RatingHistory"("playerRatingId", "createdAt");
