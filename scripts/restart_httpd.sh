#!/bin/bash
# Certificate should be located at: s3://test/scripts/restart_httpd.sh

echo "--------- Get httpd service ---------"
sudo service httpd status

echo "--------- Restart httpd service ---------"
sudo service httpd restart
sleep 3

echo "--------- Get httpd service ---------"
sudo service httpd status