#!/usr/bin python

"""
#
# data-push.py contains the python program to push metrics to vROps. Before you run this script
# set-config.py should be run once to set the environment
# Author Sajal Debnath <sdebnath@vmware.com> 
#
"""
# Importing the Modules

import nagini
import requests
import json
import os, sys
import base64
import time
from requests.packages.urllib3.exceptions import InsecureRequestWarning



# Function to get the absolute path of the script
def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

# Function to map the name of resources with its identifier
def match_resources(resourceknd,adapter):
    resourcedata = {}
    for resource in vrops.get_resources(resourceKind=resourceknd, adapterKindKey=adapter)['resourceList']:
        resourcedata[resource['resourceKey']['name']] = resource['identifier']

    return resourcedata



# Disabling the warning sign for self signed certificates. Remove the below line for CA certificates
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
#pp = pprint.PrettyPrinter(indent=2)


# Getting the absolute path from where the script is being run
basepath = get_script_path()

# Getting the path of the data and envrionment files
datapath = basepath +"/"+"data.json"
envpath = basepath + "/" + 'env.json'

# Opening the env.json file
with open(envpath) as env_file:
    envinfo = json.load(env_file)

# Getting the information from env.json file

adapter = envinfo["adapterKind"]
resourceknd = envinfo["resourceKind"]
servername = envinfo["server"]["name"]
passwd = base64.b64decode(envinfo["server"]["password"])
uid = envinfo["server"]["userid"]


# connecting to the vROps server
#print("Connecting to vROps")
vrops = nagini.Nagini(host=servername, user_pass=(uid, passwd))

# Getting the resources mapped according to their name and uuid
resourcemapping = match_resources(resourceknd, adapter)
# print(resourcemapping)


# Opening the data.json file to get the information
with open(datapath) as data_file:
    data=json.load(data_file)


# Reading the data from data.json file and pushing to vROps
for info in data:
    creationtime = info["createdTime"]
    resourcename = info["name"]
    hostname = info["Hostname"]
    timestamp = info["timestamp"]

    statkeys = ["Summary|creationDate", "Summary|inside-vm-Hostname"]
    resourceid = resourcemapping.get(resourcename)

    proReq = '{"property-content": [{"statKey": "' + statkeys[0] + '", "timestamps": [' + str(timestamp) + '], "values": [' + '"'+ creationtime + '"' + ']},' \
                                                                                                           '{"statKey": "' + statkeys[1] + '", "timestamps": [' + str(timestamp) + '], "values": ['+ '"'+ hostname + '"' + ' ]}]}'
    print(proReq)
    proReq = json.dumps(json.loads(proReq))

    vrops.add_properties( proReq,id=resourceid)
