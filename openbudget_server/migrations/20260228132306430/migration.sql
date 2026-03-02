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
-- ACTION CREATE TABLE
--
CREATE TABLE "solana_wallet" (
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

-- Indexes
CREATE UNIQUE INDEX "solana_wallet_account_unique" ON "solana_wallet" USING btree ("accountId");
CREATE INDEX "solana_wallet_budget_idx" ON "solana_wallet" USING btree ("budgetId");
CREATE INDEX "solana_wallet_address_idx" ON "solana_wallet" USING btree ("address");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "solana_wallet_holding" (
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
    "priceSource" text,
    "priceAsOf" timestamp without time zone,
    "metadataJson" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "solana_wallet_holding_wallet_idx" ON "solana_wallet_holding" USING btree ("walletId");
CREATE INDEX "solana_wallet_holding_budget_idx" ON "solana_wallet_holding" USING btree ("budgetId");
CREATE INDEX "solana_wallet_holding_asset_idx" ON "solana_wallet_holding" USING btree ("assetId");
CREATE UNIQUE INDEX "solana_wallet_holding_wallet_asset_unique" ON "solana_wallet_holding" USING btree ("walletId", "assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "solana_wallet_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "signature" text NOT NULL,
    "slot" bigint NOT NULL,
    "occurredAt" timestamp without time zone,
    "description" text NOT NULL,
    "txType" text NOT NULL,
    "source" text NOT NULL,
    "programsJson" text,
    "nativeTransfersJson" text,
    "tokenTransfersJson" text,
    "category" text,
    "tagsCsv" text,
    "memo" text,
    "rawJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "solana_wallet_tx_wallet_idx" ON "solana_wallet_transaction" USING btree ("walletId");
CREATE INDEX "solana_wallet_tx_budget_idx" ON "solana_wallet_transaction" USING btree ("budgetId");
CREATE INDEX "solana_wallet_tx_signature_idx" ON "solana_wallet_transaction" USING btree ("signature");
CREATE UNIQUE INDEX "solana_wallet_tx_wallet_signature_unique" ON "solana_wallet_transaction" USING btree ("walletId", "signature");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "solana_wallet"
    ADD CONSTRAINT "solana_wallet_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet"
    ADD CONSTRAINT "solana_wallet_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "solana_wallet_holding"
    ADD CONSTRAINT "solana_wallet_holding_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "solana_wallet"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet_holding"
    ADD CONSTRAINT "solana_wallet_holding_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "solana_wallet_transaction"
    ADD CONSTRAINT "solana_wallet_transaction_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "solana_wallet"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet_transaction"
    ADD CONSTRAINT "solana_wallet_transaction_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260228132306430', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260228132306430', "timestamp" = now();

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
