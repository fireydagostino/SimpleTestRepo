"""
    Python script designed to sync up the current repository
    with the selected remote repository (in this case the
    sigma project by Neo23x0).
    Sigma URL: https://github.com/Neo23x0/sigma.git
"""

import subprocess


'''
    Python method to run a bash script within python.
    In this case the bash script to run is called
    sync_prog.sh
'''
def run_sync():
    subprocess.check_call(["bash", "-c", "/opt/sigma/git_sigma/sync_prog.sh"])



if __name__ == '__main__':
    run_sync()
