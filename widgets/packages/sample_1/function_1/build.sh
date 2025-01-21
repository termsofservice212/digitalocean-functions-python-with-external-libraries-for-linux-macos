#!/bin/bash

set -e

virtualenv ---without-pip virtualenv
source virtualenv/source/activate
# Assuming you are using python 3.9
pip install -r requirements.txt --target virtualenv/lib/python3.9/site-packages
# Assuming you are using python 3.11
pip install -r requirements.txt --target virtualenv/lib/python3.11/site-packages
