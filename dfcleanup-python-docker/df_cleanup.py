#!/usr/bin/env python3

# importing required modules, imported clean_up_msg (has api for mailgun, use smtplib if not using mailgun for email alerts)
from clean_up_msg import clean_up_message
from my_modules import *

# define threshold at which disk cleanup should be performed 
threshold = 80

# run disk cleanup && send email alert  
# if disk usage is greater than or equal to threshold
if (used / total)*100 >= threshold:
    dfcleanup(), clean_up_message()
    print("Clean up complete (:")
    print(f"Disk Usage:\nTotal: {total_2_dp} GiB, Used: {used_2_dp} GiB, Free: {free_2_dp} GiB")

# otherwise, show disk usage in cli
else: 
    print(f"Disk Usage:\nTotal: {total_2_dp} GiB, Used: {used_2_dp} GiB, Free: {free_2_dp} GiB")
