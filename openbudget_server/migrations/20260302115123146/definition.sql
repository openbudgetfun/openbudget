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
-- Class Account as table account
--
CREATE TABLE "account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "accountType" text NOT NULL,
    "balanceCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "budgetId" uuid NOT NULL,
    "creatorId" uuid,
    "institutionId" uuid,
    "onBudget" boolean NOT NULL,
    "sortOrder" bigint NOT NULL,
    "isClosed" boolean NOT NULL,
    "sourceType" text,
    "externalAccountId" text,
    "connectionId" uuid,
    "lastSyncedAt" timestamp without time zone,
    "syncStatus" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "account_budget_idx" ON "account" USING btree ("budgetId");
CREATE INDEX "account_budget_external_idx" ON "account" USING btree ("budgetId", "externalAccountId");

--
-- Class AssetQuoteCache as table asset_quote_cache
--
CREATE TABLE "asset_quote_cache" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "chain" text NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text NOT NULL,
    "usdPrice" double precision NOT NULL,
    "fetchedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "asset_quote_cache_chain_asset_idx" ON "asset_quote_cache" USING btree ("chain", "assetId");
CREATE INDEX "asset_quote_cache_expires_idx" ON "asset_quote_cache" USING btree ("expiresAt");

--
-- Class Budget as table budget
--
CREATE TABLE "budget" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "currencyCode" text NOT NULL,
    "displayCurrencyCode" text,
    "ownerId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "budget_owner_idx" ON "budget" USING btree ("ownerId");

--
-- Class BudgetTemplate as table budget_template
--
CREATE TABLE "budget_template" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "name" text NOT NULL,
    "allocationData" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "budget_template_budget_idx" ON "budget_template" USING btree ("budgetId");

--
-- Class Category as table category
--
CREATE TABLE "category" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "budgetId" uuid NOT NULL,
    "sortOrder" bigint NOT NULL,
    "isHidden" boolean DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "category_budget_idx" ON "category" USING btree ("budgetId");

--
-- Class Envelope as table envelope
--
CREATE TABLE "envelope" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "categoryId" uuid NOT NULL,
    "budgetedAmountCents" bigint NOT NULL,
    "spentAmountCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "sortOrder" bigint NOT NULL,
    "note" text,
    "isHidden" boolean DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "envelope_category_idx" ON "envelope" USING btree ("categoryId");

--
-- Class EnvelopeGoal as table envelope_goal
--
CREATE TABLE "envelope_goal" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "envelopeId" uuid NOT NULL,
    "goalType" text NOT NULL,
    "targetAmountCents" bigint NOT NULL,
    "targetDate" timestamp without time zone,
    "monthlyFundingCents" bigint,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "envelope_goal_envelope_idx" ON "envelope_goal" USING btree ("envelopeId");

--
-- Class FxRateEntry as table fx_rate_entry
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
-- Class FxRateSnapshot as table fx_rate_snapshot
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
-- Class Institution as table institution
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
-- Class InstitutionLocation as table institution_location
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
-- Class MonthlyAllocation as table monthly_allocation
--
CREATE TABLE "monthly_allocation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "envelopeId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "year" bigint NOT NULL,
    "month" bigint NOT NULL,
    "allocatedCents" bigint NOT NULL,
    "carryoverCents" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "monthly_allocation_envelope_idx" ON "monthly_allocation" USING btree ("envelopeId");
CREATE INDEX "monthly_allocation_budget_idx" ON "monthly_allocation" USING btree ("budgetId");
CREATE UNIQUE INDEX "monthly_allocation_unique_idx" ON "monthly_allocation" USING btree ("envelopeId", "year", "month");

--
-- Class Payee as table payee
--
CREATE TABLE "payee" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "budgetId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "payee_budget_idx" ON "payee" USING btree ("budgetId");
CREATE UNIQUE INDEX "payee_name_budget_idx" ON "payee" USING btree ("budgetId", "name");

--
-- Class PlaidConnection as table plaid_connection
--
CREATE TABLE "plaid_connection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "plaidItemId" text NOT NULL,
    "accessToken" text NOT NULL,
    "institutionName" text,
    "institutionId" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSyncedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "plaid_connection_budget_item_idx" ON "plaid_connection" USING btree ("budgetId", "plaidItemId");
