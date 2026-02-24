import * as gcp from "@pulumi/gcp";
import * as pulumi from "@pulumi/pulumi";
import { GcpNetworking, } from "./networking";

export interface GcpComputeArgs {
  environment: string;
  project: string;
  domain: string;
  networking: GcpNetworking;
  cpu: string;
  memory: string;
  dbPassword: pulumi.Output<string>;
  serviceSecret: pulumi.Output<string>;
  redisEnabled: boolean;
  redisPassword?: pulumi.Output<string>;
}

export class GcpCompute extends pulumi.ComponentResource {
  public readonly apiUrl: pulumi.Output<string>;
  public readonly webUrl: pulumi.Output<string>;
  public readonly insightsUrl: pulumi.Output<string>;
  public readonly repositoryUrl: pulumi.Output<string>;
  public readonly globalIpAddress: pulumi.Output<string>;

  constructor(
    name: string,
    args: GcpComputeArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:gcp:Compute", name, args, opts,);

    const envPrefix = args.environment === "staging" ? "-staging" : "";

    // Artifact Registry
    const registry = new gcp.artifactregistry.Repository(
      `${name}-registry`,
      {
        format: "DOCKER",
        repositoryId: `openbudget-${args.environment}`,
        project: args.project,
        labels: { environment: args.environment, },
      },
      { parent: this, },
    );

    const region = gcp.config.region ?? "us-central1";
    this.repositoryUrl = pulumi.interpolate`${region}-docker.pkg.dev/${args.project}/${registry.repositoryId}`;

    // Secrets in Secret Manager
    const dbPasswordSecret = new gcp.secretmanager.Secret(
      `${name}-db-password`,
      {
        secretId: `serverpod-db-password-${args.environment}`,
        replication: { auto: {}, },
        project: args.project,
      },
      { parent: this, },
    );
    new gcp.secretmanager.SecretVersion(
      `${name}-db-password-ver`,
      { secret: dbPasswordSecret.id, secretData: args.dbPassword, },
      { parent: this, },
    );

    const svcSecret = new gcp.secretmanager.Secret(
      `${name}-service-secret`,
      {
        secretId: `serverpod-service-secret-${args.environment}`,
        replication: { auto: {}, },
        project: args.project,
      },
      { parent: this, },
    );
    new gcp.secretmanager.SecretVersion(
      `${name}-service-secret-ver`,
      { secret: svcSecret.id, secretData: args.serviceSecret, },
      { parent: this, },
    );

    // Cloud Run Service Account
    const serviceAccount = new gcp.serviceaccount.Account(
      `${name}-sa`,
      {
        accountId: `serverpod-${args.environment}`,
        displayName: `Serverpod ${args.environment} service account`,
        project: args.project,
      },
      { parent: this, },
    );

    // Grant secret access
    for (
      const [secretName, secret,] of [
        ["db", dbPasswordSecret,],
        ["svc", svcSecret,],
      ] as const
    ) {
      new gcp.secretmanager.SecretIamMember(
        `${name}-${secretName}-access`,
        {
          secretId: secret.id,
          role: "roles/secretmanager.secretAccessor",
          member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
          project: args.project,
        },
        { parent: this, },
      );
    }

    // Grant Cloud SQL client access
    new gcp.projects.IAMMember(
      `${name}-sql-client`,
      {
        role: "roles/cloudsql.client",
        member: pulumi.interpolate`serviceAccount:${serviceAccount.email}`,
        project: args.project,
      },
      { parent: this, },
    );

    // Shared container config
    const containerEnvs = [
      { name: "runmode", value: args.environment, },
      { name: "serverid", value: "default", },
      { name: "logging", value: "normal", },
      { name: "role", value: "monolith", },
    ];

    // Create Cloud Run services for each Serverpod role
    const services: Record<string, { port: number; service: gcp.cloudrunv2.Service; }> = {};

    for (
      const [role, port,] of [
        ["api", 8080,],
        ["web", 8082,],
        ["insights", 8081,],
      ] as [string, number,][]
    ) {
      const svc = new gcp.cloudrunv2.Service(
        `${name}-${role}`,
        {
          location: region,
          ingress: "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER",
          template: {
            serviceAccount: serviceAccount.email,
            vpcAccess: {
              connector: args.networking.vpcConnector.id,
              egress: "ALL_TRAFFIC",
            },
            scaling: {
              minInstanceCount: args.environment === "production" ? 1 : 0,
              maxInstanceCount: args.environment === "production" ? 10 : 3,
            },
            containers: [
              {
                image: pulumi.interpolate`${this.repositoryUrl}/serverpod:latest`,
                ports: { containerPort: port, },
                envs: containerEnvs,
                resources: {
                  limits: {
                    cpu: args.cpu,
                    memory: args.memory,
                  },
                },
              },
            ],
          },
          project: args.project,
          labels: { environment: args.environment, role, },
        },
        { parent: this, },
      );

      services[role] = { port, service: svc, };

      // Allow unauthenticated access (traffic comes through LB)
      new gcp.cloudrunv2.ServiceIamMember(
        `${name}-${role}-invoker`,
        {
          name: svc.name,
          role: "roles/run.invoker",
          member: "allUsers",
          project: args.project,
        },
        { parent: this, },
      );
    }

    // Global static IP for HTTPS Load Balancer
    const globalIp = new gcp.compute.GlobalAddress(
      `${name}-global-ip`,
      { project: args.project, },
      { parent: this, },
    );
    this.globalIpAddress = globalIp.address;

    // Serverless NEGs for each Cloud Run service
    const backends: Record<string, gcp.compute.RegionNetworkEndpointGroup> = {};
    for (const [role, { service, },] of Object.entries(services,)) {
      backends[role] = new gcp.compute.RegionNetworkEndpointGroup(
        `${name}-${role}-neg`,
        {
          region,
          networkEndpointType: "SERVERLESS",
          cloudRun: { service: service.name, },
          project: args.project,
        },
        { parent: this, },
      );
    }

    // Backend services
    const backendServices: Record<string, gcp.compute.BackendService> = {};
    for (const [role, neg,] of Object.entries(backends,)) {
      backendServices[role] = new gcp.compute.BackendService(
        `${name}-${role}-backend`,
        {
          protocol: "HTTP",
          backends: [{ group: neg.id, },],
          project: args.project,
        },
        { parent: this, },
      );
    }

    // URL Map with host-based routing
    const urlMap = new gcp.compute.URLMap(
      `${name}-url-map`,
      {
        defaultService: backendServices["api"].id,
        hostRules: [
          {
            hosts: [`api${envPrefix}.${args.domain}`,],
            pathMatcher: "api",
          },
          {
            hosts: [`app${envPrefix}.${args.domain}`,],
            pathMatcher: "web",
          },
          {
            hosts: [`insights${envPrefix}.${args.domain}`,],
            pathMatcher: "insights",
          },
        ],
        pathMatchers: [
          {
            name: "api",
            defaultService: backendServices["api"].id,
          },
          {
            name: "web",
            defaultService: backendServices["web"].id,
          },
          {
            name: "insights",
            defaultService: backendServices["insights"].id,
          },
        ],
        project: args.project,
      },
      { parent: this, },
    );

    // Google-managed SSL certificate
    const sslCert = new gcp.compute.ManagedSslCertificate(
      `${name}-ssl-cert`,
      {
        managed: {
          domains: [
            `api${envPrefix}.${args.domain}`,
            `app${envPrefix}.${args.domain}`,
            `insights${envPrefix}.${args.domain}`,
          ],
        },
        project: args.project,
      },
      { parent: this, },
    );

    // Target HTTPS Proxy
    const httpsProxy = new gcp.compute.TargetHttpsProxy(
      `${name}-https-proxy`,
      {
        urlMap: urlMap.id,
        sslCertificates: [sslCert.id,],
        project: args.project,
      },
      { parent: this, },
    );

    // Global Forwarding Rule
    new gcp.compute.GlobalForwardingRule(
      `${name}-forwarding-rule`,
      {
        target: httpsProxy.id,
        ipAddress: globalIp.address,
        portRange: "443",
        project: args.project,
      },
      { parent: this, },
    );

    // HTTP → HTTPS redirect
    const httpUrlMap = new gcp.compute.URLMap(
      `${name}-http-redirect`,
      {
        defaultUrlRedirect: {
          httpsRedirect: true,
          stripQuery: false,
          redirectResponseCode: "MOVED_PERMANENTLY_DEFAULT",
        },
        project: args.project,
      },
      { parent: this, },
    );

    const httpProxy = new gcp.compute.TargetHttpProxy(
      `${name}-http-proxy`,
      {
        urlMap: httpUrlMap.id,
        project: args.project,
      },
      { parent: this, },
    );

    new gcp.compute.GlobalForwardingRule(
      `${name}-http-forwarding-rule`,
      {
        target: httpProxy.id,
        ipAddress: globalIp.address,
        portRange: "80",
        project: args.project,
      },
      { parent: this, },
    );

    this.apiUrl = pulumi.interpolate`https://api${envPrefix}.${args.domain}`;
    this.webUrl = pulumi.interpolate`https://app${envPrefix}.${args.domain}`;
    this.insightsUrl = pulumi.interpolate`https://insights${envPrefix}.${args.domain}`;

    this.registerOutputs({
      apiUrl: this.apiUrl,
      webUrl: this.webUrl,
      insightsUrl: this.insightsUrl,
      repositoryUrl: this.repositoryUrl,
      globalIpAddress: this.globalIpAddress,
    },);
  }
}
