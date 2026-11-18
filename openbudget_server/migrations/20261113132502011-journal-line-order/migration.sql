BEGIN;

--
-- ACTION ALTER TABLE
--
-- `lineNumber` is added nullable, backfilled to 0..n-1 per journal in id
-- order, then made NOT NULL with its model default: the generator's plain
-- ADD COLUMN ... NOT NULL DEFAULT 0 would leave every existing line at 0
-- and the unique index below would fail on any journal with two lines.
ALTER TABLE "journal_line" ADD COLUMN "lineNumber" bigint;
UPDATE "journal_line" AS jl
  SET "lineNumber" = numbered.line_number
  FROM (
    SELECT "id", ROW_NUMBER() OVER (PARTITION BY "journalId" ORDER BY "id") - 1 AS line_number
    FROM "journal_line"
  ) AS numbered
  WHERE jl."id" = numbered."id";
ALTER TABLE "journal_line" ALTER COLUMN "lineNumber" SET NOT NULL;
ALTER TABLE "journal_line" ALTER COLUMN "lineNumber" SET DEFAULT 0;

--
-- ACTION CREATE INDEX
--
CREATE UNIQUE INDEX "journal_line_journal_line_number_idx" ON "journal_line" USING btree ("journalId", "lineNumber");

--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261113132502011-journal-line-order', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261113132502011-journal-line-order', "timestamp" = now();

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
