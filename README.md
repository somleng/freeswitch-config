# freeswitch-config

Freeswitch configuration optimized for [mod_rayo](https://freeswitch.org/confluence/display/FREESWITCH/mod_rayo) and [Adhearsion](https://github.com/adhearsion/adhearsion).

## Deployment

### Elastic Beanstalk

This configuration is optimized for deployment on a Amazon Elastic Beanstalk multicontainer docker instance. To deploy this to your own AWS account create an Elastic Beanstalk application and follow the instructions below.

#### Create a VPC

Create a VPC with 2 public subnets (one for each availability zone)

#### Create a new Elastic Beanstalk Application

Create an Multi-Container Docker Elastic Beanstalk single instance application under your VPC. This will give you an Elastic IP address which won't change if you terminate or scale your instances. When prompted for the VPC details enter the VPC and subnets you created above. The following commands are useful.

```
$ eb platform select
$ eb create --vpc -i t2.micro --single
```

#### Configure IAM Permissions for aws-elasticbeanstalk-ec2-role

Add the following managed policies to the aws-elasticbeanstalk-ec2-role

* AWSElasticBeanstalkMulticontainerDocker

#### Configure a S3 bucket to any sensitive or custom configuration

Adapted from [this blog post](https://blogs.aws.amazon.com/security/post/Tx2B3QUWAA7KOU/How-to-Manage-Secrets-for-Amazon-EC2-Container-Service-Based-Applications-by-Usi)

Sensitive freeswitch configuration can be stored on S3. When the docker container runs the [docker-entrypoint.sh](https://github.com/dwilkie/freeswitch-config/blob/master/docker-entrypoint.sh) it downloads the configuration before starting freeswitch.

In order for this to work you need to set up an S3 bucket in your AWS account in which to store the configuration and restrict the access to the VPC.

First, create a bucket in S3 using the AWS web console in which to store your configuration.

Next, create a VPC Endpoint to S3. Use the following command following command replacing `<your-aws-profile>` with your configured profile in `~/.aws/credentials`, `VPC_ID` and `ROUTE_TABLE_ID` with the values found in your VPC configuration via the AWS web console and `REGION` with the name of your region e.g. `ap-southeast-1`

```
$ aws ec2 --profile <your-aws-profile> create-vpc-endpoint --vpc-id VPC_ID --route-table-ids ROUTE_TABLE_ID --service-name com.amazonaws.REGION.s3 --region REGION
```

You should see the output similar to the following:

```json
{
  "VpcEndpoint": {
  "PolicyDocument": "{\"Version\":\"2008-10-17\",\"Statement\":[{\"Sid\":\"\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":
\"*\",\"Resource\":\"*\"}]}",
  "VpcId": "vpc-1a2b3c4d",
  "State": "available",
  "ServiceName": "com.amazonaws.us-east-1.s3",
  "RouteTableIds": [
    "rtb-11aa22bb"
  ],
  "VpcEndpointId": "vpce-3ecf2a57",
  "CreationTimestamp": "2016-05-15T09:40:50Z"
  }
}
```

Take note of the `VpcEndpointId` which is required for the next step.

Next, create a file called `policy.json` with the following contents replacing `SECRETS_BUCKET_NAME` with your the name of your new bucket and `VPC_ID` with the `VpcEndpointId` from the previous step.

This policy prevents unencrypted uploads and restricts access to the bucket to the VPC.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::SECRETS_BUCKET_NAME/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": " DenyUnEncryptedInflightOperations",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::SECRETS_BUCKET_NAME/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": false
        }
      }
    },
    {
      "Sid": "Access-to-specific-VPCE-only",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [ "s3:GetObject", "s3:PutObject", "s3:DeleteObject" ],
      "Resource": "arn:aws:s3:::SECRETS_BUCKET_NAME/*",
      "Condition": {
        "StringNotEquals": {
          "aws:sourceVpce": "VPC_ID"
        }
      }
    }
  ]
}
```

Next, add the policy to the bucket. Use the following command replacing `SECRETS_BUCKET_NAME` with the name of your bucket.

```
$ aws s3api put-bucket-policy --profile <your-aws-profile> --bucket SECRETS_BUCKET_NAME --policy file:////home/user/path/to/policy.json
```

You can check that your policy was uploaded successfully with the following command.

```
$ aws s3api get-bucket-policy --profile <your-aws-profile> --bucket SECRETS_BUCKET_NAME
```

Next, allow your Elastic Beanstalk Instances to access S3. Using the AWS web console, navigate to IAM roles and add a policy to the role `aws-elasticbeanstalk-ec2-role` to allow Amazon S3 Full Access.

Finally, upload your sensitive configuration to S3 from your EC2 Instance. Note you cannot do this from your development machine because we have already resticted access to the VPC.

```
$ aws s3 cp --recursive freeswitch_conf_dir s3://SECRETS_BUCKET_NAME/FREESWITCH_CONF_DIR --sse
```

When updating configuration, download your custom configuration from S3, update it, reupload it to S3 and re-deploy the application. The following commands are useful:

```
$ aws s3 cp --recursive s3://SECRETS_BUCKET_NAME/FREESWITCH_CONF_DIR freeswitch_conf
$ aws s3 cp --recursive freeswitch_conf_dir s3://SECRETS_BUCKET_NAME/FREESWITCH_CONF_DIR --sse
```

#### Dockerrun.aws.json

[Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json) contains the container configuration for FreeSwitch. It's options are passed to the `docker run` command.

##### Memory

You must specify the memory option in this file. To set it to the maximum value possible, first set it to a number exceeding the memory of the host instance. Then grep the logs in `/var/log/eb-ecs-mgr.log` and look for `remainingResources`. Look for the `MEMORY` value and use this in your `Dockerrun.aws.json` file.

##### RTP and SIP Port Mappings

There [used to be a script](https://github.com/dwilkie/freeswitch-config/commit/c5d3ab0545ff729e44f84a2336a432a602e1ee9f) which added RTP port mappings to `Dockerrun.aws.json`. However there is a [limitation](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html) on AWS which limits a container instance to 100 reserved ports at a time.

More importantly though, I found that mapping RTP and SIP ports to the host is not required. I couldn't figure out exactly why but my guess is that the FreeSwitch external profile is configured to handle NAT correctly. So it rewrites the SIP packets to handle the NAT using `ext-rtp-ip` and `ext-sip-ip`. What I still don't understand is how the host knows how to send the packets to the container running FreeSwitch. If someone has a better explanation please open a Pull Request.

##### logConfiguration

The `awslogs` log driver should be used instead of the default `json` log driver so that you don't run out of disk space. This can be setup via the `logConfiguration` option. I followed [this guide](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html).

The important steps are, creating the log group in the CloudWatch console and adding the managed policy `AmazonEC2ContainerServiceforEC2Role` to the `aws-elasticbeanstalk-ec2-role` (or the role you use for your Elastic Beanstalk instances). Make sure that the log group has the same name that you set in your [Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json)

You can check that the logging is setup correctly by inspecting the output of `sudo docker inspect <instance> | grep -C 10 LogConfig`.

#### Inpecting Docker Containers using the AWS ECS Console

Under Services->EC2 Container Service, you will see an overview of the clusters. Click on one of the clusters, then on the Tasks tab shows the running tasks. Click on a task to, then under Containers expand the container that you want to inspect. Here you should see Network bindings, Environment Variables, Mount Points and Log Configuration.

#### Security Groups and Networking

[Dockerrun.aws.json](https://github.com/dwilkie/freeswitch-config/blob/master/Dockerrun.aws.json) defines a list of port mappings which map the host to the docker container. Not all of these ports need to be opened in your security group. For example port 8021 is used for `mod_event_socket` but this port should not be opened on in your security group. Depending on your application you may need to open the following ports in your security group:

    udp     16384:32768  (RTP)
    udp     5060         (SIP)
    tcp     5222         (XMPP / Adhearsion)

It's highly recommended that you restrict the source of the ports in your security group. For example for SIP and RTP traffic restric the ports to the known SIP provider / telco. For XMPP / Adhearsion you can restrict the port to instances inside the your VPC.

#### FreeSwitch CLI

In order to access the FreeSwitch CLI ssh into your instance, run the docker container which contains FreeSwitch in interactive mode with `/bin/bash`, then from within the container, run the `fs_cli` command specifying the host and password parameters. The host can be found by inspecting the running freeswitch instance's container.

The following commands are useful.

```
$ sudo docker ps
$ sudo docker inspect <process_id>
$ sudo docker run -i -t dwilkie/freeswitch-rayo /bin/bash
$ fs_cli -H FREESWITCH_HOST -p EVENT_SOCKET_PASSWORD
```

##### Useful CLI Commands

###### Reload SIP Profiles

```
sofia profile external [rescan|reload]
```

###### Turn on siptrace

```
sofia global siptrace on
```

###### Freeswitch control messages

####### View max sessions

```
fsctl max_sessions
```

####### Set max sessions

```
fsctl max_sessions 1000
```

####### Set max sessions-per-second

```
fsctl sps 200
```

#### Troubleshooting

If the app fails to deploy the following logs are useful:

* `/var/log/eb-ecs-mgr.log`
* `/var/log/eb-activity.log`

##### Testing Mobile Originated (MO) Calls

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

## Load Testing

### SIPp

First install SIPp

```
$ git clone git@github.com:SIPp/sipp.git
$ cd sipp
$ sudo apt-get install libpcap-dev libsctp-dev libgsl-dev
$ ./build.sh
$ sudo make install
```

### sippy_cup

```
$ cd test
$ bundle install --path vendor
```
