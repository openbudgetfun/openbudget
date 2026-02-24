import * as pulumi from "@pulumi/pulumi";
import { InfraConfig, } from "../config";
import { GcpCache, } from "./cache";
import { GcpCompute, } from "./compute";
import { GcpDatabase, } from "./database";
import { GcpDns, } from "./dns";
import { GcpNetworking, } from "./networking";
import { GcpStorage, } from "./storage";

export class ServerpodGcpStack extends pulumi.ComponentResource {
  public readonly apiUrl: pulumi.Output<string>;
  public readonly webUrl: pulumi.Output<string>;
  public readonly insightsUrl: pulumi.Output<string>;
  public readonly databaseHost: pulumi.Output<string>;
  public readonly registryUrl: pulumi.Output<string>;

  constructor(
    name: string,
    config: InfraConfig,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Stack", name, {}, opts,);

    const project = config.gcpProject ?? "openbudget";

    const networking = new GcpNetworking(
      `${name}-net`,
      { environment: config.environment, project, },
      { parent: this, },
    );

    const database = new GcpDatabase(
      `${name}-db`,
      {
        environment: config.environment,
        project,
        networking,
        tier: config.dbTier,
        password: config.dbPassword,
      },
      { parent: this, },
    );

    new GcpCache(
      `${name}-cache`,
      {
        environment: config.environment,
        project,
        networking,
        enabled: config.redisEnabled,
        password: config.redisPassword,
      },
      { parent: this, },
    );

    const dns = new GcpDns(
      `${name}-dns`,
      {
        environment: config.environment,
        project,
        domain: config.domain,
      },
      { parent: this, },
    );

    new GcpStorage(
      `${name}-storage`,
      {
        environment: config.environment,
        project,
        domain: config.domain,
      },
      { parent: this, },
    );

    const compute = new GcpCompute(
      `${name}-compute`,
      {
        environment: config.environment,
        project,
        domain: config.domain,
        networking,
        cpu: config.cloudRunCpu,
        memory: config.cloudRunMemory,
        dbPassword: config.dbPassword,
        serviceSecret: config.serviceSecret,
        redisEnabled: config.redisEnabled,
        redisPassword: config.redisPassword,
      },
      { parent: this, },
    );

    // Point DNS records at the global IP
    dns.createLoadBalancerRecords(
      config.environment,
      config.domain,
      compute.globalIpAddress,
    );

    this.apiUrl = compute.apiUrl;
    this.webUrl = compute.webUrl;
    this.insightsUrl = compute.insightsUrl;
    this.databaseHost = database.host;
    this.registryUrl = compute.repositoryUrl;

    this.registerOutputs({
      apiUrl: this.apiUrl,
      webUrl: this.webUrl,
      insightsUrl: this.insightsUrl,
      databaseHost: this.databaseHost,
      registryUrl: this.registryUrl,
    },);
  }
}
