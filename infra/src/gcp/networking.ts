import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

export interface GcpNetworkingArgs {
  environment: string;
  project: string;
}

export class GcpNetworking extends pulumi.ComponentResource {
  public readonly network: gcp.compute.Network;
  public readonly subnet: gcp.compute.Subnetwork;
  public readonly vpcConnector: gcp.vpcaccess.Connector;
  public readonly privateIpRange: gcp.compute.GlobalAddress;

  constructor(
    name: string,
    args: GcpNetworkingArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Networking", name, args, opts,);

    this.network = new gcp.compute.Network(
      `${name}-network`,
      {
        autoCreateSubnetworks: false,
        project: args.project,
      },
      { parent: this, },
    );

    this.subnet = new gcp.compute.Subnetwork(
      `${name}-subnet`,
      {
        network: this.network.id,
        ipCidrRange: "10.0.0.0/20",
        privateIpGoogleAccess: true,
        project: args.project,
      },
      { parent: this, },
    );

    // Reserved IP range for private services (Cloud SQL)
    this.privateIpRange = new gcp.compute.GlobalAddress(
      `${name}-private-ip-range`,
      {
        purpose: "VPC_PEERING",
        addressType: "INTERNAL",
        prefixLength: 16,
        network: this.network.id,
        project: args.project,
      },
      { parent: this, },
    );

    // Private service connection for Cloud SQL
    new gcp.servicenetworking.Connection(
      `${name}-private-svc`,
      {
        network: this.network.id,
        service: "servicenetworking.googleapis.com",
        reservedPeeringRanges: [this.privateIpRange.name,],
      },
      { parent: this, },
    );

    // VPC Access Connector for Cloud Run → private network
    this.vpcConnector = new gcp.vpcaccess.Connector(
      `${name}-connector`,
      {
        network: this.network.id,
        ipCidrRange: "10.8.0.0/28",
        minInstances: 2,
        maxInstances: 3,
        project: args.project,
      },
      { parent: this, },
    );

    // Allow health check traffic from GCP load balancer ranges
    new gcp.compute.Firewall(
      `${name}-allow-health-check`,
      {
        network: this.network.id,
        allows: [{ protocol: "tcp", ports: ["8080", "8081", "8082",], },],
        sourceRanges: ["130.211.0.0/22", "35.191.0.0/16",],
        targetTags: ["serverpod",],
        project: args.project,
      },
      { parent: this, },
    );

    this.registerOutputs({
      networkId: this.network.id,
      subnetId: this.subnet.id,
    },);
  }
}
