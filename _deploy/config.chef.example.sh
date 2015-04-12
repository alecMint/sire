
# Path to AWS private key
# Do not need this if you already have ssh access
export ec2Cert='/Users/ahulce/.ssh/my-aws-private-key.pem'

# Local public key
# Can also paste entire value here
# Do not need this if you already have ssh access
export sshKey='/Users/ahulce/.ssh/id_rsa.pub'

# IP or CNAME of target instance...
export serverName='123.123.123.123' # or ec2-123-123-123-123.compute-1.amazonaws.com

# Public + private keys of deploy github user
# This user should have read-only access to your repos
# Can also set the value to point at a file
export machineSshKeyPublic='ssh-rsa AAAAC4G...'
export machineSshKeyPrivate=$'-----BEGIN RSA PRIVATE KEY-----\nMIIFnAGB...'

# Keys for s3
export awsAccessKey=''
export awsAccessSecret=''

export facebookAppId=''
export facebookAppSecret=''
