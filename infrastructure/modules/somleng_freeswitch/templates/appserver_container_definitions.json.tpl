[
  {
    "name": "${container_name}",
    "image": "${app_image}:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
       "options": {
         "awslogs-group": "${app_logs_group}",
         "awslogs-region": "${logs_group_region}",
         "awslogs-stream-prefix": "${app_environment}"
       }
    },
    "startTimeout": 120,
    "essential": true,
    "secrets": [
      {
        "name": "FS_DATABASE_PASSWORD",
        "valueFrom": "${database_password_parameter_arn}"
      },
      {
        "name": "FS_MOD_RAYO_PASSWORD",
        "valueFrom": "${rayo_password_parameter_arn}"
      },
      {
        "name": "FS_MOD_JSON_CDR_PASSWORD",
        "valueFrom": "${json_cdr_password_parameter_arn}"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${rayo_port},
        "protocol": "tcp"
      },
      {
        "containerPort": ${sip_port},
        "protocol": "udp"
      }
    ],
    "environment": [
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${region}"
      },
      {
        "name": "FS_DATABASE_NAME",
        "value": "${database_name}"
      },
      {
        "name": "FS_DATABASE_USERNAME",
        "value": "${database_username}"
      },
      {
        "name": "FS_DATABASE_HOST",
        "value": "${database_host}"
      },
      {
        "name": "FS_DATABASE_PORT",
        "value": "${database_port}"
      },
      {
        "name": "FS_EXTERNAL_SIP_IP",
        "value": "${external_sip_ip}"
      },
      {
        "name": "FS_EXTERNAL_RTP_IP",
        "value": "${external_rtp_ip}"
      },
      {
        "name": "FS_MOD_RAYO_PORT",
        "value": "${rayo_port}"
      },
      {
        "name": "FS_MOD_RAYO_HOST",
        "value": "${rayo_host}"
      },
      {
        "name": "FS_MOD_RAYO_USER",
        "value": "${rayo_user}"
      },
      {
        "name": "FS_MOD_JSON_CDR_URL",
        "value": "${json_cdr_url}"
      }
    ]
  }
]
