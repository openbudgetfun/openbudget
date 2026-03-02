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
ALTER TABLE "account" ADD COLUMN "creatorId" uuid;
ALTER TABLE "account" ADD COLUMN "institutionId" uuid;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "institution" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "slug" text NOT NULL,
    "name" text NOT NULL,
    "website" text,
    "plaidInstitutionId" text,
    "isDigitalBank" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "institution_slug_idx" ON "institution" USING btree ("slug");
CREATE INDEX "institution_name_idx" ON "institution" USING btree ("name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "institution_location" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "institutionId" uuid NOT NULL,
    "locationCode" text NOT NULL,
    "isPopular" boolean NOT NULL DEFAULT false,
    "popularityRank" bigint,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "institution_location_institution_idx" ON "institution_location" USING btree ("institutionId");
CREATE INDEX "institution_location_code_idx" ON "institution_location" USING btree ("locationCode", "isPopular", "popularityRank");
CREATE UNIQUE INDEX "institution_location_unique_idx" ON "institution_location" USING btree ("institutionId", "locationCode");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_1"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "institution_location"
    ADD CONSTRAINT "institution_location_fk_0"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20260302115123146', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260302115123146', "timestamp" = now();

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
