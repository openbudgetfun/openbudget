import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import { AwsNetworking, } from "./networking";

export interface AwsDatabaseArgs {
  environment: string;
  networking: AwsNetworking;
  instanceClass: string;
  password: pulumi.Output<string>;
  dbName?: string;
}

export class AwsDatabase extends pulumi.ComponentResource {
  public readonly host: pulumi.Output<string>;
  public readonly port: pulumi.Output<number>;
  public readonly dbName: pulumi.Output<string>;
  public readonly username: pulumi.Output<string>;

  constructor(
    name: string,
    args: AwsDatabaseArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Database", name, args, opts,);

    const dbName = args.dbName ?? "serverpod";

    const subnetGroup = new aws.rds.SubnetGroup(
      `${name}-subnet-group`,
      {
        subnetIds: args.networking.vpc.privateSubnetIds,
        tags: { Name: `${name}-subnet-group`, Environment: args.environment, },
      },
      { parent: this, },
    );

    const parameterGroup = new aws.rds.ParameterGroup(
      `${name}-params`,
      {
        family: "postgres16",
        description: "OpenBudget PostgreSQL 16 parameters",
        parameters: [
          { name: "log_connections", value: "1", applyMethod: "immediate", },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    const instance = new aws.rds.Instance(
      `${name}-instance`,
      {
        engine: "postgres",
        engineVersion: "16",
        instanceClass: args.instanceClass,
        allocatedStorage: 20,
        maxAllocatedStorage: 100,
        storageType: "gp3",
        dbName: dbName,
        username: "postgres",
        password: args.password,
        parameterGroupName: parameterGroup.name,
        dbSubnetGroupName: subnetGroup.name,
        vpcSecurityGroupIds: [args.networking.dbSecurityGroup.id,],
        publiclyAccessible: false,
        storageEncrypted: true,
        backupRetentionPeriod: 7,
        skipFinalSnapshot: args.environment === "staging",
        finalSnapshotIdentifier: pulumi.interpolate`${name}-final-snapshot`,
        tags: { Name: `${name}-instance`, Environment: args.environment, },
      },
      { parent: this, },
    );

    this.host = instance.address;
    this.port = pulumi.output(5432,);
    this.dbName = pulumi.output(dbName,);
    this.username = pulumi.output("postgres",);

    this.registerOutputs({
      host: this.host,
      port: this.port,
      dbName: this.dbName,
      username: this.username,
    },);
  }
}
