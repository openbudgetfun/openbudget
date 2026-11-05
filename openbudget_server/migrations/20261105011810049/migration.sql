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
CREATE TABLE "agent_conversation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "agent_conversation_budget_idx" ON "agent_conversation" USING btree ("budgetId", "updatedAt");
CREATE INDEX "agent_conversation_user_idx" ON "agent_conversation" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_message" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "conversationId" uuid NOT NULL,
    "role" text NOT NULL,
    "content" text NOT NULL,
    "toolCallsJson" text,
    "toolCallId" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "agent_message_conversation_idx" ON "agent_message" USING btree ("conversationId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_proposal" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "conversationId" uuid,
    "kind" text NOT NULL,
    "payloadJson" text NOT NULL,
    "summary" text NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "agent_proposal_budget_idx" ON "agent_proposal" USING btree ("budgetId", "status");
CREATE INDEX "agent_proposal_user_idx" ON "agent_proposal" USING btree ("userId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_provider_settings" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "baseUrl" text NOT NULL,
    "model" text NOT NULL,
    "encryptedApiKey" text NOT NULL,
    "nonce" text NOT NULL,
    "keyHint" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "agent_provider_settings_user_unique_idx" ON "agent_provider_settings" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_usage_record" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "conversationId" uuid,
    "provider" text NOT NULL,
    "model" text NOT NULL,
    "promptTokens" bigint NOT NULL,
    "cachedTokens" bigint NOT NULL,
    "completionTokens" bigint NOT NULL,
    "costMicroUsd" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "agent_usage_user_idx" ON "agent_usage_record" USING btree ("userId", "createdAt");
CREATE INDEX "agent_usage_conversation_idx" ON "agent_usage_record" USING btree ("conversationId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_conversation"
    ADD CONSTRAINT "agent_conversation_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_message"
    ADD CONSTRAINT "agent_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "agent_conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_proposal"
    ADD CONSTRAINT "agent_proposal_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261105011810049', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105011810049', "timestamp" = now();

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