CREATE INDEX "plaid_connection_budget_idx" ON "plaid_connection" USING btree ("budgetId");

--
-- Class RecurringTransaction as table recurring_transaction
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
-- Class SolanaWallet as table solana_wallet
--
CREATE TABLE "solana_wallet" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "accountId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "address" text NOT NULL,
    "label" text,
    "cluster" text NOT NULL,
    "lastSignature" text,
    "lastSyncedAt" timestamp without time zone,
    "syncStatus" text NOT NULL,
    "lastSyncError" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "solana_wallet_account_unique" ON "solana_wallet" USING btree ("accountId");
CREATE INDEX "solana_wallet_budget_idx" ON "solana_wallet" USING btree ("budgetId");
CREATE INDEX "solana_wallet_address_idx" ON "solana_wallet" USING btree ("address");

--
-- Class SolanaWalletHolding as table solana_wallet_holding
--
CREATE TABLE "solana_wallet_holding" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text,
    "name" text,
    "tokenProgram" text,
    "decimals" bigint NOT NULL,
    "balanceRaw" text NOT NULL,
    "balanceUi" text NOT NULL,
    "isNft" boolean NOT NULL,
    "priceCurrency" text,
    "pricePerToken" double precision,
    "totalValue" double precision,
    "estimatedCostBasis" double precision,
    "estimatedUnrealizedPnl" double precision,
    "estimatedUnrealizedPnlPercent" double precision,
    "estimatedRealizedPnl" double precision,
    "pnlCurrency" text,
    "pnlAsOf" timestamp without time zone,
    "priceSource" text,
    "priceQuality" text,
    "priceConfidence" text,
    "isPriceStale" boolean,
    "priceAsOf" timestamp without time zone,
    "metadataJson" text,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "solana_wallet_holding_wallet_idx" ON "solana_wallet_holding" USING btree ("walletId");
CREATE INDEX "solana_wallet_holding_budget_idx" ON "solana_wallet_holding" USING btree ("budgetId");
CREATE INDEX "solana_wallet_holding_asset_idx" ON "solana_wallet_holding" USING btree ("assetId");
CREATE UNIQUE INDEX "solana_wallet_holding_wallet_asset_unique" ON "solana_wallet_holding" USING btree ("walletId", "assetId");

--
-- Class SolanaWalletTransaction as table solana_wallet_transaction
--
CREATE TABLE "solana_wallet_transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletId" uuid NOT NULL,
    "budgetId" uuid NOT NULL,
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
    "estimatedCostBasis" double precision,
    "estimatedProceeds" double precision,
    "estimatedRealizedPnl" double precision,
    "pnlCurrency" text,
    "taxYear" bigint,
    "category" text,
    "tagsCsv" text,
    "memo" text,
    "rawJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "solana_wallet_tx_wallet_idx" ON "solana_wallet_transaction" USING btree ("walletId");
CREATE INDEX "solana_wallet_tx_budget_idx" ON "solana_wallet_transaction" USING btree ("budgetId");
CREATE INDEX "solana_wallet_tx_signature_idx" ON "solana_wallet_transaction" USING btree ("signature");
CREATE UNIQUE INDEX "solana_wallet_tx_wallet_signature_unique" ON "solana_wallet_transaction" USING btree ("walletId", "signature");

--
-- Class Transaction as table transaction
--
CREATE TABLE "transaction" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "description" text NOT NULL,
    "amountCents" bigint NOT NULL,
    "currencyCode" text NOT NULL,
    "envelopeId" uuid,
    "budgetId" uuid NOT NULL,
    "accountId" uuid,
    "payeeId" uuid,
    "transactionDate" timestamp without time zone NOT NULL,
    "transferPairId" uuid,
    "parentTransactionId" uuid,
    "memo" text,
    "cleared" boolean NOT NULL DEFAULT false,
    "reconciled" boolean NOT NULL DEFAULT false,
    "flagColor" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "transaction_envelope_idx" ON "transaction" USING btree ("envelopeId");
CREATE INDEX "transaction_budget_idx" ON "transaction" USING btree ("budgetId");
CREATE INDEX "transaction_account_idx" ON "transaction" USING btree ("accountId");
CREATE INDEX "transaction_payee_idx" ON "transaction" USING btree ("payeeId");
CREATE INDEX "transaction_date_idx" ON "transaction" USING btree ("transactionDate");
CREATE INDEX "transaction_parent_idx" ON "transaction" USING btree ("parentTransactionId");

