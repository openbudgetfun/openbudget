import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
import * as pulumi from "@pulumi/pulumi";

export interface AwsNetworkingArgs {
  environment: string;
}

export class AwsNetworking extends pulumi.ComponentResource {
  public readonly vpc: awsx.ec2.Vpc;
  public readonly dbSecurityGroup: aws.ec2.SecurityGroup;
  public readonly cacheSecurityGroup: aws.ec2.SecurityGroup;
  public readonly appSecurityGroup: aws.ec2.SecurityGroup;
  public readonly albSecurityGroup: aws.ec2.SecurityGroup;

  constructor(
    name: string,
    args: AwsNetworkingArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Networking", name, args, opts,);

    this.vpc = new awsx.ec2.Vpc(
      `${name}-vpc`,
      {
        enableDnsHostnames: true,
        enableDnsSupport: true,
        natGateways: { strategy: awsx.ec2.NatGatewayStrategy.Single, },
        subnetSpecs: [
          { type: awsx.ec2.SubnetType.Public, cidrMask: 24, },
          { type: awsx.ec2.SubnetType.Private, cidrMask: 24, },
        ],
        tags: { Environment: args.environment, Project: "openbudget", },
      },
      { parent: this, },
    );

    this.albSecurityGroup = new aws.ec2.SecurityGroup(
      `${name}-alb-sg`,
      {
        vpcId: this.vpc.vpcId,
        description: "Allow HTTP/HTTPS traffic to ALB",
        ingress: [
          {
            protocol: "tcp",
            fromPort: 80,
            toPort: 80,
            cidrBlocks: ["0.0.0.0/0",],
            description: "HTTP",
          },
          {
            protocol: "tcp",
            fromPort: 443,
            toPort: 443,
            cidrBlocks: ["0.0.0.0/0",],
            description: "HTTPS",
          },
        ],
        egress: [
          {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0",],
            description: "All outbound",
          },
        ],
        tags: { Name: `${name}-alb-sg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.appSecurityGroup = new aws.ec2.SecurityGroup(
      `${name}-app-sg`,
      {
        vpcId: this.vpc.vpcId,
        description: "Allow traffic from ALB to Serverpod containers",
        ingress: [
          {
            protocol: "tcp",
            fromPort: 8080,
            toPort: 8082,
            securityGroups: [this.albSecurityGroup.id,],
            description: "Serverpod ports from ALB",
          },
        ],
        egress: [
          {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0",],
            description: "All outbound",
          },
        ],
        tags: { Name: `${name}-app-sg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.dbSecurityGroup = new aws.ec2.SecurityGroup(
      `${name}-db-sg`,
      {
        vpcId: this.vpc.vpcId,
        description: "Allow PostgreSQL traffic from app containers",
        ingress: [
          {
            protocol: "tcp",
            fromPort: 5432,
            toPort: 5432,
            securityGroups: [this.appSecurityGroup.id,],
            description: "PostgreSQL from app",
          },
        ],
        egress: [
          {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0",],
            description: "All outbound",
          },
        ],
        tags: { Name: `${name}-db-sg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.cacheSecurityGroup = new aws.ec2.SecurityGroup(
      `${name}-cache-sg`,
      {
        vpcId: this.vpc.vpcId,
        description: "Allow Redis traffic from app containers",
        ingress: [
          {
            protocol: "tcp",
            fromPort: 6379,
            toPort: 6379,
            securityGroups: [this.appSecurityGroup.id,],
            description: "Redis from app",
          },
        ],
        egress: [
          {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0",],
            description: "All outbound",
          },
        ],
        tags: { Name: `${name}-cache-sg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.registerOutputs({
      vpcId: this.vpc.vpcId,
    },);
  }
}
