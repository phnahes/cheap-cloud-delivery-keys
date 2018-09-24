from __future__ import print_function
from Crypto.PublicKey import RSA

import boto3
import datetime
import calendar
import re


def add_months(sourcedate,months):
    month = sourcedate.month - 1 + months
    year = sourcedate.year + month // 12
    month = month % 12 + 1
    day = min(sourcedate.day,calendar.monthrange(year,month)[1])
    
    #return datetime.date(year,month,day)
    date_string = str(year) + "/" + str(month) + "/"
    return date_string

def lambda_handler(event, context):

    month_now = datetime.date.today()
    date_dir = add_months(month_now,1)
    

    key = RSA.generate(2048)
    pubkey = key.publickey()
    #private = key.exportKey(passphrase=code, pkcs=8)
    private = key.exportKey('PEM')
    public = pubkey.exportKey('OpenSSH')
    
    
    # S3
    private_encoded_string = private.encode("utf-8")
    public_encoded_string = public.encode("utf-8")

    bucket_name = "key-mgmt"

    priv_file_name = "priv.pem"
    public_file_name = "authorized_keys"
    priv_s3_path = date_dir + priv_file_name
    public_s3_path = date_dir + public_file_name

    s3 = boto3.resource("s3")
    
    s3.Bucket(bucket_name).put_object(Key=public_s3_path, Body=public_encoded_string)
    s3.Bucket(bucket_name).put_object(Key=priv_s3_path, Body=private_encoded_string)
    
    #print(private)
    #print(public)
    
    return ()

