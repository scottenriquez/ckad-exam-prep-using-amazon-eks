#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { ApiCdkStack } from '../lib/api-cdk-stack';

const app = new cdk.App();
new ApiCdkStack(app, 'ApiCdkStack', {});