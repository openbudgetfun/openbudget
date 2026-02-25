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
ALTER TABLE "budget" ADD COLUMN "displayCurrencyCode" text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "fx_rate_entry" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "snapshotId" uuid NOT NULL,
    "currencyCode" text NOT NULL,
    "rate" double precision NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fx_rate_entry_snapshot_idx" ON "fx_rate_entry" USING btree ("snapshotId");
CREATE UNIQUE INDEX "fx_rate_entry_snapshot_currency_unique_idx" ON "fx_rate_entry" USING btree ("snapshotId", "currencyCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fx_rate_snapshot" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "provider" text NOT NULL,
    "baseCurrencyCode" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL,
    "isLatest" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "fx_rate_snapshot_latest_idx" ON "fx_rate_snapshot" USING btree ("provider", "baseCurrencyCode", "isLatest");
CREATE INDEX "fx_rate_snapshot_fetched_idx" ON "fx_rate_snapshot" USING btree ("provider", "baseCurrencyCode", "fetchedAt");
CREATE UNIQUE INDEX "fx_rate_snapshot_provider_base_time_unique_idx" ON "fx_rate_snapshot" USING btree ("provider", "baseCurrencyCode", "fetchedAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fx_rate_entry"
    ADD CONSTRAINT "fx_rate_entry_fk_0"
    FOREIGN KEY("snapshotId")
    REFERENCES "fx_rate_snapshot"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260225015709860', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260225015709860', "timestamp" = now();

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
