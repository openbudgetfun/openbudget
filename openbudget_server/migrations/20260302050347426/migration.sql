BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "solana_wallet_holding" ADD COLUMN "estimatedCostBasis" double precision;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "estimatedUnrealizedPnl" double precision;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "estimatedUnrealizedPnlPercent" double precision;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "estimatedRealizedPnl" double precision;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "pnlCurrency" text;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "pnlAsOf" timestamp without time zone;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "priceQuality" text;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "priceConfidence" text;
ALTER TABLE "solana_wallet_holding" ADD COLUMN "isPriceStale" boolean;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "interpretationConfidence" text;
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "estimatedCostBasis" double precision;
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "estimatedProceeds" double precision;
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "estimatedRealizedPnl" double precision;
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "pnlCurrency" text;
ALTER TABLE "solana_wallet_transaction" ADD COLUMN "taxYear" bigint;

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
