import sys
import subprocess


'''
    To Do:
        1) Add check for > 2 arguments
'''


def run_update(in_alias, out_alias):
    if in_alias == "--" and out_alias == "--":
        print("Error: Please indicate at least one outsource repository to link with.")
        exit(1)
    else:
        subprocess.check_call(["bash", "-c", "./arg_tester.sh " + in_alias + " " + out_alias])


if __name__ == '__main__':
    try:
        run_update(sys.argv[1], sys.argv[2])
    except OSError as e:
        print("Bash script execution failed:", e)
