import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

export interface AwsStorageArgs {
  environment: string;
  domain: string;
}

export class AwsStorage extends pulumi.ComponentResource {
  public readonly bucketName: pulumi.Output<string>;
  public readonly bucketArn: pulumi.Output<string>;

  constructor(
    name: string,
    args: AwsStorageArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Storage", name, args, opts,);

    const bucket = new aws.s3.BucketV2(
      `${name}-bucket`,
      {
        forceDestroy: args.environment === "staging",
        tags: { Name: `${name}-bucket`, Environment: args.environment, },
      },
      { parent: this, },
    );

    new aws.s3.BucketPublicAccessBlock(
      `${name}-public-access`,
      {
        bucket: bucket.id,
        blockPublicAcls: true,
        blockPublicPolicy: true,
        ignorePublicAcls: true,
        restrictPublicBuckets: true,
      },
      { parent: this, },
    );

    new aws.s3.BucketServerSideEncryptionConfigurationV2(
      `${name}-encryption`,
      {
        bucket: bucket.id,
        rules: [
          {
            applyServerSideEncryptionByDefault: {
              sseAlgorithm: "AES256",
            },
          },
        ],
      },
      { parent: this, },
    );

    new aws.s3.BucketVersioningV2(
      `${name}-versioning`,
      {
        bucket: bucket.id,
        versioningConfiguration: {
          status: args.environment === "production" ? "Enabled" : "Suspended",
        },
      },
      { parent: this, },
    );

    this.bucketName = bucket.bucket;
    this.bucketArn = bucket.arn;

    this.registerOutputs({
      bucketName: this.bucketName,
      bucketArn: this.bucketArn,
    },);
  }
}
