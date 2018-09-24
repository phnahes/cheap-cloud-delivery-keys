# cheap-cloud-delivery-keys
Cheap cloud based delivery SSH keys (Lambda, S3, Ansible, Shell)

## LAMBDA

Create Lambda Function and import code in Lambda folder.

Allow access to Cloudwatch and S3.



## Schedulling

To scheduller, we will use CloudWatch Events:

Description: Create a Key Pair for the next month 
```cron(0 1 1 * ? *)```


## Security

In Local account, use to permit Ec2 Instances access S3 Bucket, using IAM policy bellow, attached on a IAM Role used on Ec2 instances:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<BUCKET_NAME>/*",
                "arn:aws:s3:::<BUCKET_NAME>/"
            ]
        }
    ]
}
```

In Cross Account access, use:

### Bucket Policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Example permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<AWS LOCAL ACCOUNT ID>:root"
            },
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::<BUCKET_NAME>",
                "arn:aws:s3:::<BUCKET_NAME>/*"
            ]
        }
    ]
}
```


### IAM Policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Example",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::<BUCKET_NAME>",
                "arn:aws:s3:::<BUCKET_NAME>/*"
            ]
        }
    ]
}
```

And Attach this IAM POlicy, on a IAM Role (used on Ec2 Instance)


### Attaching Policies


aws --profile <PROFILE> --region <REGION> iam attach-role-policy --policy-arn <ARN_POLICY> --role-name iam-role_name
