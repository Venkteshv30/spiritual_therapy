-- Create Enums
CREATE TYPE "Role" AS ENUM ('USER', 'GURU', 'ADMIN', 'HELPDESK', 'GUEST');
CREATE TYPE "MembershipTier" AS ENUM ('FREE', 'SILVER', 'GOLD', 'PREMIUM');
CREATE TYPE "SessionStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED');

-- Create User table
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "email" TEXT,
    "name" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "nakshatra" TEXT,
    "dateOfBirth" TIMESTAMP(3),
    "profession" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "membershipTier" "MembershipTier" NOT NULL DEFAULT 'FREE',
    "membershipExpiry" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- Create Guru table
CREATE TABLE "Guru" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bio" TEXT,
    "specialization" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Guru_pkey" PRIMARY KEY ("id")
);

-- Create Session table
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "status" "SessionStatus" NOT NULL DEFAULT 'PENDING',
    "requestedById" TEXT NOT NULL,
    "assignedToId" TEXT,
    "scheduledAt" TIMESTAMP(3),
    "maxCapacity" INTEGER NOT NULL DEFAULT 50,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- Create Meeting table
CREATE TABLE "Meeting" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "guruId" TEXT NOT NULL,
    "agoraChannelName" TEXT NOT NULL,
    "agoraToken" TEXT,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3),
    "duration" INTEGER NOT NULL DEFAULT 60,
    "maxUsers" INTEGER NOT NULL DEFAULT 50,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Meeting_pkey" PRIMARY KEY ("id")
);

-- Create Attendance table
CREATE TABLE "Attendance" (
    "id" TEXT NOT NULL,
    "meetingId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),

    CONSTRAINT "Attendance_pkey" PRIMARY KEY ("id")
);

-- Create Unique Constraints
CREATE UNIQUE INDEX "User_phoneNumber_key" ON "User"("phoneNumber");
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "Guru_userId_key" ON "Guru"("userId");
CREATE UNIQUE INDEX "Session_sessionId_key" ON "Session"("id");
CREATE UNIQUE INDEX "Meeting_sessionId_key" ON "Meeting"("sessionId");
CREATE UNIQUE INDEX "Meeting_agoraChannelName_key" ON "Meeting"("agoraChannelName");
CREATE UNIQUE INDEX "Attendance_meetingId_userId_key" ON "Attendance"("meetingId", "userId");

-- Create Indexes
CREATE INDEX "User_phoneNumber_idx" ON "User"("phoneNumber");
CREATE INDEX "User_email_idx" ON "User"("email");
CREATE INDEX "Session_status_idx" ON "Session"("status");
CREATE INDEX "Session_requestedById_idx" ON "Session"("requestedById");
CREATE INDEX "Meeting_agoraChannelName_idx" ON "Meeting"("agoraChannelName");
CREATE INDEX "Meeting_startTime_idx" ON "Meeting"("startTime");
CREATE INDEX "Attendance_meetingId_idx" ON "Attendance"("meetingId");
CREATE INDEX "Attendance_userId_idx" ON "Attendance"("userId");

-- Create Foreign Keys
ALTER TABLE "Guru" ADD CONSTRAINT "Guru_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Session" ADD CONSTRAINT "Session_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Session" ADD CONSTRAINT "Session_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "Guru"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Meeting" ADD CONSTRAINT "Meeting_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Meeting" ADD CONSTRAINT "Meeting_guruId_fkey" FOREIGN KEY ("guruId") REFERENCES "Guru"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_meetingId_fkey" FOREIGN KEY ("meetingId") REFERENCES "Meeting"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Attendance" ADD CONSTRAINT "Attendance_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

