import { Construct } from 'constructs';
import { App, Chart, ChartProps } from 'cdk8s';
import { KubeDeployment } from './imports/k8s';

export class MyChart extends Chart {
  constructor(scope: Construct, id: string, props: ChartProps = { }) {
    super(scope, id, props);
    new KubeDeployment(this, 'my-deployment', {
      spec: {
        replicas: 3,
        selector: { matchLabels: { app: 'frontend' } },
        template: {
          metadata: { labels: { app: 'frontend'} },
          spec: {
            containers: [
              {
                name: 'app-container',
                image: 'nginx:latest',
                ports: [{ containerPort: 80 }]
              }
            ]
          }
        }
      }
    });
  }
}

const app = new App();
new MyChart(app, 'cluster');
app.synth();