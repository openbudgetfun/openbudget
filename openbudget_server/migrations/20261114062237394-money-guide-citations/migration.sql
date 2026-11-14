BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "agent_message" ADD COLUMN "citationsJson" text;
ALTER TABLE "agent_message" ADD COLUMN "touchesTaxOrInvestment" boolean NOT NULL DEFAULT false;

--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261114062237394-money-guide-citations', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261114062237394-money-guide-citations', "timestamp" = now();

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
