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
ALTER TABLE "envelope" ADD COLUMN "taxCategoryCode" text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "tax_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "jurisdiction" text NOT NULL,
    "entityKind" text NOT NULL,
    "profileJson" text NOT NULL,
    "linkedBudgetId" uuid,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "tax_profile_budget_unique_idx" ON "tax_profile" USING btree ("budgetId");
CREATE INDEX "tax_profile_linked_budget_idx" ON "tax_profile" USING btree ("linkedBudgetId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "transaction" ADD COLUMN "taxCategoryCode" text;
ALTER TABLE "transaction" ADD COLUMN "businessUsePercent" bigint;
ALTER TABLE "transaction" ADD COLUMN "salesTaxCents" bigint;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "tax_profile"
    ADD CONSTRAINT "tax_profile_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261104214126529', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261104214126529', "timestamp" = now();

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
