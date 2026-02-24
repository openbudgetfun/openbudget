import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import { AwsNetworking, } from "./networking";

export interface AwsCacheArgs {
  environment: string;
  networking: AwsNetworking;
  enabled: boolean;
  password?: pulumi.Output<string>;
}

export class AwsCache extends pulumi.ComponentResource {
  public readonly host?: pulumi.Output<string>;
  public readonly port?: pulumi.Output<number>;

  constructor(
    name: string,
    args: AwsCacheArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Cache", name, args, opts,);

    if (!args.enabled) {
      this.registerOutputs({},);
      return;
    }

    const subnetGroup = new aws.elasticache.SubnetGroup(
      `${name}-subnet-group`,
      {
        subnetIds: args.networking.vpc.privateSubnetIds,
        tags: { Name: `${name}-subnet-group`, Environment: args.environment, },
      },
      { parent: this, },
    );

    const cluster = new aws.elasticache.Cluster(
      `${name}-cluster`,
      {
        engine: "redis",
        engineVersion: "7.0",
        nodeType: "cache.t3.micro",
        numCacheNodes: 1,
        subnetGroupName: subnetGroup.name,
        securityGroupIds: [args.networking.cacheSecurityGroup.id,],
        tags: { Name: `${name}-cluster`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.host = cluster.cacheNodes.apply(
      (nodes,) => nodes[0]?.address ?? "",
    );
    this.port = pulumi.output(6379,);

    this.registerOutputs({
      host: this.host,
      port: this.port,
    },);
  }
}
