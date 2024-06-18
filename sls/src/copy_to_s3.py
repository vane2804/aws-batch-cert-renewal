import os
import boto3

def lambda_handler(event, context):
    # folder path from EFS
    efs_path = r'/mnt/efs'
    s3_bucket = "BUCKET_NAME"

    print('List directories and files')
    res = os.listdir(efs_path)
    print(res)

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(s3_bucket)
 
    for subdir, dirs, files in os.walk(efs_path):
        for file in files:
            full_path = os.path.join(subdir, file)
            key_path = 'certbot-efs/'+full_path[len(efs_path)+1:]
            key_path = key_path.replace('\\', '/')
            print(f"Key Path: {key_path}")
            with open(full_path, 'rb') as data:
                bucket.put_object(Key=key_path, Body=data)

    return