--
-- Class TransactionRule as table transaction_rule
--
CREATE TABLE "transaction_rule" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "payeeId" uuid NOT NULL,
    "targetEnvelopeId" uuid NOT NULL,
    "enabled" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "transaction_rule_budget_idx" ON "transaction_rule" USING btree ("budgetId");
CREATE UNIQUE INDEX "transaction_rule_payee_budget_idx" ON "transaction_rule" USING btree ("budgetId", "payeeId");

--
-- Class WalletConnection as table wallet_connection
--
CREATE TABLE "wallet_connection" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "budgetId" uuid NOT NULL,
    "chain" text NOT NULL,
    "address" text NOT NULL,
    "label" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSyncedAt" timestamp without time zone,
    "syncStatus" text,
    "lastError" text
);

-- Indexes
CREATE UNIQUE INDEX "wallet_connection_budget_chain_address_idx" ON "wallet_connection" USING btree ("budgetId", "chain", "address");
CREATE INDEX "wallet_connection_budget_idx" ON "wallet_connection" USING btree ("budgetId");

--
-- Class WalletHolding as table wallet_holding
--
CREATE TABLE "wallet_holding" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "walletConnectionId" uuid NOT NULL,
    "chain" text NOT NULL,
    "assetId" text NOT NULL,
    "symbol" text NOT NULL,
    "decimals" bigint NOT NULL,
    "quantityBaseUnits" text NOT NULL,
    "quantityDisplay" double precision NOT NULL,
    "usdPrice" double precision,
    "usdValue" double precision,
    "lastSyncedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "wallet_holding_connection_asset_idx" ON "wallet_holding" USING btree ("walletConnectionId", "assetId");
CREATE INDEX "wallet_holding_connection_idx" ON "wallet_holding" USING btree ("walletConnectionId");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
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
-- Class ServerHealthMetric as table serverpod_health_metric
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
-- Class LogEntry as table serverpod_log
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
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId");

--
-- Class MessageLogEntry as table serverpod_message_log
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

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
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
-- Class QueryLogEntry as table serverpod_query_log
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
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
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
-- Class AnonymousAccount as table serverpod_auth_idp_anonymous_account
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- Class AppleAccount as table serverpod_auth_idp_apple_account
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
-- Class EmailAccount as table serverpod_auth_idp_email_account
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
-- Class EmailAccountPasswordResetRequest as table serverpod_auth_idp_email_account_password_reset_request
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "emailAccountId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "challengeId" uuid NOT NULL,
    "setPasswordChallengeId" uuid
);

--
-- Class EmailAccountRequest as table serverpod_auth_idp_email_account_request
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
-- Class FirebaseAccount as table serverpod_auth_idp_firebase_account
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
-- Class GitHubAccount as table serverpod_auth_idp_github_account
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
-- Class GoogleAccount as table serverpod_auth_idp_google_account
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
-- Class PasskeyAccount as table serverpod_auth_idp_passkey_account
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
-- Class PasskeyChallenge as table serverpod_auth_idp_passkey_challenge
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "challenge" bytea NOT NULL
);

--
-- Class RateLimitedRequestAttempt as table serverpod_auth_idp_rate_limited_request_attempt
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "domain" text NOT NULL,
    "source" text NOT NULL,
    "nonce" text NOT NULL,
    "ipAddress" text,
    "attemptedAt" timestamp without time zone NOT NULL,
    "extraData" json
);

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" USING btree ("domain", "source", "nonce", "attemptedAt");

--
-- Class SecretChallenge as table serverpod_auth_idp_secret_challenge
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "challengeCodeHash" text NOT NULL
);

--
-- Class RefreshToken as table serverpod_auth_core_jwt_refresh_token
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
-- Class UserProfile as table serverpod_auth_core_profile
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
-- Class UserProfileImage as table serverpod_auth_core_profile_image
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
-- Class ServerSideSession as table serverpod_auth_core_session
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
-- Class AuthUser as table serverpod_auth_core_user
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

--
-- Foreign relations for "account" table
--
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "account"
    ADD CONSTRAINT "account_fk_1"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "budget_template" table
