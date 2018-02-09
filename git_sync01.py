import subprocess

cmd = "./sync_prog.sh"
sync_check = subprocess.check_call(["bash", "-c", cmd])