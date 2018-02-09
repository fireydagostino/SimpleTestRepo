import subprocess

'''
    Note: The bash script being run is dependent on the remote
    repository being set as the upstream for ease when using
    the git rev-parse command.
    
    If it is not the case, perform an initial set with the
    following command: git remote add upstream
'''

cmd = "./sync_prog.sh"
sync_check = subprocess.check_call(["bash", "-c", cmd])