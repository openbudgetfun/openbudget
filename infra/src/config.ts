import * as pulumi from "@pulumi/pulumi";

export type CloudProvider = "aws" | "gcp";
export type Environment = "staging" | "production";

export interface InfraConfig {
  cloudProvider: CloudProvider;
  environment: Environment;
  domain: string;
  dbPassword: pulumi.Output<string>;
  redisEnabled: boolean;
  redisPassword?: pulumi.Output<string>;
  serviceSecret: pulumi.Output<string>;
  // AWS
  dbInstanceClass: string;
  containerCpu: number;
  containerMemory: number;
  // GCP
  gcpProject?: string;
  dbTier: string;
  cloudRunCpu: string;
  cloudRunMemory: string;
}

export function getConfig(): InfraConfig {
  const config = new pulumi.Config();
  const gcpConfig = new pulumi.Config("gcp",);

  return {
    cloudProvider: config.require("cloudProvider",) as CloudProvider,
    environment: config.require("environment",) as Environment,
    domain: config.require("domain",),
    dbPassword: config.requireSecret("dbPassword",),
    redisEnabled: config.getBoolean("redisEnabled",) ?? false,
    redisPassword: config.getSecret("redisPassword",),
    serviceSecret: config.requireSecret("serviceSecret",),
    dbInstanceClass: config.get("dbInstanceClass",) ?? "db.t3.micro",
    containerCpu: config.getNumber("containerCpu",) ?? 256,
    containerMemory: config.getNumber("containerMemory",) ?? 512,
    gcpProject: gcpConfig.get("project",),
    dbTier: config.get("dbTier",) ?? "db-f1-micro",
    cloudRunCpu: config.get("cloudRunCpu",) ?? "1",
    cloudRunMemory: config.get("cloudRunMemory",) ?? "512Mi",
  };
}
