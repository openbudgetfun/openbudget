import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import { GcpNetworking, } from "./networking";

export interface GcpCacheArgs {
  environment: string;
  project: string;
  networking: GcpNetworking;
  enabled: boolean;
  password?: pulumi.Output<string>;
}

export class GcpCache extends pulumi.ComponentResource {
  public readonly host?: pulumi.Output<string>;
  public readonly port?: pulumi.Output<number>;

  constructor(
    name: string,
    args: GcpCacheArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Cache", name, args, opts,);

    if (!args.enabled) {
      this.registerOutputs({},);
      return;
    }

    const instance = new gcp.redis.Instance(
      `${name}-instance`,
      {
        tier: args.environment === "production" ? "STANDARD_HA" : "BASIC",
        memorySizeGb: 1,
        redisVersion: "REDIS_7_0",
        authorizedNetwork: args.networking.network.id,
        connectMode: "PRIVATE_SERVICE_ACCESS",
        project: args.project,
        labels: { environment: args.environment, },
      },
      { parent: this, },
    );

    this.host = instance.host;
    this.port = instance.port;

    this.registerOutputs({
      host: this.host,
      port: this.port,
    },);
  }
}
