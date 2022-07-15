# Process

## Create EC2 Instance

```shell
sh shell-commands/setup-prom-ec2.sh
```

```shell
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
```

```shell
sh ec2-instances.sh filters.json
```

## Terminal A: SSH into EC2 Instance

```shell
chmod 400 path_to_pem_file
```

```shell
ssh -i path_to_pem_file ubuntu@replace_this_with_prom_ec2_public_dns_name
```

## Terminal A: Download Promethues into Instance

```shell
wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
```

```shell
tar xvfz prometheus-2.19.0.linux-amd64.tar.gz
```

## Terminal A: Verify installation

```shell
cd prometheus-2.19.0.linux-amd64
```

```shell
./prometheus --version
```

## Terminal A: Download & Verify Node Exporter

```shell
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

```

```shell
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
```

```shell
cd node_exporter-1.0.1.linux-amd64
```

```shell
./node_exporter
```

## Terminal B: Configure Node Exporter (from different terminal)

```shell
ssh -i ~/.ssh/udacity-prometheus.pem ubuntu@replace_this_with_public_dns_name
```

```shell
cd prometheus-2.19.0.linux-amd64
```

```shell
nano prometheus.yml
```

### Setup Automatic Discovery

```yml
  - job_name: 'node'
    ec2_sd_configs:
      - region: us-west-2
        access_key: replace_with_aws_IAM_access_key
        secret_key: replace_with_aws_IAM_secret_key+XJqTnNHAh2b
        port: 9100
```

Save file

- Ctrl + X
- y
- Enter

## Terminal A: Configure Alert Manager

```shell
nano rules.yml
```

Input

```yml
groups:
  - name: AllInstances
    rules:
    - alert: UsingTooMuchMemory
# Condition for alerting
      expr: node_memory_MemFree_bytes < 1000000
      for: 1m
# Annotation - additional informational labels to store more information
      annotations:
        title: 'Instances {{ $labels.instance }} is almost out of memory'
        description: '{{ $labels.instance }}' of job {{ $labels.job }} has been down for >
# Labels - additinoal labels to be attached to the alert
      labels:
        severity: 'critical'
```

Save file

- Ctrl + X
- Y
- Enter

```shell
nano prometheus.yml
```

Add in rule_files section

```yml
rule_files:
# add this
  - "rules.yml"
```

Save file

- Ctrl + X
- Y
- Enter

## Terminal B: Install Alert Manager 

```shell
ssh -i ~/.ssh/udacity-prometheus.pem ubuntu@replace_this_with_public_dns_name
```

```shell
mdir alertmanager
cd alertmanager
```

```shell
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

tar xvfz alertmanager-0.21.0.linux-amd64.tar.gz
```

## Terminal A: Configure Alert Manager Changes 

```shell
nano prometheus.yml
```

Under altering change  ```# - alertmanager:9093``` to ```- localhost:9093```

## Terminal B: Alert Manager with slack

```shell
nano alertmanager.yml
```

Delete everything in file

Add

```yml
global:
  resolve_timeout: 1m
  stack_api_url: "https://hooks.slack.com/services/TSUJTM1HQ/BT7JT5RFS/5eZMpbDkK8wkk2V"

route:
  receiver: "slack-notifications"

receivers:
  - name: "slack-notifications"
    slack_configs:
      - channel: "#monitoring-instances"
        send_resolved: true
    # Custom Alert
    icon_url: https://avatars3.githubusercontent.com/u/3380462
    title: |-
     [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
     {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
       {{" "}}(
       {{- with .CommonLabels.Remove .GroupLabels.Names }}
         {{- range $index, $label := .SortedPairs -}}
           {{ if $index }}, {{ end }}
           {{- $label.Name }}="{{ $label.Value -}}"
         {{- end }}
       {{- end -}}
       )
     {{- end }}
    text: >-
     Udacity Project 3 Customer Alert Messages (udapeople)
     {{ range .Alerts -}}
     *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}

     *Description:* {{ .Annotations.description }}

     *Details:*
       {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
       {{ end }}
```

Save file

- Ctrl + X
- Y
- Enter

## Terminal A: Start Prometheus

```shell
./prometheus --config.file=./prometheus.yml
```

replace_this_with_public_dns_name:9093
## Terminal B: Start Alert Manager

```shell
./alertmanager --config.file=alertmanager.yml
```

replace_this_with_public_dns_name:9093

Not seeing anything because unlikely errors such as low memory


## Exit

Ctrl+C

or

```shell
exit
```

## Intentional Error To Test Alerts

Set up an alert for low memory, or instance down, or any other condition you can control to intentionally cause an alert.

### Instance Down

Stop the instance

### Low Memory

Resize EC2 instance

## Further guides

- [Set up Prometheus Server on EC2: Install Prometheus on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part1/)
- [Configure Prometheus for AWS Service Discovery: Prometheus Service Discovery on AWS EC2](https://codewizardly.com/prometheus-on-aws-ec2-part3/)
- [Prometheus Alertmanager Sending Emails](https://codewizardly.com/prometheus-on-aws-ec2-part4/)
- [Step-by-step guide to setting up Prometheus Alertmanager with Slack, PagerDuty, and Gmail](https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/)
- [Notification Template Examples](https://prometheus.io/docs/alerting/latest/notification_examples/)

Lessons/Exercises:
- CC6-L5-C6-Prometheus
- CC6-L5-C10-Exporters
- CC6-L5-C15-Sending-Alert-Messages