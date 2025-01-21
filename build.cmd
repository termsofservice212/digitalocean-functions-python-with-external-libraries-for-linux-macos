virtualenv --without-pip virtualenv
virtualenv\Scripts\activate.bat
# Python 3.9
# pip install -r requirements.txt --target virtualenv/lib/python3.9/site-packages
# Python 3.11 is default
pip install -r requirements.txt --target virtualenv/lib/python3.11/site-packages
