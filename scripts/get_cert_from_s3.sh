#!/bin/bash

# Certificate should be located the S3 path: s3://test/get_cert_from_s3.sh

# Variables
local_path='/data/ssl/default'
s3_path='s3://test/certbot-efs/live/domain.com'

s3_cert_file_name='cert.pem'
s3_cert_key_file_name='privkey.pem'
s3_cert_chain_file_name='fullchain.pem'

cert_file_name='domain.com.crt'
cert_key_file_name='domain.com.key'
cert_chain_file_name='gd_bundle.crt'

# Certificate File
echo "Download certificate file"
echo "from [$s3_path/$s3_cert_file_name]"
echo "to [$local_path/$cert_file_name]"
aws s3 cp "$s3_path/$s3_cert_file_name" "$local_path/$cert_file_name"

# Certificate Key
echo "Download certificate key"
echo "from [$s3_path/$s3_cert_key_file_name]"
echo "to [$local_path/$cert_key_file_name]"
aws s3 cp "$s3_path/$s3_cert_key_file_name" "$local_path/$cert_key_file_name"

# Certificate Chain
echo "Download certificate chain"
echo "from [$s3_path/$s3_cert_chain_file_name]"
echo "to [$local_path/$cert_chain_file_name]"
aws s3 cp "$s3_path/$s3_cert_chain_file_name" "$local_path/$cert_chain_file_name"