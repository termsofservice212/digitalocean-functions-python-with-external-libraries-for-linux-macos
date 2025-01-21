# Template for DigitalOcean Functions using python with external libraries for linux and macos

This is to help anyone who has problem with running DO Functions needing to use additional python libraries not provided by DO. I've selected DO Functions because the python script only needed to run twice a day which slips under the free tier. 

I was trying out DigitalOcean Functions to run python cron job. It took me couple days to figure out how to run the python script while installing additional python libraries via virtualenv, to find out my code (with all the python libraries) amounted to 50mb, crossing DO's limit by 2mb. Nonetheless I've got to find another way to solve my use case.

Just in case you have the same requirement as I do
- Using DO Functions
- Using either python 3.9 or 3.11 (these are the two versions provided by DO)
- Require additional python libraries not provided by DO
- You are running Linux. (I had immense trouble with Win11 ergo switched to Linux: _Update:_ I managed to get it running from a Win11 client. See bottom)
- You are comfortable with the commandline.
- You require the task to be run at scheduled timings.

Here's how you can start up quickly.

1. Log into DO web portal and create a API token, assigning the serverless/function scopes (create, read, update, delete) to the token. 

Steps:
Login to DO > [Go to left panel near bottom] Select API > [On right panel, select] Create token > Give the token a name and assign the serverless scopes as mentioned above.

You will also need to select a validity period for the token. Select one which you think is needed for your use case/testing period. You can also set never to expire. You will need to pay the charges if the token was misused by other people. See this time-based setting as a financial firewall for $$$ loss prevention, you also must not misplace the token.

Next, save this token using a text editor. You will need this shortly to login to DO Functions on the command line.

2. Download and install doctl from DO's page. [How to install doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/)

3. Get into commandline and authenticate to DO using `doctl auth init`

4. If this is the first time you've installed doctl, you will need to install the serverless component via `doctl serverless install`

5. Create a namespace `doctl serverless namespace --context <your_namespace>` eg `doctl serverless namespace --context my_fantastic_ns`

6. Next go to your python script folder and create the following [project folder](https://docs.digitalocean.com/products/functions/how-to/structure-projects/) structure

```
widget
  |----packages (this needs to be named `packages` as required by DO)
  |      |----sample_1 (this package can be named anything you want)
  |               |----function_1 (this can be named anything you want)
  |                       |-----requirements.txt
  |                       |-----build.sh
  |                       |-----__main.py__
  |
  project.yml
```

7. Your python script needs to be renamed to `__main.py__`

8. To get requirements.txt, `pip freeze > requirements.txt`

9. For build.sh, use the below (for python 3.11)

```
#!/bin/bash

set -e

virtualenv ---without-pip virtualenv
source virtualenv/source/activate
# Assuming you are using python 3.9
# pip install -r requirements.txt --target virtualenv/lib/python3.9/site-packages
# Assuming you are using python 3.11
pip install -r requirements.txt --target virtualenv/lib/python3.11/site-packages
```

9. For project.yml. This is setup for a scheduled trigger (eg cron job)

```
parameters: {}
environment: {}
packages:
    - name: sample_1
      shared: false
      functions:
        - name: function_1
          binary: false
          main: function_1/__main__.py
          runtime: 'python:default'
          web: false
          webSecure: false
          triggers:
            - name: 'trigger-function_1'
              sourceType: scheduler
              sourceDetails:
                  cron: "*/5 * * * *"  # Cron expression every five minutes
```

10. To load the function into DO's runtime, you run this `doctl serverless deploy . --verbose-build` when you are in the widget folder. Note there is a period between `deploy` and `--verbose-build` See example below

```
/
|--home
     |---luser
           |----projects 
                   |------ widget (this is your Functions app folder. run the above command here)
                             |----- packages
                                       |----- sample_1 (this is your package name)
```

11. As I have scheduled runs of the function (in the project.yml, you can see the `*/5 * * * *` which means run at every five minute intervals), you can check the progress using `doctl serverless activations list`. Running this command will show you how many times the function has activated. If you want to see more details, run `doctl serverless activations logs`.

12. Alright, the functions lifecycle almost complete. For the last part, we need to know how to deactivate the function. `doctl serverless undeploy <package_name/function_name>`. Eg `doctl serverless undeploy sample_1/function_1`

Alternatively, `doctl serverless undeploy --all` to undeploy all functions at one go.

13. NOTE! You will have to pay if the functions get run more than what's given under DO's [free tier](https://docs.digitalocean.com/products/functions/details/pricing/). So don't forget to undeploy functions when you are done - Even when you are doing testing!


## Template for DigitalOcean Functions using python with external libraries for windows 11
If you are on windows 11, replace the build.cmd (in the root folder) with build.sh in the functions folder.

You will need to install (_python3_)[https://www.python.org/downloads/windows/] on Windows first before pulling in _virtualenv_ `pip install virtualenv` on the command line.


