#!/usr/bin/env python3

# importing required modules
from my_modules import *

# define threshold at which disk cleanup should be performed 
threshold = 80
 
# if disk usage is greater than or equal to threshold
if (used / total)*100 >= threshold:
    dfcleanup()
    print("Clean up complete (:")
    print(f"Disk Usage:\nTotal: {total_2_dp} GiB, Used: {used_2_dp} GiB, Free: {free_2_dp} GiB")

# otherwise, show disk usage in cli
else: 
    print(f"Disk Usage:\nTotal: {total_2_dp} GiB, Used: {used_2_dp} GiB, Free: {free_2_dp} GiB")
