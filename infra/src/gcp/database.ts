import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import { GcpNetworking, } from "./networking";

export interface GcpDatabaseArgs {
  environment: string;
  project: string;
  networking: GcpNetworking;
  tier: string;
  password: pulumi.Output<string>;
  dbName?: string;
}

export class GcpDatabase extends pulumi.ComponentResource {
  public readonly host: pulumi.Output<string>;
  public readonly connectionName: pulumi.Output<string>;
  public readonly dbName: pulumi.Output<string>;
  public readonly username: pulumi.Output<string>;

  constructor(
    name: string,
    args: GcpDatabaseArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Database", name, args, opts,);

    const dbName = args.dbName ?? "serverpod";

    const instance = new gcp.sql.DatabaseInstance(
      `${name}-instance`,
      {
        databaseVersion: "POSTGRES_16",
        project: args.project,
        deletionProtection: args.environment === "production",
        settings: {
          tier: args.tier,
          availabilityType: args.environment === "production" ? "REGIONAL" : "ZONAL",
          backupConfiguration: {
            enabled: true,
            startTime: "03:00",
            pointInTimeRecoveryEnabled: args.environment === "production",
          },
          ipConfiguration: {
            ipv4Enabled: false,
            privateNetwork: args.networking.network.id,
          },
          databaseFlags: [
            { name: "log_connections", value: "on", },
          ],
          diskAutoresize: true,
          diskAutoresizeLimit: 100,
          diskSize: 10,
          diskType: "PD_SSD",
        },
      },
      { parent: this, },
    );

    const database = new gcp.sql.Database(
      `${name}-database`,
      {
        instance: instance.name,
        name: dbName,
        project: args.project,
      },
      { parent: this, },
    );

    const user = new gcp.sql.User(
      `${name}-user`,
      {
        instance: instance.name,
        name: "postgres",
        password: args.password,
        project: args.project,
      },
      { parent: this, },
    );

    this.host = instance.privateIpAddress;
    this.connectionName = instance.connectionName;
    this.dbName = database.name;
    this.username = user.name;

    this.registerOutputs({
      host: this.host,
      connectionName: this.connectionName,
      dbName: this.dbName,
      username: this.username,
    },);
  }
}
