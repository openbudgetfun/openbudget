import * as pulumi from "@pulumi/pulumi";
import { ServerpodAwsStack, } from "./src/aws";
import { getConfig, } from "./src/config";
import { ServerpodGcpStack, } from "./src/gcp";

const config = getConfig();

interface StackOutputs {
  apiUrl: pulumi.Output<string>;
  webUrl: pulumi.Output<string>;
  insightsUrl: pulumi.Output<string>;
  databaseHost: pulumi.Output<string>;
  registryUrl: pulumi.Output<string>;
}

let outputs: StackOutputs;

if (config.cloudProvider === "aws") {
  const stack = new ServerpodAwsStack("openbudget", config,);
  outputs = {
    apiUrl: stack.apiUrl,
    webUrl: stack.webUrl,
    insightsUrl: stack.insightsUrl,
    databaseHost: stack.databaseHost,
    registryUrl: stack.registryUrl,
  };
} else {
  const stack = new ServerpodGcpStack("openbudget", config,);
  outputs = {
    apiUrl: stack.apiUrl,
    webUrl: stack.webUrl,
    insightsUrl: stack.insightsUrl,
    databaseHost: stack.databaseHost,
    registryUrl: stack.registryUrl,
  };
}

export const apiUrl = outputs.apiUrl;
export const webUrl = outputs.webUrl;
export const insightsUrl = outputs.insightsUrl;
export const databaseHost = outputs.databaseHost;
export const registryUrl = outputs.registryUrl;
