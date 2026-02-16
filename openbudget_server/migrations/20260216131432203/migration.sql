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
CREATE TABLE "recurring_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "description" text NOT NULL,
    "amountCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "envelopeId" uuid,
    "budgetId" uuid NOT NULL,
    "accountId" uuid,
    "payeeId" uuid,
    "frequency" text NOT NULL,
    "nextOccurrence" timestamp without time zone NOT NULL,
    "endDate" timestamp without time zone,
    "isActive" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "recurring_transaction_budget_idx" ON "recurring_transaction" USING btree ("budgetId");
CREATE INDEX "recurring_transaction_next_idx" ON "recurring_transaction" USING btree ("nextOccurrence");
CREATE INDEX "recurring_transaction_active_idx" ON "recurring_transaction" USING btree ("budgetId", "isActive");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "transaction" ADD COLUMN "memo" text;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_0"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_2"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_3"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260216131432203', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260216131432203', "timestamp" = now();

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
