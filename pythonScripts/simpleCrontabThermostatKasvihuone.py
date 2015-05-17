#!/usr/bin/python
# -*- coding: utf-8 -*-
import subprocess
import os
import redis
from datetime import datetime
"""
Super simple thermostat program
@author: jussikin
"""

CUT_OFF=11
START_POINT=9


STOP_COMMAND="/usr/local/bin/tdtool --off 3"
START_COMMAND="/usr/local/bin/tdtool --on 3"

r = redis.Redis(host="10.102.27.90",port=6379,db=0)
number   = float(r.hget('sensor',16).split(':')[0])

if(number<START_POINT):
    subprocess.call(START_COMMAND,shell=True,
               stderr=open(os.devnull,'w'),
               stdout=open(os.devnull,'w'))
if(number>CUT_OFF):
    subprocess.call(STOP_COMMAND,shell=True,
                stderr=open(os.devnull,'w'),
                stdout=open(os.devnull,'w'))

