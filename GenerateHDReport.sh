#!/bin/bash
. $(dirname $0)/base_util.sh
. $(dirname $0)/email.cnf

# HDSentinel PATHS
FILE_DIR=$(dirname $0)
HDS_PATH="${FILE_DIR}/HDSentinel"
REP_PATH="/tmp/HDSentinelReport.html"


# Retrieves computer name
function getComputerName() {
	grep "Computer Name" ${REP_PATH} | awk -F"td>" '{ print $5 }'
}


# Retrieves lowest drive health
function getHealth() {
	grep "Health" ${REP_PATH} | awk -F"td> " '{ print $2 }' | sort -n | head -1
}


# Generate Report
if [ -f "${HDS_PATH}" ]; then
	logmsg "Generating HDSentinel Report"
	${HDS_PATH} -html -r ${REP_PATH}

	# Report was generated?
	if [ -f "${REP_PATH}" ]; then
	
		# Fetch health
		REP_HEALTH=$(getHealth)
		PC_NAME=$(getComputerName)

		# Send Report by email
        sendMailWithHtmlBody "${EMAIL_FROM}" "${EMAIL_TO}" "${EMAIL_SUBJECT} (${PC_NAME}) - ${REP_HEALTH}" "${REP_PATH}"
    else
        logmsg "Error generating the HDSentinel report file ${REP_PATH}"
    fi
else
	logmsg "The HDSentinel binary file was not found! please check the README_FIRST.txt file"
fi

