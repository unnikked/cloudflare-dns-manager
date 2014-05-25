#!/bin/bash

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2004 Sam Hocevar
#  22 rue de Plaisance, 75014 Paris, France
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

# GITHUB REPO: 		https://github.com/unnikked/cloudflare-dns-manager
# DEPENDENCIES: 	https://github.com/stedolan/jq

# dyndns email token domain action type zone_name service_mode
# CREATE - create a zone record
# MODIFY - modify a zone record 
# DELETE - delete a zone record 

if [ $# -lt 7 ]; then
	echo "USAGE $0 [email] [token] [action] [domain] [type] [zone_name] [service_mode] (ip address)"
	exit 1;
fi

EMAIL="$1"
TKN="$2"
ACTION="$3"
DOMAIN="$4"
TYPE="$5"
NAME="$6"
SERVICE_MODE="$7"

if [ $# -eq 8 ]; then
	IP="$8"
	echo "Using the ip specified: $IP"
else
	IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
	echo "Using your public ip: $IP"
fi

# returns status code
function handle_response() {
	local RES=$(echo "$1" | jq ".result")
	if [ "${RES:1:-1}" == "success" ]; then
		echo "success"
		return
	fi
	echo -n "${RES:1:-1}:"
	echo "$1" | jq ".msg"
}

# get all records for a given DOMAIN
function get_all_rec() {
	local RES=$(curl -s https://www.cloudflare.com/api_json.html \
		-d "a=rec_load_all" \
		-d "tkn=$TKN" \
		-d "email=$EMAIL" \
		-d "z=$DOMAIN")
	echo "$RES"
}

# get rec_id for given DOMAIN, TYPE and NAME
function get_rec_id() {
	local RES="$1"
	local ITEMS=$(echo "$RES" | jq '.response.recs.count')
	for i in $(seq $ITEMS); do
		local CURRENT_DOMAIN=$(echo "$RES"| jq ".response.recs.objs[$i].zone_name")
		if [ "${CURRENT_DOMAIN:1:-1}" == "$DOMAIN" ]; then
			local CURRENT_TYPE=$(echo "$RES" | jq ".response.recs.objs[$i].type")
			if [ "${CURRENT_TYPE:1:-1}" == "$TYPE" ]; then
				local CURRENT_NAME=$(echo "$RES" | jq ".response.recs.objs[$i].name")
				if [ "${CURRENT_NAME:1:-1}" == "$NAME" ]; then
					local REC_ID=$(echo "$RES" | jq ".response.recs.objs[$i].rec_id")
					echo "${REC_ID:1:-1}"
					return
				fi
			fi
		fi
	done
	echo "NONE"
}

# return status code - PARAMS {get_all_rec} {rec_id}
# 0 ip changed
# 1 ip not changed or an error occurred
function ip_changed() {
	local RES="$1"
	local REC_ID="$2"
	local ITEMS=$(echo $RES | jq '.response.recs.count')
	for i in $(seq $ITEMS); do
		local CURRENT_REC_ID=$(echo $RES | jq ".response.recs.objs[$i].rec_id")
		if [ "${CURRENT_REC_ID:1:-1}" == "$REC_ID" ]; then
			local CURRENT_IP=$(echo $RES | jq ".response.recs.objs[$i].content")
			if [ "${CURRENT_IP:1:-1}" == "$IP" ]; then
				echo "0" 
			else
				echo "1"
			fi
		fi	
	done
}

# returns the JSON formatted response to be handled
function create_record() {
	local RES=$(curl -s https://www.cloudflare.com/api_json.html \
		-d "a=rec_new" \
		-d "tkn=$TKN" \
		-d "email=$EMAIL" \
		-d "z=$DOMAIN" \
		-d "type=$TYPE" \
		-d "name=$NAME" \
		-d "content=$IP" \
		-d "ttl=1" )
	echo "$RES"
}

# returns the JSON formatted response to be handled
# PARAMS {rec_id}
function update_record() {
	local RES=$(curl -s https://www.cloudflare.com/api_json.html \
		-d "a=rec_edit" \
		-d "tkn=$TKN" \
		-d "id=$1" \
		-d "email=$EMAIL" \
		-d "z=$DOMAIN" \
		-d "type=$TYPE" \
		-d "name=$NAME" \
		-d "content=$IP" \
		-d "service_mode=$SERVICE_MODE" \
		-d "ttl=1")
	echo "$RES"
}

# returns the JSON formatted response to be handled
# PARAMS {rec_id}
function delete_record() {
	local RES=$(curl -s https://www.cloudflare.com/api_json.html \
		-d "a=rec_delete" \
  		-d "tkn=$TKN" \
  		-d "email=$EMAIL" \
  		-d "z=$DOMAIN" \
  		-d "id=$1" )
  	echo "$RES"
}

if [ "$ACTION" == "CREATE" ]; then 
	GETALLREC="$(get_all_rec)"
	RES="$(handle_response "$GETALLREC")"
	if [ "$RES" == "success" ]; then
		CREATERECORD="$(create_record)"
		RES="$(handle_response "$CREATERECORD")"
		echo "$RES"
		if [ "$RES" == "success" ]; then
			exit 0
		else 
			exit 1
		fi
	else
		echo "$RES"
		exit 1
	fi
fi

if [ "$ACTION" == "MODIFY" ]; then 
	GETALLREC="$(get_all_rec)"
	RES="$(handle_response "$GETALLREC")"
	if [ "$RES" == "success" ]; then
		RECID="$(get_rec_id "$GETALLREC")"
		if [ "$RECID" == "NONE" ]; then
			echo "error: record not found, maybe you have to CREATE it first."
			exit 1
		fi
		IPCHANGED="$(ip_changed "$GETALLREC" "$RECID")"
		if [ "$IPCHANGED" == "1" ]; then
			UPDATERECORD="$(update_record "$RECID")"
			RES="$(handle_response "$UPDATERECORD")"
			echo "$RES"
			if [ "$RES" == "success" ]; then
				exit 0
			else 
				exit 1
			fi
		elif [ "$IPCHANGED" == "0" ]; then
			echo "IP was not changed"
			exit 0
		fi
	else
		echo "$RES"
		exit 1
	fi
fi

if [ "$ACTION" == "DELETE" ]; then 
	GETALLREC="$(get_all_rec)"
	RES="$(handle_response "$GETALLREC")"
	if [ "$RES" == "success" ]; then
		RECID="$(get_rec_id "$GETALLREC")"
		UPDATERECORD="$(delete_record "$RECID")"
		RES="$(handle_response "$UPDATERECORD")"
		echo "$RES"		
		if [ "$RES" == "success" ]; then
			exit 0
		else 
			exit 1
		fi
	else
		echo "$RES"
		exit 1
	fi
fi

if [ "$ACTION" == "LISTALL" ]; then 
	GETALLREC="$(get_all_rec)"
	RES="$(handle_response "$GETALLREC")"
	if [ "$RES" == "success" ]; then
		ITEMS=$(echo $GETALLREC | jq '.response.recs.count')
		let ITEMS=$ITEMS-1
		for i in $(seq $ITEMS); do
			echo -e "TYPE: $(echo $GETALLREC | jq ".response.recs.objs[$i].type") CONTENT: $(echo $GETALLREC | jq ".response.recs.objs[$i].content") NAME: $(echo $GETALLREC | jq ".response.recs.objs[$i].name")"
		done
	else 
		echo "$RES"
		exit 1
	fi
	exit 0
fi

echo "error: invalid action"
exit 1

#Disclaimer
#
#THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
