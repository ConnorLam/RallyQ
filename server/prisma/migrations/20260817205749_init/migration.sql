-- CreateEnum
CREATE TYPE "SkillLevel" AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ELITE');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY');

-- CreateEnum
CREATE TYPE "SessionStatus" AS ENUM ('SCHEDULED', 'ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "HostRole" AS ENUM ('OWNER', 'CO_HOST');

-- CreateEnum
CREATE TYPE "ParticipantStatus" AS ENUM ('PARTNER_LOBBY', 'QUEUED', 'CALLED', 'READY', 'PLAYING', 'RESTING', 'LEFT');

-- CreateEnum
CREATE TYPE "LobbyExitReason" AS ENUM ('PAIRED', 'RESTING', 'LEFT_SESSION', 'HOST_REMOVED', 'SESSION_ENDED');

-- CreateEnum
CREATE TYPE "PartnershipRequestSource" AS ENUM ('PLAYER_REQUEST', 'HOST_PROPOSAL', 'SYSTEM_SUGGESTION');

-- CreateEnum
CREATE TYPE "PartnershipRequestStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "PartnershipStatus" AS ENUM ('ACTIVE', 'QUEUED', 'CALLED', 'PLAYING', 'DISSOLVED');

-- CreateEnum
CREATE TYPE "PartnershipDissolutionReason" AS ENUM ('MATCH_FINISHED', 'LEFT_QUEUE', 'PLAYER_LEFT', 'HOST_DISSOLVED', 'SESSION_ENDED');

-- CreateEnum
CREATE TYPE "QueueEntryStatus" AS ENUM ('WAITING', 'CALLED', 'MATCHED', 'REMOVED');

-- CreateEnum
CREATE TYPE "CourtStatus" AS ENUM ('AVAILABLE', 'RESERVED', 'IN_USE', 'UNAVAILABLE');

-- CreateEnum
CREATE TYPE "MatchStatus" AS ENUM ('CONFIRMING', 'READY', 'PLAYING', 'SCORE_PENDING', 'AWAITING_VERIFICATION', 'COMPLETED', 'DISPUTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MatchSideName" AS ENUM ('SIDE_A', 'SIDE_B');

-- CreateEnum
CREATE TYPE "ConfirmationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "ScoreSubmissionStatus" AS ENUM ('PENDING_VERIFICATION', 'VERIFIED', 'DISPUTED', 'HOST_RESOLVED');

-- CreateEnum
CREATE TYPE "MatchCallEventType" AS ENUM ('CALLED', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'REPLACED', 'CANCELLED');

-- CreateTable
CREATE TABLE "Player" (
    "id" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "profilePictureUrl" TEXT,
    "gender" "Gender",
    "birthDate" TIMESTAMP(3),
    "skillLevel" "SkillLevel" NOT NULL,
    "playStyle" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlayerRating" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL DEFAULT 1000,
    "matchesRated" INTEGER NOT NULL DEFAULT 0,
    "isProvisional" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlayerRating_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RatingHistory" (
    "id" TEXT NOT NULL,
    "playerRatingId" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "ratingBefore" INTEGER NOT NULL,
    "ratingChange" INTEGER NOT NULL,
    "ratingAfter" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RatingHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OpenPlaySession" (
    "id" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "joinCode" TEXT NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "status" "SessionStatus" NOT NULL DEFAULT 'SCHEDULED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OpenPlaySession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SessionHost" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "role" "HostRole" NOT NULL DEFAULT 'CO_HOST',
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SessionHost_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SessionParticipant" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "status" "ParticipantStatus" NOT NULL DEFAULT 'PARTNER_LOBBY',
    "declineCount" INTEGER NOT NULL DEFAULT 0,
    "timeoutCount" INTEGER NOT NULL DEFAULT 0,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SessionParticipant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerLobbyVisit" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "sessionParticipantId" TEXT NOT NULL,
    "enteredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "exitedAt" TIMESTAMP(3),
    "exitReason" "LobbyExitReason",

    CONSTRAINT "PartnerLobbyVisit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnershipRequest" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "senderParticipantId" TEXT NOT NULL,
    "recipientParticipantId" TEXT NOT NULL,
    "proposedByParticipantId" TEXT,
    "source" "PartnershipRequestSource" NOT NULL DEFAULT 'PLAYER_REQUEST',
    "status" "PartnershipRequestStatus" NOT NULL DEFAULT 'PENDING',
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PartnershipRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Partnership" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "status" "PartnershipStatus" NOT NULL DEFAULT 'ACTIVE',
    "formedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dissolvedAt" TIMESTAMP(3),
    "dissolutionReason" "PartnershipDissolutionReason",

    CONSTRAINT "Partnership_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnershipMember" (
    "id" TEXT NOT NULL,
    "partnershipId" TEXT NOT NULL,
    "sessionParticipantId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnershipMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QueueEntry" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "partnershipId" TEXT NOT NULL,
    "status" "QueueEntryStatus" NOT NULL DEFAULT 'WAITING',
    "queuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "originalPriorityAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "calledAt" TIMESTAMP(3),
    "removedAt" TIMESTAMP(3),
    "declineCount" INTEGER NOT NULL DEFAULT 0,
    "timeoutCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QueueEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Court" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "courtNumber" INTEGER NOT NULL,
    "name" TEXT,
    "status" "CourtStatus" NOT NULL DEFAULT 'AVAILABLE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Court_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Match" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "courtId" TEXT NOT NULL,
    "status" "MatchStatus" NOT NULL DEFAULT 'CONFIRMING',
    "calledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "confirmationExpiresAt" TIMESTAMP(3) NOT NULL,
    "readyAt" TIMESTAMP(3),
    "startedAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Match_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchSide" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "partnershipId" TEXT NOT NULL,
    "side" "MatchSideName" NOT NULL,
    "confirmationStatus" "ConfirmationStatus" NOT NULL DEFAULT 'PENDING',
    "confirmedByParticipantId" TEXT,
    "confirmedAt" TIMESTAMP(3),
    "declineReason" TEXT,
    "declinedAt" TIMESTAMP(3),

    CONSTRAINT "MatchSide_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchParticipant" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "matchSideId" TEXT NOT NULL,
    "sessionParticipantId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "ratingBefore" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MatchParticipant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchGame" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "gameNumber" INTEGER NOT NULL,
    "sideAScore" INTEGER NOT NULL,
    "sideBScore" INTEGER NOT NULL,
    "winningSide" "MatchSideName" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MatchGame_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScoreSubmission" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "submittedByParticipantId" TEXT NOT NULL,
    "verifiedByParticipantId" TEXT,
    "disputedByParticipantId" TEXT,
    "resolvedByParticipantId" TEXT,
    "status" "ScoreSubmissionStatus" NOT NULL DEFAULT 'PENDING_VERIFICATION',
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "verifiedAt" TIMESTAMP(3),
    "disputedAt" TIMESTAMP(3),
    "disputeReason" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScoreSubmission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MatchCallEvent" (
    "id" TEXT NOT NULL,
    "matchId" TEXT NOT NULL,
    "partnershipId" TEXT NOT NULL,
    "eventType" "MatchCallEventType" NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MatchCallEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Player_email_key" ON "Player"("email");

-- CreateIndex
CREATE INDEX "Player_lastName_firstName_idx" ON "Player"("lastName", "firstName");

-- CreateIndex
CREATE UNIQUE INDEX "PlayerRating_playerId_key" ON "PlayerRating"("playerId");

-- CreateIndex
CREATE INDEX "RatingHistory_matchId_idx" ON "RatingHistory"("matchId");

-- CreateIndex
CREATE UNIQUE INDEX "RatingHistory_playerRatingId_matchId_key" ON "RatingHistory"("playerRatingId", "matchId");

-- CreateIndex
CREATE UNIQUE INDEX "OpenPlaySession_joinCode_key" ON "OpenPlaySession"("joinCode");

-- CreateIndex
CREATE INDEX "OpenPlaySession_createdById_idx" ON "OpenPlaySession"("createdById");

-- CreateIndex
CREATE INDEX "OpenPlaySession_status_startsAt_idx" ON "OpenPlaySession"("status", "startsAt");

-- CreateIndex
CREATE INDEX "SessionHost_playerId_idx" ON "SessionHost"("playerId");

-- CreateIndex
CREATE UNIQUE INDEX "SessionHost_sessionId_playerId_key" ON "SessionHost"("sessionId", "playerId");

-- CreateIndex
CREATE INDEX "SessionParticipant_sessionId_status_idx" ON "SessionParticipant"("sessionId", "status");

-- CreateIndex
CREATE INDEX "SessionParticipant_playerId_idx" ON "SessionParticipant"("playerId");

-- CreateIndex
CREATE UNIQUE INDEX "SessionParticipant_sessionId_playerId_key" ON "SessionParticipant"("sessionId", "playerId");

-- CreateIndex
CREATE INDEX "PartnerLobbyVisit_sessionId_enteredAt_idx" ON "PartnerLobbyVisit"("sessionId", "enteredAt");

-- CreateIndex
CREATE INDEX "PartnerLobbyVisit_sessionParticipantId_exitedAt_idx" ON "PartnerLobbyVisit"("sessionParticipantId", "exitedAt");

-- CreateIndex
CREATE INDEX "PartnershipRequest_sessionId_status_idx" ON "PartnershipRequest"("sessionId", "status");

-- CreateIndex
CREATE INDEX "PartnershipRequest_senderParticipantId_status_idx" ON "PartnershipRequest"("senderParticipantId", "status");

-- CreateIndex
CREATE INDEX "PartnershipRequest_recipientParticipantId_status_idx" ON "PartnershipRequest"("recipientParticipantId", "status");

-- CreateIndex
CREATE INDEX "Partnership_sessionId_status_idx" ON "Partnership"("sessionId", "status");

-- CreateIndex
CREATE INDEX "PartnershipMember_sessionParticipantId_idx" ON "PartnershipMember"("sessionParticipantId");

-- CreateIndex
CREATE UNIQUE INDEX "PartnershipMember_partnershipId_sessionParticipantId_key" ON "PartnershipMember"("partnershipId", "sessionParticipantId");

-- CreateIndex
CREATE UNIQUE INDEX "QueueEntry_partnershipId_key" ON "QueueEntry"("partnershipId");

-- CreateIndex
CREATE INDEX "QueueEntry_sessionId_status_originalPriorityAt_idx" ON "QueueEntry"("sessionId", "status", "originalPriorityAt");

-- CreateIndex
CREATE INDEX "Court_sessionId_status_idx" ON "Court"("sessionId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Court_sessionId_courtNumber_key" ON "Court"("sessionId", "courtNumber");

-- CreateIndex
CREATE INDEX "Match_sessionId_status_idx" ON "Match"("sessionId", "status");

-- CreateIndex
CREATE INDEX "Match_courtId_status_idx" ON "Match"("courtId", "status");

-- CreateIndex
CREATE INDEX "MatchSide_partnershipId_idx" ON "MatchSide"("partnershipId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchSide_matchId_side_key" ON "MatchSide"("matchId", "side");

-- CreateIndex
CREATE INDEX "MatchParticipant_playerId_createdAt_idx" ON "MatchParticipant"("playerId", "createdAt");

-- CreateIndex
CREATE INDEX "MatchParticipant_sessionParticipantId_idx" ON "MatchParticipant"("sessionParticipantId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchParticipant_matchId_playerId_key" ON "MatchParticipant"("matchId", "playerId");

-- CreateIndex
CREATE UNIQUE INDEX "MatchGame_matchId_gameNumber_key" ON "MatchGame"("matchId", "gameNumber");

-- CreateIndex
CREATE UNIQUE INDEX "ScoreSubmission_matchId_key" ON "ScoreSubmission"("matchId");

-- CreateIndex
CREATE INDEX "MatchCallEvent_matchId_createdAt_idx" ON "MatchCallEvent"("matchId", "createdAt");

-- CreateIndex
CREATE INDEX "MatchCallEvent_partnershipId_idx" ON "MatchCallEvent"("partnershipId");

-- AddForeignKey
ALTER TABLE "PlayerRating" ADD CONSTRAINT "PlayerRating_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RatingHistory" ADD CONSTRAINT "RatingHistory_playerRatingId_fkey" FOREIGN KEY ("playerRatingId") REFERENCES "PlayerRating"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RatingHistory" ADD CONSTRAINT "RatingHistory_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenPlaySession" ADD CONSTRAINT "OpenPlaySession_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionHost" ADD CONSTRAINT "SessionHost_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionHost" ADD CONSTRAINT "SessionHost_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionParticipant" ADD CONSTRAINT "SessionParticipant_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionParticipant" ADD CONSTRAINT "SessionParticipant_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnerLobbyVisit" ADD CONSTRAINT "PartnerLobbyVisit_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnerLobbyVisit" ADD CONSTRAINT "PartnerLobbyVisit_sessionParticipantId_fkey" FOREIGN KEY ("sessionParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipRequest" ADD CONSTRAINT "PartnershipRequest_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipRequest" ADD CONSTRAINT "PartnershipRequest_senderParticipantId_fkey" FOREIGN KEY ("senderParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipRequest" ADD CONSTRAINT "PartnershipRequest_recipientParticipantId_fkey" FOREIGN KEY ("recipientParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipRequest" ADD CONSTRAINT "PartnershipRequest_proposedByParticipantId_fkey" FOREIGN KEY ("proposedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Partnership" ADD CONSTRAINT "Partnership_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipMember" ADD CONSTRAINT "PartnershipMember_partnershipId_fkey" FOREIGN KEY ("partnershipId") REFERENCES "Partnership"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnershipMember" ADD CONSTRAINT "PartnershipMember_sessionParticipantId_fkey" FOREIGN KEY ("sessionParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QueueEntry" ADD CONSTRAINT "QueueEntry_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QueueEntry" ADD CONSTRAINT "QueueEntry_partnershipId_fkey" FOREIGN KEY ("partnershipId") REFERENCES "Partnership"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Court" ADD CONSTRAINT "Court_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Match" ADD CONSTRAINT "Match_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "OpenPlaySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Match" ADD CONSTRAINT "Match_courtId_fkey" FOREIGN KEY ("courtId") REFERENCES "Court"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchSide" ADD CONSTRAINT "MatchSide_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchSide" ADD CONSTRAINT "MatchSide_partnershipId_fkey" FOREIGN KEY ("partnershipId") REFERENCES "Partnership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchSide" ADD CONSTRAINT "MatchSide_confirmedByParticipantId_fkey" FOREIGN KEY ("confirmedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_matchSideId_fkey" FOREIGN KEY ("matchSideId") REFERENCES "MatchSide"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_sessionParticipantId_fkey" FOREIGN KEY ("sessionParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchParticipant" ADD CONSTRAINT "MatchParticipant_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchGame" ADD CONSTRAINT "MatchGame_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScoreSubmission" ADD CONSTRAINT "ScoreSubmission_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScoreSubmission" ADD CONSTRAINT "ScoreSubmission_submittedByParticipantId_fkey" FOREIGN KEY ("submittedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScoreSubmission" ADD CONSTRAINT "ScoreSubmission_verifiedByParticipantId_fkey" FOREIGN KEY ("verifiedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScoreSubmission" ADD CONSTRAINT "ScoreSubmission_disputedByParticipantId_fkey" FOREIGN KEY ("disputedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScoreSubmission" ADD CONSTRAINT "ScoreSubmission_resolvedByParticipantId_fkey" FOREIGN KEY ("resolvedByParticipantId") REFERENCES "SessionParticipant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchCallEvent" ADD CONSTRAINT "MatchCallEvent_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MatchCallEvent" ADD CONSTRAINT "MatchCallEvent_partnershipId_fkey" FOREIGN KEY ("partnershipId") REFERENCES "Partnership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
