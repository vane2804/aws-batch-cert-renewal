import boto3
import sys
import time
import logging

# An SSM Document is run on specific instances
# The script "get_cert_from_s3.sh" is run by the SSM Document

# The following lines should be replaced with the correct values:
# instance_ids = ['INSTANCE_IDS']
# 'sourceInfo':["{\"path\":\"SCRIPT_PATH\"}"],

# Define boto3 clients
client_ssm = boto3.client('ssm')
client_ec2 = boto3.client('ec2')

# Configure logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def start_process():
  instance_ids = ['INSTANCE_IDS']

  for id in instance_ids:
    ssm_response = send_command(id)
    command_id = ssm_response['Command']['CommandId']
    wait_for_command(command_id, id)

  return

# Wait for ssm command to finish
def wait_for_command( command_id, instance_id ):
  max_attempts = 20
  sleep_time = 5
  time_seconds = max_attempts * sleep_time

  output_content = ''
  error_content = ''

  logger.info('Wait for SSM command to finish')
  logger.info('Instance [%s] and Command Id [%s]', instance_id, command_id)
  for x in range(max_attempts):

    logger.info('Check ssm command status, attemp [%s]', x)

    try:
      if x == (max_attempts-1):
        logger.error("Command did not arrive to Success or Failed status after [%s] seconds", time_seconds)
        sys.exit()

      response = client_ssm.get_command_invocation(
        CommandId = command_id,
        InstanceId = instance_id,
        PluginName = 'runShellScript'
      )
      logger.info('Fetching command state')

      if response['Status'] == "Success":
        output_content = response['StandardOutputContent']
        error_content = response['StandardErrorContent']
        logger.info('SSM Command SUCCESS')

        logger.info('Standard Output Content')
        logger.info(output_content)
        logger.error('Standard Error Content')
        logger.error(error_content)
        break
      elif response['Status'] == "Failed":
        output_content = response['StandardOutputContent']
        error_content = response['StandardErrorContent']
        logger.error('SSM Command FAILED')

        logger.info('Standard Output Content')
        logger.info(output_content)
        logger.error('Standard Error Content')
        logger.error(error_content)
        sys.exit(1)
      else:
        time.sleep(sleep_time)
    except Exception as e:
      # print(e)
      # logger.error("Error fetching ssm command status", exc_info=True)
      logger.error("Error fetching ssm command status [%s]", e)
      time.sleep(sleep_time)

# Run ssm command
def send_command( instance_id ):
  command = 'restart_httpd.sh'
  logger.info('Command to run')
  logger.info(command)
  logger.info(instance_id)

  try:
    response = client_ssm.send_command(
      InstanceIds=[instance_id],
      DocumentName='AWS-RunRemoteScript',
      Parameters={
        'sourceType': [ 'S3' ],
        'sourceInfo':["{\"path\":\"SCRIPT_PATH\"}"],
        "commandLine":[command]
      }
    )
    logger.info('SSM response')
    logger.info(response)
    return response
  except Exception as e:
    logger.error("Error running SSM Command", exc_info=True)
    sys.exit()

# Main function
def main():
  logger.info(f'Start process')
  start_process()
  logger.info(f'End process')

def lambda_handler(event, context):
  main()
