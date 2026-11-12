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
CREATE TABLE "account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "name" text NOT NULL,
    "kind" text NOT NULL,
    "currencyCode" text NOT NULL,
    "balanceSource" text NOT NULL,
    "balanceMinor" bigint NOT NULL DEFAULT 0,
    "onBudget" boolean NOT NULL DEFAULT false,
    "institutionId" uuid,
    "plaidConnectionId" uuid,
    "plaidAccountId" text,
    "reportedBalanceMinor" bigint,
    "reportedBalanceAt" timestamp without time zone,
    "ledgerAccountId" uuid,
    "reconciledThroughDate" timestamp without time zone,
    "note" text,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "closedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "account_entity_idx" ON "account" USING btree ("entityId", "sortOrder");
CREATE UNIQUE INDEX "account_plaid_unique_idx" ON "account" USING btree ("plaidConnectionId", "plaidAccountId");
CREATE UNIQUE INDEX "account_ledger_account_unique_idx" ON "account" USING btree ("ledgerAccountId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "account_valuation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "accountId" uuid NOT NULL,
    "valuationDate" timestamp without time zone NOT NULL,
    "valueMinor" bigint NOT NULL,
    "source" text NOT NULL,
    "note" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "account_valuation_account_date_unique_idx" ON "account_valuation" USING btree ("accountId", "valuationDate");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_access_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "name" text NOT NULL,
    "tokenHash" text NOT NULL,
    "tokenPrefix" text NOT NULL,
    "canPropose" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone,
    "revokedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "agent_access_token_hash_unique_idx" ON "agent_access_token" USING btree ("tokenHash");
CREATE INDEX "agent_access_token_user_idx" ON "agent_access_token" USING btree ("userId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "agent_conversation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "entityId" uuid NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "agent_conversation_entity_idx" ON "agent_conversation" USING btree ("entityId", "updatedAt");
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
    "entityId" uuid NOT NULL,
    "conversationId" uuid,
    "kind" text NOT NULL,
    "payloadJson" text NOT NULL,
    "summary" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "rulesVersion" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "agent_proposal_entity_status_idx" ON "agent_proposal" USING btree ("entityId", "status");
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
-- ACTION CREATE TABLE
--
CREATE TABLE "asset_price" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "network" text NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text,
    "currencyCode" text NOT NULL,
    "unitPrice" text NOT NULL,
    "source" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "asset_price_network_asset_unique_idx" ON "asset_price" USING btree ("network", "assetId");
CREATE INDEX "asset_price_expires_idx" ON "asset_price" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "audit_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "actorId" uuid NOT NULL,
    "action" text NOT NULL,
    "subjectType" text,
    "subjectId" uuid,
    "payloadJson" text NOT NULL DEFAULT '{}'::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "audit_event_entity_created_idx" ON "audit_event" USING btree ("entityId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "budget_template" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "budget_template_entity_idx" ON "budget_template" USING btree ("entityId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "budget_template_line" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "templateId" uuid NOT NULL,
    "envelopeId" uuid NOT NULL,
    "allocatedMinor" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "budget_template_line_unique_idx" ON "budget_template_line" USING btree ("templateId", "envelopeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "category" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "isHidden" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "category_entity_idx" ON "category" USING btree ("entityId", "sortOrder");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "entitlement" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "source" text NOT NULL,
    "externalId" text NOT NULL,
    "status" text NOT NULL,
    "currentPeriodStart" timestamp without time zone NOT NULL,
    "currentPeriodEnd" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "entitlement_rail_unique_idx" ON "entitlement" USING btree ("source", "externalId");
CREATE INDEX "entitlement_user_idx" ON "entitlement" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "entity" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "ownerId" uuid NOT NULL,
    "name" text NOT NULL,
    "kind" text NOT NULL,
    "countryCode" text NOT NULL,
    "baseCurrencyCode" text NOT NULL,
    "timeZone" text NOT NULL,
    "accountingMode" text NOT NULL DEFAULT 'envelope'::text,
    "fiscalYearEndMonth" bigint NOT NULL,
    "fiscalYearEndDay" bigint NOT NULL,
    "includeInNetWorth" boolean NOT NULL DEFAULT true,
    "linkedPersonalEntityId" uuid,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "archivedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "entity_owner_idx" ON "entity" USING btree ("ownerId", "sortOrder");
CREATE INDEX "entity_linked_personal_idx" ON "entity" USING btree ("linkedPersonalEntityId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "envelope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "categoryId" uuid NOT NULL,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "note" text,
    "taxCategoryCode" text,
    "defaultLedgerAccountId" uuid,
    "isHidden" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "envelope_entity_idx" ON "envelope" USING btree ("entityId");
CREATE INDEX "envelope_category_idx" ON "envelope" USING btree ("categoryId", "sortOrder");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "envelope_goal" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "envelopeId" uuid NOT NULL,
    "kind" text NOT NULL,
    "amountMinor" bigint NOT NULL,
    "targetDate" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "envelope_goal_envelope_unique_idx" ON "envelope_goal" USING btree ("envelopeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fx_rate" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "rateDate" timestamp without time zone NOT NULL,
    "currencyCode" text NOT NULL,
    "rate" text NOT NULL,
    "provider" text NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "fx_rate_currency_date_unique_idx" ON "fx_rate" USING btree ("currencyCode", "rateDate");
CREATE INDEX "fx_rate_date_idx" ON "fx_rate" USING btree ("rateDate");

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
-- ACTION CREATE TABLE
--
CREATE TABLE "journal" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "reference" text NOT NULL DEFAULT ''::text,
    "narration" text,
    "status" text NOT NULL DEFAULT 'draft'::text,
    "source" text NOT NULL DEFAULT 'manual'::text,
    "sourceTransactionId" uuid,
    "sourceRevision" bigint,
    "postedAt" timestamp without time zone,
    "postedBy" uuid,
    "reversalOfJournalId" uuid,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "journal_entity_date_idx" ON "journal" USING btree ("entityId", "date");
CREATE INDEX "journal_entity_status_idx" ON "journal" USING btree ("entityId", "status");
CREATE UNIQUE INDEX "journal_source_transaction_unique_idx" ON "journal" USING btree ("sourceTransactionId", "sourceRevision");
CREATE INDEX "journal_reversal_of_idx" ON "journal" USING btree ("reversalOfJournalId");

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
    "baseDebitMinor" bigint NOT NULL DEFAULT 0,
    "baseCreditMinor" bigint NOT NULL DEFAULT 0,
    "fxRate" text NOT NULL DEFAULT '1'::text,
    "fxRateDate" timestamp without time zone NOT NULL,
    "fxRateSource" text NOT NULL DEFAULT 'identity'::text,
    "taxCode" text
);

-- Indexes
CREATE INDEX "journal_line_journal_idx" ON "journal_line" USING btree ("journalId");
CREATE INDEX "journal_line_ledger_account_idx" ON "journal_line" USING btree ("ledgerAccountId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ledger_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "code" text NOT NULL,
    "name" text NOT NULL,
    "type" text NOT NULL,
    "systemRole" text,
    "currencyCode" text,
    "taxCategoryCode" text,
    "archivedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ledger_account_entity_code_unique_idx" ON "ledger_account" USING btree ("entityId", "code");
CREATE UNIQUE INDEX "ledger_account_entity_role_unique_idx" ON "ledger_account" USING btree ("entityId", "systemRole");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ledger_period_lock" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "lockDate" timestamp without time zone NOT NULL,
    "setBy" uuid NOT NULL,
    "setAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "ledger_period_lock_entity_unique_idx" ON "ledger_period_lock" USING btree ("entityId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "monthly_allocation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "envelopeId" uuid NOT NULL,
    "month" bigint NOT NULL,
    "allocatedMinor" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "monthly_allocation_envelope_month_unique_idx" ON "monthly_allocation" USING btree ("envelopeId", "month");
CREATE INDEX "monthly_allocation_entity_month_idx" ON "monthly_allocation" USING btree ("entityId", "month");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "payee" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "payee_entity_name_unique_idx" ON "payee" USING btree ("entityId", "name");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "plaid_connection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "plaidItemId" text NOT NULL,
    "accessTokenCiphertext" text,
    "accessTokenNonce" text,
    "plaidInstitutionId" text,
    "institutionName" text,
    "transactionsCursor" text,
    "syncStatus" text NOT NULL DEFAULT 'pending'::text,
    "lastSyncedAt" timestamp without time zone,
    "lastSyncError" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "plaid_connection_item_unique_idx" ON "plaid_connection" USING btree ("plaidItemId");
CREATE INDEX "plaid_connection_entity_idx" ON "plaid_connection" USING btree ("entityId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "recurring_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "accountId" uuid NOT NULL,
    "payeeId" uuid,
    "envelopeId" uuid,
    "description" text NOT NULL,
    "memo" text,
    "amountMinor" bigint NOT NULL,
    "frequency" text NOT NULL,
    "nextDate" timestamp without time zone NOT NULL,
    "endDate" timestamp without time zone,
    "isActive" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "recurring_transaction_entity_idx" ON "recurring_transaction" USING btree ("entityId", "isActive");
CREATE INDEX "recurring_transaction_due_idx" ON "recurring_transaction" USING btree ("isActive", "nextDate");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "solana_billing_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "message" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "usedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "solana_billing_challenge_user_idx" ON "solana_billing_challenge" USING btree ("userId");
CREATE UNIQUE INDEX "solana_billing_challenge_message_idx" ON "solana_billing_challenge" USING btree ("message");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "stripe_customer" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "customerId" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "stripe_customer_user_idx" ON "stripe_customer" USING btree ("userId");
CREATE UNIQUE INDEX "stripe_customer_customer_idx" ON "stripe_customer" USING btree ("customerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "tax_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "profileJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "tax_profile_entity_unique_idx" ON "tax_profile" USING btree ("entityId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "accountId" uuid NOT NULL,
    "date" timestamp without time zone NOT NULL,
    "amountMinor" bigint NOT NULL,
    "baseAmountMinor" bigint NOT NULL,
    "fxRate" text NOT NULL DEFAULT '1'::text,
    "fxRateDate" timestamp without time zone NOT NULL,
    "fxRateSource" text NOT NULL DEFAULT 'identity'::text,
    "kind" text NOT NULL DEFAULT 'standard'::text,
    "status" text NOT NULL DEFAULT 'uncleared'::text,
    "flag" text,
    "payeeId" uuid,
    "description" text NOT NULL DEFAULT ''::text,
    "memo" text,
    "externalId" text,
    "recurringTransactionId" uuid,
    "revision" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "transaction_entity_date_idx" ON "transaction" USING btree ("entityId", "date");
CREATE INDEX "transaction_account_date_idx" ON "transaction" USING btree ("accountId", "date");
CREATE INDEX "transaction_payee_idx" ON "transaction" USING btree ("payeeId");
CREATE INDEX "transaction_recurring_idx" ON "transaction" USING btree ("recurringTransactionId");
CREATE UNIQUE INDEX "transaction_account_external_unique_idx" ON "transaction" USING btree ("accountId", "externalId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_line" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "transactionId" uuid NOT NULL,
    "amountMinor" bigint NOT NULL,
    "baseAmountMinor" bigint NOT NULL,
    "envelopeId" uuid,
    "ledgerAccountId" uuid,
    "taxCategoryCode" text,
    "businessUsePercent" bigint,
    "salesTaxMinor" bigint,
    "memo" text,
    "sortOrder" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX "transaction_line_transaction_idx" ON "transaction_line" USING btree ("transactionId");
CREATE INDEX "transaction_line_envelope_idx" ON "transaction_line" USING btree ("envelopeId");
CREATE INDEX "transaction_line_ledger_account_idx" ON "transaction_line" USING btree ("ledgerAccountId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transaction_rule" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "payeeId" uuid NOT NULL,
    "envelopeId" uuid NOT NULL,
    "enabled" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "transaction_rule_entity_idx" ON "transaction_rule" USING btree ("entityId");
CREATE UNIQUE INDEX "transaction_rule_payee_unique_idx" ON "transaction_rule" USING btree ("payeeId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "transfer" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "fromTransactionId" uuid NOT NULL,
    "toTransactionId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "transfer_from_unique_idx" ON "transfer" USING btree ("fromTransactionId");
CREATE UNIQUE INDEX "transfer_to_unique_idx" ON "transfer" USING btree ("toTransactionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_settings" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userId" uuid NOT NULL,
    "reportingCurrencyCode" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "user_settings_user_unique_idx" ON "user_settings" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "wallet" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "entityId" uuid NOT NULL,
    "accountId" uuid NOT NULL,
    "network" text NOT NULL,
    "address" text NOT NULL,
    "label" text,
    "lastSignature" text,
    "syncStatus" text NOT NULL DEFAULT 'pending'::text,
    "lastSyncedAt" timestamp without time zone,
    "lastSyncError" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "wallet_account_unique_idx" ON "wallet" USING btree ("accountId");
CREATE UNIQUE INDEX "wallet_entity_network_address_unique_idx" ON "wallet" USING btree ("entityId", "network", "address");
CREATE INDEX "wallet_address_idx" ON "wallet" USING btree ("address");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "wallet_holding" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text,
    "name" text,
    "tokenProgram" text,
    "decimals" bigint NOT NULL,
    "quantityRaw" text NOT NULL,
    "isNft" boolean NOT NULL DEFAULT false,
    "priceCurrencyCode" text,
    "unitPrice" text,
    "valueMinor" bigint,
    "priceSource" text,
    "priceQuality" text NOT NULL DEFAULT 'unpriced'::text,
    "priceConfidence" text,
    "priceAsOf" timestamp without time zone,
    "costBasisMinor" bigint,
    "realizedPnlMinor" bigint,
    "pnlAsOf" timestamp without time zone,
    "metadataJson" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "wallet_holding_wallet_asset_unique_idx" ON "wallet_holding" USING btree ("walletId", "assetId");
CREATE INDEX "wallet_holding_asset_idx" ON "wallet_holding" USING btree ("assetId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "wallet_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "signature" text NOT NULL,
    "slot" bigint NOT NULL,
    "occurredAt" timestamp without time zone,
    "description" text NOT NULL,
    "txType" text NOT NULL,
    "source" text NOT NULL,
    "interpretationConfidence" text,
    "programsJson" text,
    "nativeTransfersJson" text,
    "tokenTransfersJson" text,
    "pnlCurrencyCode" text,
    "costBasisMinor" bigint,
    "proceedsMinor" bigint,
    "realizedPnlMinor" bigint,
    "category" text,
    "tags" json,
    "memo" text,
    "rawJson" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "wallet_transaction_wallet_signature_unique_idx" ON "wallet_transaction" USING btree ("walletId", "signature");
CREATE INDEX "wallet_transaction_wallet_time_idx" ON "wallet_transaction" USING btree ("walletId", "occurredAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "downloadFileName" text,
    "contentType" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" USING btree ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" USING btree ("expiration");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "maxFileSize" bigint NOT NULL DEFAULT 10485760,
    "contentLength" bigint,
    "preventOverwrite" boolean NOT NULL DEFAULT false,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text,
    "scheduling" json
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_apple_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userIdentifier" text NOT NULL,
    "refreshToken" text NOT NULL,
    "refreshTokenRequestedWithBundleIdentifier" boolean NOT NULL,
    "lastRefreshedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text,
    "isEmailVerified" boolean,
    "isPrivateEmail" boolean,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_apple_account_identifier" ON "serverpod_auth_idp_apple_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_email_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "passwordHash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_email" ON "serverpod_auth_idp_email_account" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_email_account_otp_login_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" text NOT NULL,
    "challengeId" uuid NOT NULL,
    "completeChallengeId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_otp_login_request_email" ON "serverpod_auth_idp_email_account_otp_login_request" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "emailAccountId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "challengeId" uuid NOT NULL,
    "setPasswordChallengeId" uuid
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_email_account_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" text NOT NULL,
    "challengeId" uuid NOT NULL,
    "createAccountChallengeId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_request_email" ON "serverpod_auth_idp_email_account_request" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_facebook_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "fullName" text,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_facebook_account_user_identifier" ON "serverpod_auth_idp_facebook_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_firebase_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text,
    "phone" text,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_firebase_account_user_identifier" ON "serverpod_auth_idp_firebase_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_github_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_github_account_user_identifier" ON "serverpod_auth_idp_github_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_google_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_google_account_user_identifier" ON "serverpod_auth_idp_google_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_microsoft_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_microsoft_account_user_identifier" ON "serverpod_auth_idp_microsoft_account" USING btree ("userIdentifier");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_passkey_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "keyId" bytea NOT NULL,
    "keyIdBase64" text NOT NULL,
    "clientDataJSON" bytea NOT NULL,
    "attestationObject" bytea NOT NULL,
    "originalChallenge" bytea NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_passkey_account_key_id_base64" ON "serverpod_auth_idp_passkey_account" USING btree ("keyIdBase64");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "challenge" bytea NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "domain" text NOT NULL,
    "source" text NOT NULL,
    "key" text NOT NULL,
    "ipAddress" text,
    "attemptedAt" timestamp without time zone NOT NULL,
    "extraData" json
);

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" USING btree ("domain", "source", "key", "attemptedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "challengeCodeHash" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_core_jwt_refresh_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "extraClaims" text,
    "method" text NOT NULL,
    "fixedSecret" bytea NOT NULL,
    "rotatingSecretHash" text NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "serverpod_auth_core_jwt_refresh_token_last_updated_at" ON "serverpod_auth_core_jwt_refresh_token" USING btree ("lastUpdatedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_core_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "imageId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_profile_user_profile_email_auth_user_id" ON "serverpod_auth_core_profile" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_core_profile_image" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userProfileId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "url" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_core_session" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone,
    "expireAfterUnusedFor" bigint,
    "sessionKeyHash" bytea NOT NULL,
    "sessionKeySalt" bytea NOT NULL,
    "method" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_1"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_2"
    FOREIGN KEY("plaidConnectionId")
    REFERENCES "plaid_connection"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_3"
    FOREIGN KEY("ledgerAccountId")
    REFERENCES "ledger_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "account_valuation"
    ADD CONSTRAINT "account_valuation_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_access_token"
    ADD CONSTRAINT "agent_access_token_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_conversation"
    ADD CONSTRAINT "agent_conversation_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "agent_conversation"
    ADD CONSTRAINT "agent_conversation_fk_1"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
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
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "agent_proposal"
    ADD CONSTRAINT "agent_proposal_fk_1"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "agent_proposal"
    ADD CONSTRAINT "agent_proposal_fk_2"
    FOREIGN KEY("conversationId")
    REFERENCES "agent_conversation"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_provider_settings"
    ADD CONSTRAINT "agent_provider_settings_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "agent_usage_record"
    ADD CONSTRAINT "agent_usage_record_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "agent_usage_record"
    ADD CONSTRAINT "agent_usage_record_fk_1"
    FOREIGN KEY("conversationId")
    REFERENCES "agent_conversation"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "audit_event"
    ADD CONSTRAINT "audit_event_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "budget_template"
    ADD CONSTRAINT "budget_template_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "budget_template_line"
    ADD CONSTRAINT "budget_template_line_fk_0"
    FOREIGN KEY("templateId")
    REFERENCES "budget_template"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "budget_template_line"
    ADD CONSTRAINT "budget_template_line_fk_1"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "category"
    ADD CONSTRAINT "category_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "entitlement"
    ADD CONSTRAINT "entitlement_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "entity"
    ADD CONSTRAINT "entity_fk_0"
    FOREIGN KEY("ownerId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "entity"
    ADD CONSTRAINT "entity_fk_1"
    FOREIGN KEY("linkedPersonalEntityId")
    REFERENCES "entity"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "envelope"
    ADD CONSTRAINT "envelope_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "envelope"
    ADD CONSTRAINT "envelope_fk_1"
    FOREIGN KEY("categoryId")
    REFERENCES "category"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "envelope"
    ADD CONSTRAINT "envelope_fk_2"
    FOREIGN KEY("defaultLedgerAccountId")
    REFERENCES "ledger_account"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "envelope_goal"
    ADD CONSTRAINT "envelope_goal_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "envelope_goal"
    ADD CONSTRAINT "envelope_goal_fk_1"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "institution_location"
    ADD CONSTRAINT "institution_location_fk_0"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "journal"
    ADD CONSTRAINT "journal_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "journal"
    ADD CONSTRAINT "journal_fk_1"
    FOREIGN KEY("reversalOfJournalId")
    REFERENCES "journal"("id")
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
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ledger_period_lock"
    ADD CONSTRAINT "ledger_period_lock_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "monthly_allocation"
    ADD CONSTRAINT "monthly_allocation_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "monthly_allocation"
    ADD CONSTRAINT "monthly_allocation_fk_1"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "payee"
    ADD CONSTRAINT "payee_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "plaid_connection"
    ADD CONSTRAINT "plaid_connection_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_1"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_2"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "recurring_transaction"
    ADD CONSTRAINT "recurring_transaction_fk_3"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "solana_billing_challenge"
    ADD CONSTRAINT "solana_billing_challenge_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "stripe_customer"
    ADD CONSTRAINT "stripe_customer_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "tax_profile"
    ADD CONSTRAINT "tax_profile_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_1"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_2"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_3"
    FOREIGN KEY("recurringTransactionId")
    REFERENCES "recurring_transaction"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_line"
    ADD CONSTRAINT "transaction_line_fk_0"
    FOREIGN KEY("transactionId")
    REFERENCES "transaction"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_line"
    ADD CONSTRAINT "transaction_line_fk_1"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_line"
    ADD CONSTRAINT "transaction_line_fk_2"
    FOREIGN KEY("ledgerAccountId")
    REFERENCES "ledger_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_1"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_2"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "transfer"
    ADD CONSTRAINT "transfer_fk_0"
    FOREIGN KEY("fromTransactionId")
    REFERENCES "transaction"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transfer"
    ADD CONSTRAINT "transfer_fk_1"
    FOREIGN KEY("toTransactionId")
    REFERENCES "transaction"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "user_settings"
    ADD CONSTRAINT "user_settings_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "wallet"
    ADD CONSTRAINT "wallet_fk_0"
    FOREIGN KEY("entityId")
    REFERENCES "entity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "wallet"
    ADD CONSTRAINT "wallet_fk_1"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "wallet_holding"
    ADD CONSTRAINT "wallet_holding_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "wallet"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "wallet_transaction"
    ADD CONSTRAINT "wallet_transaction_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "wallet"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_anonymous_account"
    ADD CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_apple_account"
    ADD CONSTRAINT "serverpod_auth_idp_apple_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_otp_login_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_otp_login_request_fk_0"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_otp_login_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_otp_login_request_fk_1"
    FOREIGN KEY("completeChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_0"
    FOREIGN KEY("emailAccountId")
    REFERENCES "serverpod_auth_idp_email_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_1"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_2"
    FOREIGN KEY("setPasswordChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_0"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_1"
    FOREIGN KEY("createAccountChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_facebook_account"
    ADD CONSTRAINT "serverpod_auth_idp_facebook_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_firebase_account"
    ADD CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_github_account"
    ADD CONSTRAINT "serverpod_auth_idp_github_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_google_account"
    ADD CONSTRAINT "serverpod_auth_idp_google_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_microsoft_account"
    ADD CONSTRAINT "serverpod_auth_idp_microsoft_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_idp_passkey_account"
    ADD CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_core_jwt_refresh_token"
    ADD CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_1"
    FOREIGN KEY("imageId")
    REFERENCES "serverpod_auth_core_profile_image"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_core_profile_image"
    ADD CONSTRAINT "serverpod_auth_core_profile_image_fk_0"
    FOREIGN KEY("userProfileId")
    REFERENCES "serverpod_auth_core_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_auth_core_session"
    ADD CONSTRAINT "serverpod_auth_core_session_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR openbudget
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('openbudget', '20261109142242191-schema-reset', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261109142242191-schema-reset', "timestamp" = now();

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
