import * as pulumi from "@pulumi/pulumi";
import { InfraConfig, } from "../config";
import { AwsCache, } from "./cache";
import { AwsCompute, } from "./compute";
import { AwsDatabase, } from "./database";
import { AwsDns, } from "./dns";
import { AwsNetworking, } from "./networking";
import { AwsStorage, } from "./storage";

export class ServerpodAwsStack extends pulumi.ComponentResource {
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
    super("openbudget:aws:Stack", name, {}, opts,);

    const networking = new AwsNetworking(
      `${name}-net`,
      { environment: config.environment, },
      { parent: this, },
    );

    const database = new AwsDatabase(
      `${name}-db`,
      {
        environment: config.environment,
        networking,
        instanceClass: config.dbInstanceClass,
        password: config.dbPassword,
      },
      { parent: this, },
    );

    new AwsCache(
      `${name}-cache`,
      {
        environment: config.environment,
        networking,
        enabled: config.redisEnabled,
        password: config.redisPassword,
      },
      { parent: this, },
    );

    const dns = new AwsDns(
      `${name}-dns`,
      {
        environment: config.environment,
        domain: config.domain,
      },
      { parent: this, },
    );

    new AwsStorage(
      `${name}-storage`,
      {
        environment: config.environment,
        domain: config.domain,
      },
      { parent: this, },
    );

    const compute = new AwsCompute(
      `${name}-compute`,
      {
        environment: config.environment,
        domain: config.domain,
        networking,
        certificateArn: dns.certificateArn,
        cpu: config.containerCpu,
        memory: config.containerMemory,
        dbPassword: config.dbPassword,
        redisEnabled: config.redisEnabled,
        redisPassword: config.redisPassword,
        serviceSecret: config.serviceSecret,
      },
      { parent: this, },
    );

    // Point DNS records at the ALB
    dns.createAlbRecords(
      config.environment,
      config.domain,
      compute.albDnsName,
      compute.albZoneId,
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
