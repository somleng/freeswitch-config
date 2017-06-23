# Deployment

## Elastic Beanstalk

This configuration is optimized for deployment on a Amazon Elastic Beanstalk multicontainer docker instance. To deploy this to your own AWS account create an Elastic Beanstalk application and follow the instructions below.

### Create a VPC

Create a VPC with 2 public subnets (one for each availability zone). See [this article](https://github.com/dwilkie/twilreapi/blob/master/docs/AWS_VPC_SETUP.md) for detailed instructions.

### Configure Dynamic DNS (DDNS)

In order to address to your FreeSWITCH instance by a static host name from within your VPC your can setup a Dynamic DNS (DDNS). By using a DDNS you can enable managed updates on your FreeSWITCH instance without worrying about updating the host name on other resources that address FreeSWITCH within your VPC.

Follow [this guide](https://github.com/dwilkie/freeswitch-config/tree/master/docs/DDNS_CONFIGURATION.md) to setup a DDNS.

### Create a new Elastic Beanstalk Application

Create an Multi-Container Docker Elastic Beanstalk single instance application under your VPC. This will give you an Elastic IP address which won't change if you terminate or scale your instances. When prompted for the VPC details enter the VPC and subnets you created above. The following commands are useful.

```
$ eb init --profile <profile-name>
$ eb platform select --profile <profile-name>
$ eb create --vpc -i t2.micro --single --tags ZONE=<private-hosted-zone-with-trailing-dot>,CNAME=<subdomain-in-private-hosted-zone-with-trailing-dot> --profile <profile-name>
```

Note that tags can only be set when creating the Elastic Beanstalk Application, so ensure that your `ZONE` and `CNAME` are correct.

### Configure IAM Permissions for aws-elasticbeanstalk-ec2-role

Add the following managed policies to the `aws-elasticbeanstalk-ec2-role`:

* AWSElasticBeanstalkMulticontainerDocker
* AWSElasticBeanstalkWebTier

Add the following custom IAM policy to the `aws-elasticbeanstalk-ec2-role`:

* CloudWatchPutMetrics

  ```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": [
                  "cloudwatch:PutMetricData",
                  "ec2:DescribeTags"
              ],
              "Effect": "Allow",
              "Resource": [
                  "*"
              ]
          }
      ]
  }
  ```

### Cron

Cron jobs are configured in the [.ebextensions](https://github.com/dwilkie/freeswitch-config/tree/master/.ebextensions) folder.

#### CloudWatch Metrics

This job puts custom metrics such as disk space utilization and memory used. See [cloudwatch.config](https://github.com/dwilkie/freeswitch-config/blob/master/.ebextensions/cloudwatch.config) for more info.

#### Retrying CDRs

Depending on the configuration specified in [json_cdr.conf.xml](https://github.com/dwilkie/freeswitch-config/blob/master/conf/autoload_configs/json_cdr.conf.xml) CDRs which fail to log via HTTP(S) will be stored in the log directory which can fill up disk space. The [retry_cdr.sh](https://github.com/dwilkie/freeswitch-config/blob/master/.ebextensions/retry_cdr.sh) script will retry logging these CDRs these CDRs via HTTP(S) and delete them from the log directory.

### Configure a S3 bucket to sensitive or custom configuration

Follow [this guide](https://github.com/dwilkie/freeswitch-config/tree/master/docs/S3_CONFIGURATION.md) to securely store your configuration on S3.

### Dockerrun.aws.json

[Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json) contains the container configuration for FreeSwitch. It's options are passed to the `docker run` command.

#### Memory

You must specify the memory option in this file. To set it to the maximum value possible, first set it to a number exceeding the memory of the host instance. Then grep the logs in `/var/log/eb-ecs-mgr.log` and look for `remainingResources`. Look for the `MEMORY` value and use this in your `Dockerrun.aws.json` file.

#### RTP and SIP Port Mappings

There [used to be a script](https://github.com/dwilkie/freeswitch-config/commit/c5d3ab0545ff729e44f84a2336a432a602e1ee9f) which added RTP port mappings to `Dockerrun.aws.json`. However there is a [limitation](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html) on AWS which limits a container instance to 100 reserved ports at a time.

More importantly though, I found that mapping RTP and SIP ports to the host is not required. I couldn't figure out exactly why but my guess is that the FreeSwitch external profile is configured to handle NAT correctly. So it rewrites the SIP packets to handle the NAT using `ext-rtp-ip` and `ext-sip-ip`. What I still don't understand is how the host knows how to send the packets to the container running FreeSwitch. If someone has a better explanation please open a Pull Request.

#### logConfiguration

The `awslogs` log driver should be used instead of the default `json` log driver so that you don't run out of disk space. This can be setup via the `logConfiguration` option. I followed [this guide](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html).

The important steps are, creating the log group in the CloudWatch console and adding the managed policy `AmazonEC2ContainerServiceforEC2Role` to the `aws-elasticbeanstalk-ec2-role` (or the role you use for your Elastic Beanstalk instances). Make sure that the log group has the same name that you set in your [Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json)

You can check that the logging is setup correctly by inspecting the output of `sudo docker inspect <instance> | grep -C 10 LogConfig`.

### Inpecting Docker Containers using the AWS ECS Console

Under Services->EC2 Container Service, you will see an overview of the clusters. Click on one of the clusters, then on the Tasks tab shows the running tasks. Click on a task to, then under Containers expand the container that you want to inspect. Here you should see Network bindings, Environment Variables, Mount Points and Log Configuration.

### Security Groups and Networking

[Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json) defines a list of port mappings which map the host to the docker container. Depending on your application you may need to open the following ports in your security group:

    udp     16384:32768  (RTP)
    udp     5060         (SIP)
    tcp     5222         (XMPP)

It's highly recommended that you restrict the source of the ports in your security group. For SIP and RTP traffic restrict the ports to your SIP provider / MNO.

For XMPP you can restrict the access to specific instances inside the your VPC. Find the id of the security group of the instance that you want to connect from. Then in your security group rules set the source to the security group of the connecting instance.

To test connections you can use the `nc` command from the connecting instnace. E.g.

```
nc -z <internal-freeswitch-hostname> <port-number>
```

### CI Deployment

See [CI DEPLOYMENT](https://github.com/dwilkie/twilreapi/blob/master/docs/CI_DEPLOYMENT.md)

### Restarting Instances

If you run into problems you can terminate your FreeSWITCH instance using the EC2 Web Console. Be sure *not* to release the Elastic IP. A new instance will be deployed and the Elastic IP should remain the same.

### FreeSwitch CLI

In order to access the FreeSwitch CLI ssh into your instance, run the docker container which contains FreeSwitch in interactive mode with `/bin/bash`, then from within the container, run the `fs_cli` command specifying the host and password parameters. The host can be found by inspecting the running freeswitch instance's container.

The following commands are useful.

```
$ sudo docker ps
$ sudo docker inspect <process_id>
$ sudo docker run -i -t dwilkie/freeswitch-rayo /bin/bash
$ fs_cli -H FREESWITCH_HOST -p EVENT_SOCKET_PASSWORD
```

#### Useful CLI Commands

##### Reload SIP Profiles

```
sofia profile external [rescan|reload]
```

##### Turn on siptrace

```
sofia global siptrace on
```

##### View max sessions

```
fsctl max_sessions
```

##### Set max sessions

```
fsctl max_sessions 1000
```

##### Set max sessions-per-second

```
fsctl sps 200
```

#### Troubleshooting

If the app fails to deploy the following logs are useful:

* `/var/log/eb-ecs-mgr.log`
* `/var/log/eb-activity.log`

#### Testing Mobile Originated (MO) Calls

1. Configure a local instance of FreeSwitch
2. Configure a dialplan that will bridge a call to your local FreeSwitch to the remote destination. e.g.

  ```xml
  <include>
    <context name="default">
      <extension name="SimulateProductionCall">
        <condition field="destination_number" expression="^$${remote_destination}$">
          <action application="bridge" data="sofia/external/$${remote_destination}@$${remote_external_ip}"/>
        </condition>
      </extension>
    </context>
  </include>
  ```

3. Open up the relevant ports in the FreeSwitch security group. e.g. `udp/5060` and `udp/16384-32768` allowing your local IP.
4. Using a softphone such as [Zoiper](http://www.zoiper.com/), configure it to connect to your local FreeSwitch instance. Set the IP address to your local IP.
5. Dial the destination number using your softphone.

