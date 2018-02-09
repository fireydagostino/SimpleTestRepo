import os, subprocess

subprocess.call(["ls", "-l"])

#os.system("echo.sh") - works - however popup screen is annoying
#os.system("./echo.sh") works in moba

'''
    This works, as long it's done in Git Bash ... for some reason.
    IE: Causes errors when run in the windows black box
'''

print(subprocess.Popen("echo Hello World", shell=True, stdout=subprocess.PIPE).stdout.read())

return_code = subprocess.call("echo Hello Second World", shell=True)

return_next = subprocess.run("echo Hello Third World", shell=True)
#run command is only usable in Python >= 3.5

an_output = subprocess.Popen("ls | grep \"s\"", shell=True, stdout=subprocess.PIPE)
for line in an_output.stdout.readlines():
    print(line)
retval = an_output.wait()
print(retval)

return_value = subprocess.check_call(["ls", "-al"])

for x in range(0,4):
    print("Timer:", x)

cmd02 = "./echo.sh"
next_output = subprocess.check_call(["bash", "-c", cmd02]) #executes cmd02 using bash!!!
