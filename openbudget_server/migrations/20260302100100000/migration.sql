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
-- Ensure Solana wallet tables exist for databases that advanced past
-- historical migrations during branch divergence.
--
CREATE TABLE IF NOT EXISTS "solana_wallet" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "accountId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "address" text NOT NULL,
    "label" text,
    "cluster" text NOT NULL,
    "lastSignature" text,
    "lastSyncedAt" timestamp without time zone,
    "syncStatus" text NOT NULL,
    "lastSyncError" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS "solana_wallet_account_unique" ON "solana_wallet" USING btree ("accountId");
CREATE INDEX IF NOT EXISTS "solana_wallet_budget_idx" ON "solana_wallet" USING btree ("budgetId");
CREATE INDEX IF NOT EXISTS "solana_wallet_address_idx" ON "solana_wallet" USING btree ("address");

CREATE TABLE IF NOT EXISTS "solana_wallet_holding" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text,
    "name" text,
    "tokenProgram" text,
    "decimals" bigint NOT NULL,
    "balanceRaw" text NOT NULL,
    "balanceUi" text NOT NULL,
    "isNft" boolean NOT NULL,
    "priceCurrency" text,
    "pricePerToken" double precision,
    "totalValue" double precision,
    "estimatedCostBasis" double precision,
    "estimatedUnrealizedPnl" double precision,
    "estimatedUnrealizedPnlPercent" double precision,
    "estimatedRealizedPnl" double precision,
    "pnlCurrency" text,
    "pnlAsOf" timestamp without time zone,
    "priceSource" text,
    "priceQuality" text,
    "priceConfidence" text,
    "isPriceStale" boolean,
    "priceAsOf" timestamp without time zone,
    "metadataJson" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS "solana_wallet_holding_wallet_idx" ON "solana_wallet_holding" USING btree ("walletId");
CREATE INDEX IF NOT EXISTS "solana_wallet_holding_budget_idx" ON "solana_wallet_holding" USING btree ("budgetId");
CREATE INDEX IF NOT EXISTS "solana_wallet_holding_asset_idx" ON "solana_wallet_holding" USING btree ("assetId");
CREATE UNIQUE INDEX IF NOT EXISTS "solana_wallet_holding_wallet_asset_unique" ON "solana_wallet_holding" USING btree ("walletId", "assetId");

CREATE TABLE IF NOT EXISTS "solana_wallet_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "signature" text NOT NULL,
    "slot" bigint NOT NULL,
    "occurredAt" timestamp without time zone,
    "description" text NOT NULL,
    "txType" text NOT NULL,
    "source" text NOT NULL,
    "interpretationConfidence" text,
    "programsJson" text,
    "nativeTransfersJson" text,
    "tokenTransfersJson" text,
    "estimatedCostBasis" double precision,
    "estimatedProceeds" double precision,
    "estimatedRealizedPnl" double precision,
    "pnlCurrency" text,
    "taxYear" bigint,
    "category" text,
    "tagsCsv" text,
    "memo" text,
    "rawJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS "solana_wallet_tx_wallet_idx" ON "solana_wallet_transaction" USING btree ("walletId");
CREATE INDEX IF NOT EXISTS "solana_wallet_tx_budget_idx" ON "solana_wallet_transaction" USING btree ("budgetId");
CREATE INDEX IF NOT EXISTS "solana_wallet_tx_signature_idx" ON "solana_wallet_transaction" USING btree ("signature");
CREATE UNIQUE INDEX IF NOT EXISTS "solana_wallet_tx_wallet_signature_unique" ON "solana_wallet_transaction" USING btree ("walletId", "signature");

-- Ensure additive columns exist when legacy tables are present.
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedCostBasis" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedUnrealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedUnrealizedPnlPercent" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedRealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "pnlCurrency" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "pnlAsOf" timestamp without time zone;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "priceQuality" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "priceConfidence" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "isPriceStale" boolean;

ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "interpretationConfidence" text;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedCostBasis" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedProceeds" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedRealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "pnlCurrency" text;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "taxYear" bigint;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_fk_0'
  ) THEN
    ALTER TABLE ONLY "solana_wallet"
      ADD CONSTRAINT "solana_wallet_fk_0"
      FOREIGN KEY("accountId")
      REFERENCES "account"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_fk_1'
  ) THEN
    ALTER TABLE ONLY "solana_wallet"
      ADD CONSTRAINT "solana_wallet_fk_1"
      FOREIGN KEY("budgetId")
      REFERENCES "budget"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_holding_fk_0'
  ) THEN
    ALTER TABLE ONLY "solana_wallet_holding"
      ADD CONSTRAINT "solana_wallet_holding_fk_0"
      FOREIGN KEY("walletId")
      REFERENCES "solana_wallet"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_holding_fk_1'
  ) THEN
    ALTER TABLE ONLY "solana_wallet_holding"
      ADD CONSTRAINT "solana_wallet_holding_fk_1"
      FOREIGN KEY("budgetId")
      REFERENCES "budget"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_transaction_fk_0'
  ) THEN
    ALTER TABLE ONLY "solana_wallet_transaction"
      ADD CONSTRAINT "solana_wallet_transaction_fk_0"
      FOREIGN KEY("walletId")
      REFERENCES "solana_wallet"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'solana_wallet_transaction_fk_1'
  ) THEN
    ALTER TABLE ONLY "solana_wallet_transaction"
      ADD CONSTRAINT "solana_wallet_transaction_fk_1"
      FOREIGN KEY("budgetId")
      REFERENCES "budget"("id")
      ON DELETE NO ACTION
      ON UPDATE NO ACTION;
  END IF;
END $$;

--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260302100100000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260302100100000', "timestamp" = now();

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
