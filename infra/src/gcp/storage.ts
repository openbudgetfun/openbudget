import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";

export interface GcpStorageArgs {
  environment: string;
  project: string;
  domain: string;
}

export class GcpStorage extends pulumi.ComponentResource {
  public readonly bucketName: pulumi.Output<string>;
  public readonly bucketUrl: pulumi.Output<string>;

  constructor(
    name: string,
    args: GcpStorageArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Storage", name, args, opts,);

    const bucket = new gcp.storage.Bucket(
      `${name}-bucket`,
      {
        location: "US",
        forceDestroy: args.environment === "staging",
        uniformBucketLevelAccess: true,
        versioning: {
          enabled: args.environment === "production",
        },
        labels: { environment: args.environment, },
        project: args.project,
      },
      { parent: this, },
    );

    this.bucketName = bucket.name;
    this.bucketUrl = bucket.url;

    this.registerOutputs({
      bucketName: this.bucketName,
      bucketUrl: this.bucketUrl,
    },);
  }
}
