"""
    This python code is used to run the bash script sync_prog.sh
    which performs a sync check with the designated upstream
    remote branch.
"""

import subprocess

'''
    Note: The bash script being run is dependent on the remote
    repository being set as the upstream for ease when using
    the git rev-parse command.
    If this is not the case, perform an initial set with the
    following command: git branch --set-upstream-to=<branch alias>/<branch> master
'''

cmd = "./sync_prog.sh"
sync_check = subprocess.check_call(["bash", "-c", cmd])

'''
    Note: add additional code that enables the sync check to be run as a
    method, where the input is the remote url to sync up with. Therefore,
    this will be able to auto-sync with any desired remote repository.
'''

'''
    Note: Add if-main statement to enable this to be run as a method
    inside other programs.
'''

