# !/usr/bin python

"""
#
# set-env - a small python program to setup the configuration environment for data-push.py
# data-push.py contains the python program to push attribute values to vROps
# Author Sajal Debnath <sdebnath@vmware.com> 
#
"""
# Importing the required modules

import json
import base64
import os,sys


# Getting the absolute path from where the script is being run
def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

# Getting the inputs from user

def get_the_inputs():
    adapterkind = raw_input("Please enter Adapter Kind: ")
    resourceKind = raw_input("Please enter Resource Kind: ")
    servername = raw_input("Enter enter Server IP/FQDN: ")
    serveruid = raw_input("Please enter user id: ")
    serverpasswd = raw_input("Please enter vRops password: ")
    encryptedvar = base64.b64encode(serverpasswd)

    data = {}
    data["adapterKind"] = adapterkind
    data["resourceKind"] = resourceKind

    serverdetails = {}
    serverdetails["name"] = servername
    serverdetails["userid"] = serveruid
    serverdetails["password"] = encryptedvar

    data["server"] = serverdetails

    return data


# Getting the path where env.json file should be kept
path = get_script_path()
fullpath = path+"/"+"env.json"

# Getting the data for the env.json file
final_data = get_the_inputs()

# Saving the data to env.json file

with open(fullpath, 'w') as outfile:
    json.dump(final_data, outfile, sort_keys = True, indent = 2, separators=(',', ':'), ensure_ascii=False)