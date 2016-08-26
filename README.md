# freeswitch-config

Freeswitch config files for Chibi

TODO:

* Configure CORS
* Configure RTP Ports - https://freeswitch.org/confluence/display/FREESWITCH/NAT+Traversal

## Servers

### Production

freeswitch.chibitxt.me

### SysAdmin

#### Cron

##### Cleanup Logs

You'll need a cron job to clean up the logs otherwise you'll run out of diskspace.

Copy the [cron job](https://github.com/dwilkie/freeswitch-config/blob/master/cron/freeswitch) to `/etc/cron.daily` and set it's permissions to `755`

## Branches

### master

Contains the config files needed on the Production Server

### production_testing

Contains the config files needed for your development machine

### gsm_modem

Use this branch to use `mod_gsmopen` and `mod_sms` with a GSM modem

#### Installation

See also the the official instructions to compile and install [mod_gsmopen](https://freeswitch.org/confluence/display/FREESWITCH/mod_gsmopen).

The `mod_gsmopen` source can be found in the [repo](https://freeswitch.org/stash/projects/FS/repos/freeswitch/browse/src/mod/endpoints/mod_gsmopen). You'll also need to install `libfreeswitch` with `sudo apt-get install libfreeswitch` in order to compile it. Note there is no binary debian package for `mod_gsmopen`

##### Permissions

Add freeswitch to the dialout group

`sudo usermod -a -G dialout freeswitch`

##### Huawei USB Driver Installation

You might need to install the Huawei proprietary drivers. The following helped:

http://askubuntu.com/questions/323031/how-to-install-ndis-driver-for-huawei-mobile-broadband-devices

##### Usage

The default dialplan is set up to receive calls on 2909 and bridge to the `gsmopen_mt_number` in `secrets.xml`
The default chatplan is set up to receive SMS and reply to the sent number

## Installation

### Installing Freeswitch

Use the [pre-compiled Debian Package](https://freeswitch.org/confluence/display/FREESWITCH/Debian).

### Installing Required Modules

* mod_shout (required for mp3 playback)
  * `sudo apt-get install freeswitch-mod-shout`
* mod_http_cache (for caching mp3 playback)
  * `sudo apt-get install freeswitch-mod-http-cache`
* mod_rayo (Required for Adhearsion)
  * `sudo apt-get install freeswitch-mod-rayo`
* mod_xml_cdr (Required for posting CDR)
  * `sudo apt-get install freeswitch-mod-xml-cdr`

### Required Licences

mod_g729 requires one licence per channel. We have currently purchased 5 licences which should allow 5 simultanious calls using G.729.
Read the [G.729 codec guide](http://wiki.freeswitch.org/wiki/Mod_com_g729) for details on how to purchase additional licences. Note that each licence costs $10.

#### mod G729

##### Installation

Adapted from the [official installation instructions](http://files.freeswitch.org/g729/INSTALL)

1. cd /src
2. wget http://files.freeswitch.org/g729/fs-latest-installer
3. chmod u+x fs-latest-installer
4. sudo ./fs-latest-installer /usr/bin /usr/lib/freeswitch/mod /etc/freeswitch

### Configuration

#### Installing Configuration

```
cd ~
git clone git@github.com:dwilkie/freeswitch-config.git
git checkout <master_or_production_testing>
sudo cp -a freeswitch_config /etc/freeswitch
sudo chown -R freeswitch:daemon /etc/freeswitch
```

Don't forget to put the correct values in `/etc/freeswitch/secrets.xml`

#### Restart FreeSwitch

```
sudo service freeswitch restart
```

## Deployment

### Amazon AWS Elastic Beanstalk

#### Updating Configuration

1. ssh into the freeswitch application.

```
$ eb ssh
```

2. Download the configuration from the bucket.

```
$ aws s3 cp s3://${SECRETS_BUCKET_NAME}/freeswitch_secrets.xml .
```

3. Change the permissons of the downloaded secrets file

```
$ chmod 600 freeswitch_secrets.xml
```

4. Modify the secrets file

5. Reupload it to S3

```
$ aws s3 cp freeswitch_secrets.xml s3://SECRETS_BUCKET_NAME/freeswitch_secrets.xml --sse
```

6. Redeploy the application

```
$ eb deploy
```

#### FreeSwitch CLI

Follow the steps below to access the FS CLI

1. SSH into your instance using the Elastic Beanstalk console

```
$ eb ssh
```

2. Run the docker container which contains FreeSwitch

```
$ sudo docker run -i -t dwilkie/freeswitch-rayo /bin/bash
```

3. Run the `fs_cli` command specifying the host name of the container replacing `FREESWITCH_HOST` with the docker ip address of the container running freeswitch and `EVENT_SOCKET_PASSWORD` with the password specified in your secrets file.

```
$ fs_cli -H FREESWITCH_HOST -p EVENT_SOCKET_PASSWORD
```

#### Troubleshooting

If the app fails to deploy the following logs are useful:

* `/var/log/eb-ecs-mgr.log`
* `/var/log/eb-activity.log`

#### One-Time Setup

Create an Elastic Beanstalk application from the AWS web console under your existing VPC (or create a new one). This will give you a static IP address.

##### Handling Secrets

Adapted from https://blogs.aws.amazon.com/security/post/Tx2B3QUWAA7KOU/How-to-Manage-Secrets-for-Amazon-EC2-Container-Service-Based-Applications-by-Usi

1. Create a bucket in S3 using the AWS web console in which to store your secrets

2. Create a VPC Endpoint to S3 with the following command replacing `<your-aws-profile>` with your configured profile in `~/.aws/credentials`, `VPC_ID` and `ROUTE_TABLE_ID` with the values found in your VPC configuration via the AWS web console and `REGION` with the name of your region e.g. `ap-southeast-1`

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

3. Create a file called `policy.json` with the following contents replacing `SECRETS_BUCKET_NAME` with your the name of your new bucket and `VPC_ID` with the `VpcEndpointId` from the previous step.

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

4. Add the policy to the bucket using the following command replacing `SECRETS_BUCKET_NAME` with the name of your bucket.

```
$ aws s3api put-bucket-policy --profile <your-aws-profile> --bucket SECRETS_BUCKET_NAME --policy file:////home/user/path/to/policy.json
```

You can check that your policy was uploaded successfully with the following command.

```
$ aws s3api get-bucket-policy --profile pin --bucket SECRETS_BUCKET_NAME
```

5. Allow your Elastic Beanstalk Instances to access S3. Using the AWS web console, navigate to IAM roles and add a policy to the role `aws-elasticbeanstalk-ec2-role` to allow Amazon S3 Full Access.

6. Using the following command, upload `freeswitch_secrets.xml` to S3 from your EC2 Instance. You cannot do this from your development machine because we have already resticted access to the VPC.

```
$ aws s3 cp freeswitch_secrets.xml s3://SECRETS_BUCKET_NAME/freeswitch_secrets.xml --sse
```

## IP addresses

### Smart

#### Public MSC IP

```
27.109.112.80 (SIP)
27.109.112.84 (RTP)
27.109.112.0/24 (SMARTAXIATA)
```

### qb

#### Public MSC IP

```
117.55.252.146 (SIP & RTP)
117.55.252.0/24 (CADCOMMS)
```

### CooTel

#### Public MSC IP

```
103.5.126.165 (SIP & RTP)
103.5.126.0/24 (XINWEITELECOM-KH)
```

## Firewall

Open up the following ports:

    udp     16384:32768  (RTP)
    udp     5060         (SIP)
    tcp     5222         (XMPP / Adhearsion)

### Useful CLI Commands

### Reload SIP Profiles

```
sofia profile external [rescan|reload]
```
