vrops-data-push

Push resource properties/metric to vRealize Operations Manager using REST API and python client

Purpose:

This is a small program to push properties/metric data to a "resource/set of resources" in vRealize Operations Manager using python client and REST API.

For details of the purpose of the script please check http://vtechguru.com/2017/06/how-to-push-custom-data-in-vrealize-operations-manager.html 

What is included:

There are two Python script files and three powershell script files.

The Powershell scripts are used to gather the data that needs to be pushed to vROPs.

The Python files are used to process and push the data to vROps

Pre-Requisites:

These programs were written in Python2.7 and Powershell 5.0 versions.So your system should have Python 2.7 and Powershell 5.0. Also download and install nagini module from vRealize Operations Manager. It can be found at "https:///suite-api" . Visit the page, download and install the Python Client. Typically Windows boxes don't have Python installed in it. Download and install Python 2.7.x version on you windows machine.

How to run:

Download all the files to the same location. Program has three parts.

Part 1: Setting up the environment:

For first time run Set-VCdetails.ps1 using powershell. You can simply open powershell windows and run the script with C:\ .\Set-VCdetails.ps1

This will ask you for the following information:

vCenter Server Name:

vCenter User Id:

Password:

Once these information are provided, it will create vcdetails.txt (contains vCenter server name and user name) and passwd.txt (contains the password in encrypted format).

Next run set-env.py file. You can run it like following:

with #python set-env.py, this will ask for the following inputs:

Adapter Kind:

Resource Kind:

vROPs server IP/FQDN:

user id:

vROps password:

Once all the above information is provided, the script generates env.json in the same location. The provided password is saved in encrypted format.

Part 2: Getting the data from vCenter server:

Run the "Get-VMDetails.ps1" file with powershell cmdline. This will get values from vcdetails.txt and passwd.txt file and generate data.json file in the same location. This data.json will have the desired output values.

Part 3: Pushing the data to vROps server:

Next run data-push.py from cmdline with #python data-push.py. This will gather required information from env.jon, data.json and push data to vROps server

You should schedule two jobs, one for Get-VMDetails.ps1 and another for data-push.py to run these scripts one after other.