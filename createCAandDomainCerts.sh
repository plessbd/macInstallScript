#/bin/bash

SCRIPT=`basename ${BASH_SOURCE[0]}`

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

#Help function
function HELP {
  echo "Help documentation for ${BOLD}${SCRIPT}.${NORM}\n"
  echo "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT ${DOMAIN}${NORM}\n"
  echo "Command line switches are optional. The following switches are recognized."
  echo "${REV}-u${NORM}  --Sets the value for ${BOLD}USERS_NAME${NORM}. Default is ${BOLD}${USERS_NAME}${NORM}."
  echo "${REV}-f${NORM}  --Sets the value for ${BOLD}CA_FILELOCATION${NORM}. Default is ${BOLD}${CA_FILELOCATION}${NORM}."
  echo "${REV}-c${NORM}  --Sets the value for two letter ${BOLD}Country${NORM} code. Default is ${BOLD}US${NORM}."
  echo "${REV}-s${NORM}  --Sets the value for ${BOLD}State/Province${NORM}. Default is ${BOLD}NY${NORM}."
  echo "${REV}-l${NORM}  --Sets the value for ${BOLD}Location/City${NORM}. Default is ${BOLD}Clarence${NORM}."
  echo "${REV}-o${NORM}  --Sets the value for ${BOLD}Organization${NORM}. Default is ${BOLD}Development${NORM}."
  echo "${REV}-n${NORM}  --Sets the value for ${BOLD}Common Name${NORM}. Default is ${BOLD}${USERS_NAME}'s CA${NORM}."
  echo "${REV}-d${NORM}  --Sets the value for ${BOLD}CERT_DESTINATION${NORM}. Default is ${BOLD}${CERT_DESTINATION}${NORM}."
  echo "${REV}-h${NORM}  --Displays this help message. No further functions are performed.\n\n"
  echo "Example: ${BOLD}$SCRIPT -u Ben ${DOMAIN}${NORM}"
  exit 1
}
USERS_NAME="$(finger $(whoami) | egrep -o 'Name: [a-zA-Z0-9 ]{1,}' | cut -d ':' -f 2 | xargs echo)"
CERT_DESTINATION="$(brew --prefix)/etc/nginx/ssl/"
CA_FILELOCATION="/Users/$(whoami)/Library/Application Support/Certificate Authority/${USERS_NAME}'s CA"

C="US"
ST="NY"
L="Clarence"
O="Development"
CN="${USERS_NAME}'s CA"
DOMAIN="bpless.dev"
DOMAIN_KEY="${CERT_DESTINATION}star.${TEST_DOMAIN}.key.pem"
DOMAIN_CSR="${CERT_DESTINATION}star.${TEST_DOMAIN}.csr.pem"
DOMAIN_CERT="${CERT_DESTINATION}star.${TEST_DOMAIN}.crt.pem"


while getopts :u:f:c:s:l:o:n:h FLAG; do
  case $FLAG in
    u) USERS_NAME=$OPTARG
      ;;
    f) CA_FILELOCATION=$OPTARG
      ;;
    c) C=$OPTARG
      ;;
    s) ST=$OPTARG
      ;;
    l) L=$OPTARG
      ;;
    o) O=$OPTARG
      ;;
    n) CN=$OPTARG
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      #If you just want to display a simple error message instead of the full
      #help, remove the 2 lines above and uncomment the 2 lines below.
      #echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
      #exit 2
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

while [ $# -ne 0 ]; do
  # Example for generating CSR for multi-domain certificates (UCC):
  # openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout my.domain.key -out my.domain.req -subj  ‘/C=US/ST=Florida/L=Miami/O=Cool IT Company/OU=ITDept/CN=my.domain/emailAddress=hostmaster@my.domain/subjectAltName=DNS.1=www.my.domain,DNS.2=anothersubdom.my.domain’
  DOMAIN=$1
  shift  #Move on to next input file.
done

CA_BASENAME="${CA_FILELOCATION}/${USERS_NAME}'s CA"
CA_KEY="${CA_BASENAME}.key.pem"
CA_CERT="${CA_BASENAME}.crt.pem"
CA_CERT_DER="${CA_BASENAME}.crt.der"

# TODO: Need to not export this, but allow the user to set the environment variable
export CA_PASSWORD="superSecretPassword"

echo "Options:"
echo "\tUSERS_NAME = $USERS_NAME"
echo "\tCA_FILELOCATION = $CA_FILELOCATION"
echo "\tCA_BASENAME = $CA_BASENAME"
echo "\tCA_KEY = $CA_KEY"
echo "\tCA_CERT = $CA_CERT"
echo "\tCA_CERT_DER = $CA_CERT_DER"
echo "\tCA_PASSWORD = Really?"
echo "\n\tCountry: ${C}"
echo "\tState/Province: ${ST}"
echo "\tLocality (City): ${L}"
echo "\tOrganization: ${O}"
echo "\tCommon Name: ${CN}"

mkdir -p "${CA_FILELOCATION}"

if [ ! -e "${CA_CERT}" ]; then

	echo "Creating Certificate Authority for Self Signed Certificates"

	openssl genrsa -aes256 -passout env:CA_PASSWORD -out "${CA_KEY}" 4096
	openssl req -new -x509 -sha256 \
		-days 3650 \
		-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN}" \
		-key "${CA_KEY}" \
		-out "${CA_CERT}" \
		-passin env:CA_PASSWORD

	echo "Converting certificate to DER encoding for importing into keychain"
	openssl x509 -inform PEM -in "${CA_CERT}" -outform DER -out "${CA_CERT_DER}"

  # TODO: Implement this for each OS, only for mac at the moment
	echo "Adding root CA to Keychain"
	# http://sdqali.in/blog/2012/06/05/managing-security-certificates-from-the-console-windows-mac-linux/
	security add-certificate "${CA_CERT_DER}"
	echo "Trusting root CA, this will require user authentication."
	security add-trusted-cert "${CA_CERT_DER}"
fi

mkdir -p "${CERT_DESTINATION}"

echo "Since our aim is to enable SSL on a web server, bear in mind that if the key is encrypted then you will have to enter the encryption password every time you restart your web server. Use the -aes256 argument if you wish to encrypt your private key."
echo "Generate *.${DOMAIN} key"
openssl genrsa -out "${DOMAIN_KEY}" 4096

echo "Generate Certificate Signing Request *.${DOMAIN}"
openssl req -sha256 -new \
	-key "${DOMAIN_KEY}" \
	-out "${DOMAIN_CSR}" \
	-subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=*.${DOMAIN}"

echo "Generate certificate *.${DOMAIN} signed by ${NAME}'s Certificate Authority'"
openssl x509 -req -sha256 -set_serial 01 \
	-days 3650 \
	-CA "${CA_CERT}" \
	-CAkey "${CA_KEY}" \
	-in "${DOMAIN_CSR}" \
	-out "${DOMAIN_CERT}" \
	-passin env:CA_PASSWORD
