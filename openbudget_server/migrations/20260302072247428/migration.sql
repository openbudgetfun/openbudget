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
ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "sourceType" text;
ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "externalAccountId" text;
ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "connectionId" uuid;
ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "lastSyncedAt" timestamp without time zone;
ALTER TABLE "account" ADD COLUMN IF NOT EXISTS "syncStatus" text;
CREATE INDEX IF NOT EXISTS "account_budget_external_idx" ON "account" USING btree ("budgetId", "externalAccountId");
--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "asset_quote_cache" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "chain" text NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text NOT NULL,
    "usdPrice" double precision NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS "asset_quote_cache_chain_asset_idx" ON "asset_quote_cache" USING btree ("chain", "assetId");
CREATE INDEX IF NOT EXISTS "asset_quote_cache_expires_idx" ON "asset_quote_cache" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "plaid_connection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "plaidItemId" text NOT NULL,
    "accessToken" text NOT NULL,
    "institutionName" text,
    "institutionId" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSyncedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS "plaid_connection_budget_item_idx" ON "plaid_connection" USING btree ("budgetId", "plaidItemId");
CREATE INDEX IF NOT EXISTS "plaid_connection_budget_idx" ON "plaid_connection" USING btree ("budgetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "wallet_connection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "chain" text NOT NULL,
    "address" text NOT NULL,
    "label" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSyncedAt" timestamp without time zone,
    "syncStatus" text,
    "lastError" text
);

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS "wallet_connection_budget_chain_address_idx" ON "wallet_connection" USING btree ("budgetId", "chain", "address");
CREATE INDEX IF NOT EXISTS "wallet_connection_budget_idx" ON "wallet_connection" USING btree ("budgetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "wallet_holding" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletConnectionId" uuid NOT NULL,
    "chain" text NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text NOT NULL,
    "decimals" bigint NOT NULL,
    "quantityBaseUnits" text NOT NULL,
    "quantityDisplay" double precision NOT NULL,
    "usdPrice" double precision,
    "usdValue" double precision,
    "lastSyncedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS "wallet_holding_connection_asset_idx" ON "wallet_holding" USING btree ("walletConnectionId", "assetId");
CREATE INDEX IF NOT EXISTS "wallet_holding_connection_idx" ON "wallet_holding" USING btree ("walletConnectionId");

--
-- ACTION CREATE FOREIGN KEY
--
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'plaid_connection_fk_0'
  ) THEN
    ALTER TABLE ONLY "plaid_connection"
        ADD CONSTRAINT "plaid_connection_fk_0"
        FOREIGN KEY("budgetId")
        REFERENCES "budget"("id")
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;
  END IF;
END $$;

--
-- ACTION CREATE FOREIGN KEY
--
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'wallet_connection_fk_0'
  ) THEN
    ALTER TABLE ONLY "wallet_connection"
        ADD CONSTRAINT "wallet_connection_fk_0"
        FOREIGN KEY("budgetId")
        REFERENCES "budget"("id")
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;
  END IF;
END $$;

--
-- ACTION CREATE FOREIGN KEY
--
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'wallet_holding_fk_0'
  ) THEN
    ALTER TABLE ONLY "wallet_holding"
        ADD CONSTRAINT "wallet_holding_fk_0"
        FOREIGN KEY("walletConnectionId")
        REFERENCES "wallet_connection"("id")
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;
  END IF;
END $$;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260302072247428', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260302072247428', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260129181124635', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181124635', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
