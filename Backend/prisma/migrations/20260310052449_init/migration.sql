-- CreateEnum
CREATE TYPE "trip_status" AS ENUM ('OPEN', 'FULL', 'CANCELED', 'CLOSED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "participant_role" AS ENUM ('LEADER', 'MEMBER');

-- CreateEnum
CREATE TYPE "participant_status" AS ENUM ('JOINED', 'LEFT', 'KICKED');

-- CreateEnum
CREATE TYPE "receipt_status" AS ENUM ('PENDING', 'CONFIRMED');

-- CreateEnum
CREATE TYPE "settlement_status" AS ENUM ('REQUESTED', 'PAID_SELF', 'CONFIRMED', 'DISPUTED', 'OVERDUE', 'CANCELED');

-- CreateEnum
CREATE TYPE "verification_status" AS ENUM ('PENDING', 'VERIFIED', 'EXPIRED', 'FAILED');

-- CreateEnum
CREATE TYPE "report_status" AS ENUM ('OPEN', 'REVIEWED', 'ACTIONED');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "nickname" VARCHAR(20) NOT NULL,
    "profile_img_url" TEXT,
    "trust_score" DECIMAL(2,1) NOT NULL DEFAULT 4.0,
    "penalty_points" INTEGER NOT NULL DEFAULT 0,
    "is_suspended" BOOLEAN NOT NULL DEFAULT false,
    "suspended_until" TIMESTAMP(3),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "email_verifications" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "email" TEXT NOT NULL,
    "code_hash" TEXT NOT NULL,
    "status" "verification_status" NOT NULL DEFAULT 'PENDING',
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "verified_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "email_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trips" (
    "id" UUID NOT NULL,
    "creator_user_id" UUID NOT NULL,
    "leader_user_id" UUID NOT NULL,
    "depart_name" VARCHAR(80) NOT NULL,
    "depart_lat" DECIMAL(9,6) NOT NULL,
    "depart_lng" DECIMAL(9,6) NOT NULL,
    "arrive_name" VARCHAR(80) NOT NULL,
    "arrive_lat" DECIMAL(9,6) NOT NULL,
    "arrive_lng" DECIMAL(9,6) NOT NULL,
    "depart_time" TIMESTAMPTZ(6) NOT NULL,
    "capacity" INTEGER NOT NULL,
    "status" "trip_status" NOT NULL DEFAULT 'OPEN',
    "estimated_fare" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trip_participants" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "participant_role" NOT NULL DEFAULT 'MEMBER',
    "status" "participant_status" NOT NULL DEFAULT 'JOINED',
    "confirmed_departure" BOOLEAN NOT NULL DEFAULT false,
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "left_at" TIMESTAMPTZ(6),

    CONSTRAINT "trip_participants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_channels" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "kakaopay_link" TEXT,
    "updated_by" UUID NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_channels_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipts" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "uploaded_by" UUID NOT NULL,
    "image_url" TEXT NOT NULL,
    "total_amount" INTEGER NOT NULL,
    "status" "receipt_status" NOT NULL DEFAULT 'PENDING',
    "confirmed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "receipts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settlements" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "receipt_id" UUID NOT NULL,
    "payer_user_id" UUID NOT NULL,
    "payee_user_id" UUID NOT NULL,
    "share_amount" INTEGER NOT NULL,
    "memo_code" VARCHAR(20),
    "status" "settlement_status" NOT NULL DEFAULT 'REQUESTED',
    "requested_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paid_self_at" TIMESTAMPTZ(6),
    "confirmed_at" TIMESTAMPTZ(6),
    "due_at" TIMESTAMPTZ(6),

    CONSTRAINT "settlements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "settlement_proofs" (
    "id" UUID NOT NULL,
    "settlement_id" UUID NOT NULL,
    "uploaded_by" UUID NOT NULL,
    "image_url" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "settlement_proofs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_rooms" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_messages" (
    "id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "sender_user_id" UUID NOT NULL,
    "message" TEXT NOT NULL,
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" UUID NOT NULL,
    "trip_id" UUID NOT NULL,
    "from_user_id" UUID NOT NULL,
    "to_user_id" UUID NOT NULL,
    "rating" INTEGER NOT NULL,
    "tags" JSONB,
    "comment" VARCHAR(200),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "penalties" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "trip_id" UUID,
    "type" VARCHAR(30) NOT NULL,
    "points" INTEGER NOT NULL,
    "reason" VARCHAR(200),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "penalties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reports" (
    "id" UUID NOT NULL,
    "trip_id" UUID,
    "reporter_user_id" UUID NOT NULL,
    "reported_user_id" UUID NOT NULL,
    "reason" VARCHAR(50) NOT NULL,
    "detail" TEXT,
    "status" "report_status" NOT NULL DEFAULT 'OPEN',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_nickname_key" ON "users"("nickname");

-- CreateIndex
CREATE INDEX "email_verifications_email_idx" ON "email_verifications"("email");

-- CreateIndex
CREATE INDEX "trips_depart_time_idx" ON "trips"("depart_time");

-- CreateIndex
CREATE INDEX "trips_status_idx" ON "trips"("status");

-- CreateIndex
CREATE INDEX "trip_participants_user_id_idx" ON "trip_participants"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "trip_participants_trip_id_user_id_key" ON "trip_participants"("trip_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "payment_channels_trip_id_key" ON "payment_channels"("trip_id");

-- CreateIndex
CREATE UNIQUE INDEX "receipts_trip_id_key" ON "receipts"("trip_id");

-- CreateIndex
CREATE INDEX "settlements_trip_id_idx" ON "settlements"("trip_id");

-- CreateIndex
CREATE INDEX "settlements_payee_user_id_idx" ON "settlements"("payee_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "settlements_receipt_id_payer_user_id_key" ON "settlements"("receipt_id", "payer_user_id");

-- CreateIndex
CREATE INDEX "settlement_proofs_settlement_id_idx" ON "settlement_proofs"("settlement_id");

-- CreateIndex
CREATE UNIQUE INDEX "chat_rooms_trip_id_key" ON "chat_rooms"("trip_id");

-- CreateIndex
CREATE INDEX "chat_messages_room_id_sent_at_idx" ON "chat_messages"("room_id", "sent_at");

-- CreateIndex
CREATE INDEX "reviews_to_user_id_idx" ON "reviews"("to_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "reviews_trip_id_from_user_id_to_user_id_key" ON "reviews"("trip_id", "from_user_id", "to_user_id");

-- CreateIndex
CREATE INDEX "penalties_user_id_idx" ON "penalties"("user_id");

-- CreateIndex
CREATE INDEX "reports_reported_user_id_idx" ON "reports"("reported_user_id");

-- AddForeignKey
ALTER TABLE "email_verifications" ADD CONSTRAINT "email_verifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_creator_user_id_fkey" FOREIGN KEY ("creator_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trips" ADD CONSTRAINT "trips_leader_user_id_fkey" FOREIGN KEY ("leader_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_participants" ADD CONSTRAINT "trip_participants_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trip_participants" ADD CONSTRAINT "trip_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_channels" ADD CONSTRAINT "payment_channels_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_channels" ADD CONSTRAINT "payment_channels_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipts" ADD CONSTRAINT "receipts_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_receipt_id_fkey" FOREIGN KEY ("receipt_id") REFERENCES "receipts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_payer_user_id_fkey" FOREIGN KEY ("payer_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlements" ADD CONSTRAINT "settlements_payee_user_id_fkey" FOREIGN KEY ("payee_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlement_proofs" ADD CONSTRAINT "settlement_proofs_settlement_id_fkey" FOREIGN KEY ("settlement_id") REFERENCES "settlements"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "settlement_proofs" ADD CONSTRAINT "settlement_proofs_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_rooms" ADD CONSTRAINT "chat_rooms_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "chat_rooms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_sender_user_id_fkey" FOREIGN KEY ("sender_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_to_user_id_fkey" FOREIGN KEY ("to_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "penalties" ADD CONSTRAINT "penalties_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "penalties" ADD CONSTRAINT "penalties_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "trips"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reporter_user_id_fkey" FOREIGN KEY ("reporter_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
