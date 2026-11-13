BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "wallet" ADD COLUMN "scanNetworks" json;
ALTER TABLE "wallet" ADD COLUMN "descriptorCiphertext" text;
ALTER TABLE "wallet" ADD COLUMN "descriptorNonce" text;

--
-- ACTION ALTER TABLE
--
-- `network` is added nullable, backfilled from the wallet's home network,
-- then made NOT NULL: the generator's plain ADD COLUMN ... NOT NULL would
-- fail on tables that already hold rows. `position` and `spamVerdict` have
-- defaults and fill themselves.
ALTER TABLE "wallet_holding" ADD COLUMN "network" text;
UPDATE "wallet_holding" AS h SET "network" = w."network"
  FROM "wallet" AS w WHERE h."walletId" = w."id";
ALTER TABLE "wallet_holding" ALTER COLUMN "network" SET NOT NULL;
ALTER TABLE "wallet_holding" ADD COLUMN "position" text NOT NULL DEFAULT 'available'::text;
ALTER TABLE "wallet_holding" ADD COLUMN "spamVerdict" text NOT NULL DEFAULT 'clean'::text;

--
-- ACTION DROP INDEX
--
DROP INDEX "wallet_holding_wallet_asset_unique_idx";
DROP INDEX "wallet_holding_asset_idx";

--
-- ACTION CREATE INDEX
--
CREATE UNIQUE INDEX "wallet_holding_wallet_asset_unique_idx" ON "wallet_holding" USING btree ("walletId", "network", "assetId", "position");
CREATE INDEX "wallet_holding_asset_idx" ON "wallet_holding" USING btree ("network", "assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "wallet_network_state" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "network" text NOT NULL,
    "lastReadAt" timestamp without time zone,
    "lastError" text,
    "historyCursor" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "wallet_network_state_wallet_network_unique_idx" ON "wallet_network_state" USING btree ("walletId", "network");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "wallet_network_state"
    ADD CONSTRAINT "wallet_network_state_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "wallet"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION ALTER TABLE
--
-- See the wallet_holding block above: nullable add, backfill, then NOT NULL.
ALTER TABLE "wallet_transaction" ADD COLUMN "network" text;
UPDATE "wallet_transaction" AS t SET "network" = w."network"
  FROM "wallet" AS w WHERE t."walletId" = w."id";
ALTER TABLE "wallet_transaction" ALTER COLUMN "network" SET NOT NULL;

--
-- ACTION DROP INDEX
--
DROP INDEX "wallet_transaction_wallet_signature_unique_idx";

--
-- ACTION CREATE INDEX
--
CREATE UNIQUE INDEX "wallet_transaction_wallet_signature_unique_idx" ON "wallet_transaction" USING btree ("walletId", "network", "signature");


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261113100308076-multichain-wallet-schema', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113100308076-multichain-wallet-schema', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20261015164015382', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015164015382', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
