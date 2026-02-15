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
CREATE TABLE "budget" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "currencyCode" text NOT NULL,
    "ownerId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "budget_owner_idx" ON "budget" USING btree ("ownerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "category" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "budgetId" uuid NOT NULL,
    "sortOrder" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "category_budget_idx" ON "category" USING btree ("budgetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "envelope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "categoryId" uuid NOT NULL,
    "budgetedAmountCents" bigint NOT NULL,
    "spentAmountCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "envelope_category_idx" ON "envelope" USING btree ("categoryId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "description" text NOT NULL,
    "amountCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "envelopeId" uuid,
    "budgetId" uuid NOT NULL,
    "transactionDate" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "transaction_envelope_idx" ON "transaction" USING btree ("envelopeId");
CREATE INDEX "transaction_budget_idx" ON "transaction" USING btree ("budgetId");
CREATE INDEX "transaction_date_idx" ON "transaction" USING btree ("transactionDate");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "category"
    ADD CONSTRAINT "category_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "envelope"
    ADD CONSTRAINT "envelope_fk_0"
    FOREIGN KEY("categoryId")
    REFERENCES "category"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_0"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260215141834679', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260215141834679', "timestamp" = now();

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