--
ALTER TABLE ONLY "budget_template"
    ADD CONSTRAINT "budget_template_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "category" table
--
ALTER TABLE ONLY "category"
    ADD CONSTRAINT "category_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "envelope" table
--
ALTER TABLE ONLY "envelope"
    ADD CONSTRAINT "envelope_fk_0"
    FOREIGN KEY("categoryId")
    REFERENCES "category"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "envelope_goal" table
--
ALTER TABLE ONLY "envelope_goal"
    ADD CONSTRAINT "envelope_goal_fk_0"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "fx_rate_entry" table
--
ALTER TABLE ONLY "fx_rate_entry"
    ADD CONSTRAINT "fx_rate_entry_fk_0"
    FOREIGN KEY("snapshotId")
    REFERENCES "fx_rate_snapshot"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "institution_location" table
--
ALTER TABLE ONLY "institution_location"
    ADD CONSTRAINT "institution_location_fk_0"
    FOREIGN KEY("institutionId")
    REFERENCES "institution"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "monthly_allocation" table
--
ALTER TABLE ONLY "monthly_allocation"
    ADD CONSTRAINT "monthly_allocation_fk_0"
    FOREIGN KEY("envelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "monthly_allocation"
    ADD CONSTRAINT "monthly_allocation_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "payee" table
--
ALTER TABLE ONLY "payee"
    ADD CONSTRAINT "payee_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "plaid_connection" table
--
ALTER TABLE ONLY "plaid_connection"
    ADD CONSTRAINT "plaid_connection_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "recurring_transaction" table
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
-- Foreign relations for "solana_wallet" table
--
ALTER TABLE ONLY "solana_wallet"
    ADD CONSTRAINT "solana_wallet_fk_0"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet"
    ADD CONSTRAINT "solana_wallet_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "solana_wallet_holding" table
--
ALTER TABLE ONLY "solana_wallet_holding"
    ADD CONSTRAINT "solana_wallet_holding_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "solana_wallet"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet_holding"
    ADD CONSTRAINT "solana_wallet_holding_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "solana_wallet_transaction" table
--
ALTER TABLE ONLY "solana_wallet_transaction"
    ADD CONSTRAINT "solana_wallet_transaction_fk_0"
    FOREIGN KEY("walletId")
    REFERENCES "solana_wallet"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "solana_wallet_transaction"
    ADD CONSTRAINT "solana_wallet_transaction_fk_1"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "transaction" table
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
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_2"
    FOREIGN KEY("accountId")
    REFERENCES "account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction"
    ADD CONSTRAINT "transaction_fk_3"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "transaction_rule" table
--
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_1"
    FOREIGN KEY("payeeId")
    REFERENCES "payee"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "transaction_rule"
    ADD CONSTRAINT "transaction_rule_fk_2"
    FOREIGN KEY("targetEnvelopeId")
    REFERENCES "envelope"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "wallet_connection" table
--
ALTER TABLE ONLY "wallet_connection"
    ADD CONSTRAINT "wallet_connection_fk_0"
    FOREIGN KEY("budgetId")
    REFERENCES "budget"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "wallet_holding" table
--
ALTER TABLE ONLY "wallet_holding"
    ADD CONSTRAINT "wallet_holding_fk_0"
    FOREIGN KEY("walletConnectionId")
    REFERENCES "wallet_connection"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_anonymous_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_anonymous_account"
    ADD CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_apple_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_apple_account"
    ADD CONSTRAINT "serverpod_auth_idp_apple_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_password_reset_request" table
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
-- Foreign relations for "serverpod_auth_idp_email_account_request" table
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
-- Foreign relations for "serverpod_auth_idp_firebase_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_firebase_account"
    ADD CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_github_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_github_account"
    ADD CONSTRAINT "serverpod_auth_idp_github_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_google_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_google_account"
    ADD CONSTRAINT "serverpod_auth_idp_google_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_passkey_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_passkey_account"
    ADD CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_jwt_refresh_token" table
--
ALTER TABLE ONLY "serverpod_auth_core_jwt_refresh_token"
    ADD CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile" table
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
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile_image" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile_image"
    ADD CONSTRAINT "serverpod_auth_core_profile_image_fk_0"
    FOREIGN KEY("userProfileId")
    REFERENCES "serverpod_auth_core_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_session" table
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
