import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

export interface GcpDnsArgs {
  environment: string;
  project: string;
  domain: string;
}

export class GcpDns extends pulumi.ComponentResource {
  public readonly managedZone: gcp.dns.ManagedZone;
  public readonly nameServers: pulumi.Output<string[]>;

  constructor(
    name: string,
    args: GcpDnsArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Dns", name, args, opts,);

    this.managedZone = new gcp.dns.ManagedZone(
      `${name}-zone`,
      {
        dnsName: `${args.domain}.`,
        description: `OpenBudget ${args.environment} DNS zone`,
        project: args.project,
        labels: { environment: args.environment, },
      },
      { parent: this, },
    );

    this.nameServers = this.managedZone.nameServers;

    this.registerOutputs({
      nameServers: this.nameServers,
    },);
  }

  /**
   * Create DNS A records pointing subdomains to a global IP address.
   */
  public createLoadBalancerRecords(
    environment: string,
    domain: string,
    ipAddress: pulumi.Output<string>,
  ): void {
    const envPrefix = environment === "staging" ? "-staging" : "";

    for (const subdomain of ["api", "app", "insights",]) {
      new gcp.dns.RecordSet(
        `${subdomain}${envPrefix}-record`,
        {
          managedZone: this.managedZone.name,
          name: `${subdomain}${envPrefix}.${domain}.`,
          type: "A",
          ttl: 300,
          rrdatas: [ipAddress,],
        },
        { parent: this, },
      );
    }
  }
}
