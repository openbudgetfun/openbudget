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
ALTER TABLE "budget" ADD COLUMN "accountingMode" text NOT NULL DEFAULT 'envelope'::text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "journal" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "reference" text NOT NULL DEFAULT ''::text,
    "narration" text,
    "status" text NOT NULL DEFAULT 'draft'::text,
    "source" text NOT NULL DEFAULT 'manual'::text,
    "postedAt" timestamp without time zone,
    "postedBy" uuid,
    "reversalOfJournalId" uuid,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "journal_budget_date_idx" ON "journal" USING btree ("budgetId", "date");
CREATE INDEX "journal_budget_status_idx" ON "journal" USING btree ("budgetId", "status");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "journal_line" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "journalId" uuid NOT NULL,
    "ledgerAccountId" uuid NOT NULL,
    "description" text,
    "debitMinor" bigint NOT NULL DEFAULT 0,
    "creditMinor" bigint NOT NULL DEFAULT 0,
    "currencyCode" text NOT NULL,
    "functionalDebitMinor" bigint NOT NULL DEFAULT 0,
    "functionalCreditMinor" bigint NOT NULL DEFAULT 0,
    "exchangeRate" text NOT NULL DEFAULT '1'::text,
    "rateDate" timestamp without time zone,
    "rateSource" text,
    "taxCode" text
);

-- Indexes
CREATE INDEX "journal_line_journal_idx" ON "journal_line" USING btree ("journalId");
CREATE INDEX "journal_line_account_idx" ON "journal_line" USING btree ("ledgerAccountId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ledger_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "code" text NOT NULL,
    "name" text NOT NULL,
    "type" text NOT NULL,
    "systemRole" text,
    "currencyCode" text,
    "taxCategoryCode" text,
    "archived" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ledger_account_budget_code_unique_idx" ON "ledger_account" USING btree ("budgetId", "code");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ledger_audit_event" (
    "id" bigserial PRIMARY KEY,
    "budgetId" uuid NOT NULL,
    "actor" uuid NOT NULL,
    "action" text NOT NULL,
    "entity" text,
    "entityId" uuid,
    "payloadJson" text NOT NULL DEFAULT '{}'::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "ledger_audit_event_budget_idx" ON "ledger_audit_event" USING btree ("budgetId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ledger_period_lock" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "lockDate" timestamp without time zone NOT NULL,
    "setBy" uuid NOT NULL,
    "setAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ledger_period_lock_budget_unique_idx" ON "ledger_period_lock" USING btree ("budgetId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "journal"
    ADD CONSTRAINT "journal_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "journal_line"
    ADD CONSTRAINT "journal_line_fk_0"
    FOREIGN KEY("journalId")
    REFERENCES "journal"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "journal_line"
    ADD CONSTRAINT "journal_line_fk_1"
    FOREIGN KEY("ledgerAccountId")
    REFERENCES "ledger_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ledger_account"
    ADD CONSTRAINT "ledger_account_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ledger_audit_event"
    ADD CONSTRAINT "ledger_audit_event_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ledger_period_lock"
    ADD CONSTRAINT "ledger_period_lock_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261105230859979', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105230859979', "timestamp" = now();

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
