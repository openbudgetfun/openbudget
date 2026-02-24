import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

export interface AwsDnsArgs {
  environment: string;
  domain: string;
}

export class AwsDns extends pulumi.ComponentResource {
  public readonly zoneId: pulumi.Output<string>;
  public readonly certificateArn: pulumi.Output<string>;

  constructor(
    name: string,
    args: AwsDnsArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Dns", name, args, opts,);

    // Route53 Hosted Zone
    const zone = new aws.route53.Zone(
      `${name}-zone`,
      {
        name: args.domain,
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );
    this.zoneId = zone.zoneId;

    // ACM Certificate with wildcard
    const cert = new aws.acm.Certificate(
      `${name}-cert`,
      {
        domainName: args.domain,
        subjectAlternativeNames: [`*.${args.domain}`,],
        validationMethod: "DNS",
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // DNS validation record
    const validationRecord = new aws.route53.Record(
      `${name}-cert-validation`,
      {
        zoneId: zone.zoneId,
        name: cert.domainValidationOptions[0].resourceRecordName,
        type: cert.domainValidationOptions[0].resourceRecordType,
        records: [cert.domainValidationOptions[0].resourceRecordValue,],
        ttl: 60,
      },
      { parent: this, },
    );

    const certValidation = new aws.acm.CertificateValidation(
      `${name}-cert-validated`,
      {
        certificateArn: cert.arn,
        validationRecordFqdns: [validationRecord.fqdn,],
      },
      { parent: this, },
    );

    this.certificateArn = certValidation.certificateArn;

    this.registerOutputs({
      zoneId: this.zoneId,
      certificateArn: this.certificateArn,
    },);
  }

  /**
   * Create DNS A-record aliases pointing subdomains to the ALB.
   */
  public createAlbRecords(
    environment: string,
    domain: string,
    albDnsName: pulumi.Output<string>,
    albZoneId: pulumi.Output<string>,
  ): void {
    const envPrefix = environment === "staging" ? "-staging" : "";

    for (const subdomain of ["api", "app", "insights",]) {
      new aws.route53.Record(
        `${subdomain}${envPrefix}-record`,
        {
          zoneId: this.zoneId,
          name: `${subdomain}${envPrefix}.${domain}`,
          type: "A",
          aliases: [
            {
              name: albDnsName,
              zoneId: albZoneId,
              evaluateTargetHealth: true,
            },
          ],
        },
        { parent: this, },
      );
    }
  }
}
