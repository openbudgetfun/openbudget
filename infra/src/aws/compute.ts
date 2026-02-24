import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
import * as pulumi from "@pulumi/pulumi";
import { AwsNetworking, } from "./networking";

export interface AwsComputeArgs {
  environment: string;
  domain: string;
  networking: AwsNetworking;
  certificateArn: pulumi.Output<string>;
  cpu: number;
  memory: number;
  dbPassword: pulumi.Output<string>;
  serviceSecret: pulumi.Output<string>;
  redisEnabled: boolean;
  redisPassword?: pulumi.Output<string>;
}

export class AwsCompute extends pulumi.ComponentResource {
  public readonly apiUrl: pulumi.Output<string>;
  public readonly webUrl: pulumi.Output<string>;
  public readonly insightsUrl: pulumi.Output<string>;
  public readonly repositoryUrl: pulumi.Output<string>;
  public readonly albDnsName: pulumi.Output<string>;
  public readonly albZoneId: pulumi.Output<string>;

  constructor(
    name: string,
    args: AwsComputeArgs,
    opts?: pulumi.ComponentResourceOptions,
  ) {
    super("openbudget:aws:Compute", name, args, opts,);

    const envPrefix = args.environment === "staging" ? "-staging" : "";

    // ECR Repository
    const repo = new awsx.ecr.Repository(
      `${name}-repo`,
      {
        forceDelete: args.environment === "staging",
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );
    this.repositoryUrl = repo.url;

    // ECS Cluster
    const cluster = new aws.ecs.Cluster(
      `${name}-cluster`,
      {
        settings: [{ name: "containerInsights", value: "enabled", },],
        tags: { Name: `${name}-cluster`, Environment: args.environment, },
      },
      { parent: this, },
    );

    // Application Load Balancer
    const alb = new aws.lb.LoadBalancer(
      `${name}-alb`,
      {
        loadBalancerType: "application",
        securityGroups: [args.networking.albSecurityGroup.id,],
        subnets: args.networking.vpc.publicSubnetIds,
        tags: { Name: `${name}-alb`, Environment: args.environment, },
      },
      { parent: this, },
    );
    this.albDnsName = alb.dnsName;
    this.albZoneId = alb.zoneId;

    // Target Groups
    const apiTg = new aws.lb.TargetGroup(
      `${name}-api-tg`,
      {
        port: 8080,
        protocol: "HTTP",
        targetType: "ip",
        vpcId: args.networking.vpc.vpcId,
        healthCheck: {
          path: "/",
          port: "8080",
          healthyThreshold: 2,
          unhealthyThreshold: 3,
          interval: 30,
        },
        tags: { Name: `${name}-api-tg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    const insightsTg = new aws.lb.TargetGroup(
      `${name}-insights-tg`,
      {
        port: 8081,
        protocol: "HTTP",
        targetType: "ip",
        vpcId: args.networking.vpc.vpcId,
        healthCheck: {
          path: "/",
          port: "8081",
          healthyThreshold: 2,
          unhealthyThreshold: 3,
          interval: 30,
        },
        tags: { Name: `${name}-insights-tg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    const webTg = new aws.lb.TargetGroup(
      `${name}-web-tg`,
      {
        port: 8082,
        protocol: "HTTP",
        targetType: "ip",
        vpcId: args.networking.vpc.vpcId,
        healthCheck: {
          path: "/",
          port: "8082",
          healthyThreshold: 2,
          unhealthyThreshold: 3,
          interval: 30,
        },
        tags: { Name: `${name}-web-tg`, Environment: args.environment, },
      },
      { parent: this, },
    );

    // HTTPS Listener with default action to API
    const httpsListener = new aws.lb.Listener(
      `${name}-https`,
      {
        loadBalancerArn: alb.arn,
        port: 443,
        protocol: "HTTPS",
        certificateArn: args.certificateArn,
        defaultActions: [
          { type: "forward", targetGroupArn: apiTg.arn, },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // HTTP → HTTPS redirect
    new aws.lb.Listener(
      `${name}-http-redirect`,
      {
        loadBalancerArn: alb.arn,
        port: 80,
        protocol: "HTTP",
        defaultActions: [
          {
            type: "redirect",
            redirect: {
              port: "443",
              protocol: "HTTPS",
              statusCode: "HTTP_301",
            },
          },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // Host-based routing
    new aws.lb.ListenerRule(
      `${name}-insights-rule`,
      {
        listenerArn: httpsListener.arn,
        priority: 10,
        actions: [{ type: "forward", targetGroupArn: insightsTg.arn, },],
        conditions: [
          {
            hostHeader: {
              values: [`insights${envPrefix}.${args.domain}`,],
            },
          },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    new aws.lb.ListenerRule(
      `${name}-web-rule`,
      {
        listenerArn: httpsListener.arn,
        priority: 20,
        actions: [{ type: "forward", targetGroupArn: webTg.arn, },],
        conditions: [
          {
            hostHeader: {
              values: [`app${envPrefix}.${args.domain}`,],
            },
          },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // Secrets Manager for passwords.yaml secrets
    const dbPasswordSecret = new aws.secretsmanager.Secret(
      `${name}-db-password`,
      { tags: { Environment: args.environment, }, },
      { parent: this, },
    );
    new aws.secretsmanager.SecretVersion(
      `${name}-db-password-ver`,
      { secretId: dbPasswordSecret.id, secretString: args.dbPassword, },
      { parent: this, },
    );

    const svcSecret = new aws.secretsmanager.Secret(
      `${name}-service-secret`,
      { tags: { Environment: args.environment, }, },
      { parent: this, },
    );
    new aws.secretsmanager.SecretVersion(
      `${name}-service-secret-ver`,
      { secretId: svcSecret.id, secretString: args.serviceSecret, },
      { parent: this, },
    );

    // IAM Execution Role
    const executionRole = new aws.iam.Role(
      `${name}-exec-role`,
      {
        assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({
          Service: "ecs-tasks.amazonaws.com",
        },),
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    new aws.iam.RolePolicyAttachment(
      `${name}-exec-policy`,
      {
        role: executionRole.name,
        policyArn: "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
      },
      { parent: this, },
    );

    new aws.iam.RolePolicy(
      `${name}-secrets-policy`,
      {
        role: executionRole.id,
        policy: pulumi
          .all([dbPasswordSecret.arn, svcSecret.arn,],)
          .apply(([dbArn, svcArn,],) =>
            JSON.stringify({
              Version: "2012-10-17",
              Statement: [
                {
                  Effect: "Allow",
                  Action: ["secretsmanager:GetSecretValue",],
                  Resource: [dbArn, svcArn,],
                },
              ],
            },)
          ),
      },
      { parent: this, },
    );

    // IAM Task Role
    const taskRole = new aws.iam.Role(
      `${name}-task-role`,
      {
        assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({
          Service: "ecs-tasks.amazonaws.com",
        },),
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // CloudWatch Log Group
    const logGroup = new aws.cloudwatch.LogGroup(
      `${name}-logs`,
      {
        name: `/ecs/${name}`,
        retentionInDays: args.environment === "production" ? 30 : 7,
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // ECS Task Definition
    const region = aws.getRegionOutput();
    const taskDef = new aws.ecs.TaskDefinition(
      `${name}-task`,
      {
        family: name,
        networkMode: "awsvpc",
        requiresCompatibilities: ["FARGATE",],
        cpu: String(args.cpu,),
        memory: String(args.memory,),
        executionRoleArn: executionRole.arn,
        taskRoleArn: taskRole.arn,
        containerDefinitions: pulumi
          .all([repo.url, logGroup.name, region.name,],)
          .apply(([image, logGroupName, regionName,],) =>
            JSON.stringify([
              {
                name: "serverpod",
                image: `${image}:latest`,
                essential: true,
                portMappings: [
                  { containerPort: 8080, protocol: "tcp", },
                  { containerPort: 8081, protocol: "tcp", },
                  { containerPort: 8082, protocol: "tcp", },
                ],
                environment: [
                  { name: "runmode", value: args.environment, },
                  { name: "serverid", value: "default", },
                  { name: "logging", value: "normal", },
                  { name: "role", value: "monolith", },
                ],
                secrets: [
                  {
                    name: "SERVERPOD_DATABASE_PASSWORD",
                    valueFrom: dbPasswordSecret.arn,
                  },
                  {
                    name: "SERVERPOD_SERVICE_SECRET",
                    valueFrom: svcSecret.arn,
                  },
                ],
                logConfiguration: {
                  logDriver: "awslogs",
                  options: {
                    "awslogs-group": logGroupName,
                    "awslogs-region": regionName,
                    "awslogs-stream-prefix": "serverpod",
                  },
                },
              },
            ],)
          ),
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // ECS Service
    new aws.ecs.Service(
      `${name}-service`,
      {
        cluster: cluster.arn,
        taskDefinition: taskDef.arn,
        desiredCount: args.environment === "production" ? 2 : 1,
        launchType: "FARGATE",
        networkConfiguration: {
          subnets: args.networking.vpc.privateSubnetIds,
          securityGroups: [args.networking.appSecurityGroup.id,],
          assignPublicIp: false,
        },
        loadBalancers: [
          {
            targetGroupArn: apiTg.arn,
            containerName: "serverpod",
            containerPort: 8080,
          },
          {
            targetGroupArn: insightsTg.arn,
            containerName: "serverpod",
            containerPort: 8081,
          },
          {
            targetGroupArn: webTg.arn,
            containerName: "serverpod",
            containerPort: 8082,
          },
        ],
        tags: { Environment: args.environment, },
      },
      { parent: this, },
    );

    // Auto-scaling
    const scalingTarget = new aws.appautoscaling.Target(
      `${name}-scaling-target`,
      {
        maxCapacity: args.environment === "production" ? 10 : 3,
        minCapacity: args.environment === "production" ? 2 : 1,
        resourceId: pulumi.interpolate`service/${cluster.name}/${name}-service`,
        scalableDimension: "ecs:service:DesiredCount",
        serviceNamespace: "ecs",
      },
      { parent: this, },
    );

    new aws.appautoscaling.Policy(
      `${name}-cpu-scaling`,
      {
        policyType: "TargetTrackingScaling",
        resourceId: scalingTarget.resourceId,
        scalableDimension: scalingTarget.scalableDimension,
        serviceNamespace: scalingTarget.serviceNamespace,
        targetTrackingScalingPolicyConfiguration: {
          predefinedMetricSpecification: {
            predefinedMetricType: "ECSServiceAverageCPUUtilization",
          },
          targetValue: 70,
        },
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
    },);
  }
}
