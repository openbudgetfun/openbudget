BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedCostBasis" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedUnrealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedUnrealizedPnlPercent" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "estimatedRealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "pnlCurrency" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "pnlAsOf" timestamp without time zone;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "priceQuality" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "priceConfidence" text;
ALTER TABLE IF EXISTS "solana_wallet_holding" ADD COLUMN IF NOT EXISTS "isPriceStale" boolean;
--
-- ACTION ALTER TABLE
--
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "interpretationConfidence" text;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedCostBasis" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedProceeds" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "estimatedRealizedPnl" double precision;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "pnlCurrency" text;
ALTER TABLE IF EXISTS "solana_wallet_transaction" ADD COLUMN IF NOT EXISTS "taxYear" bigint;

--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260302050347426', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260302050347426', "timestamp" = now();

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
