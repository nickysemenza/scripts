from os import listdir
from os.path import isfile, join

class Command(object):
    """
    Run a command and capture it's output string, error string and exit status
    Source: http://stackoverflow.com/a/13848259/354247
    """
    def __init__(self, command):
        self.command = command
    def run(self, shell=True):
        import subprocess as sp
        process = sp.Popen(self.command, shell = shell, stdout = sp.PIPE, stderr = sp.PIPE)
        self.pid = process.pid
        self.output, self.error = process.communicate()
        self.failed = process.returncode
        return self
    @property
    def returncode(self):
        return self.failed

default_applications = ['Utilities','App Store.app','Automator.app','Calculator.app','Calendar.app','Chess.app','Contacts.app','Dashboard.app','Dictionary.app','DVD Player.app','FaceTime.app','Font Book.app','iBooks.app','Image Capture.app','iTunes.app','Launchpad.app','Mail.app','Maps.app','Messages.app','Mission Control.app','Notes.app','Paste.app','Photo Booth.app','Photos.app','Preview.app','QuickTime Player.app','Reminders.app','Safari.app','Siri.app','Stickies.app','System Preferences.app','TextEdit.app','Time Machine.app','Utilities.app']

remaps = { 
	"iTerm.app": 	"iTerm2",	# brew cask install iterm2 gives iTerm.app
	"Alfred 3.app": "Alfred" 	# brew cask install alfred gives Alfred 3.app
}

mypath = "/Applications"
installed_applications = [f for f in listdir(mypath) if not isfile(join(mypath, f))]

cask_packages 	   = Command('brew cask list').run().output.split()
mac_app_store_apps = Command('mas list').run().output.splitlines()

# collect applications that are not default ones.
user_applications = []
for x in installed_applications:
	#first remap the names
	if(x in remaps):
		name = remaps[x]
	else:
		name = x
	#then check if they are defaults
	if name not in default_applications:
		user_applications.append(name)

# determine which applications weren't installed via brew cask
unmanged_applications = []
for x in user_applications:

	strip_dotapp = x[:-4] if (".app" in x) else x
	trimmed = strip_dotapp.replace(" ", "-").lower()
	is_casked = trimmed in cask_packages
	is_mas	  = any(strip_dotapp in s for s in mac_app_store_apps)
	# print('{} -> {}:  {}|{}'.format(x, trimmed, is_casked, is_mas))
	if(not is_casked and not is_mas):
		unmanged_applications.append(x)

# print("-------------------")
print("You have {} default applications.".format(len(default_applications)))
print("Tou have {} brew cask applications.".format(len(cask_packages)))
print("Tou have {} app store applications.".format(len(mac_app_store_apps)))
print("You have {} user applications Applications not managed by brew cask or app store...\n------".format(len(unmanged_applications)))
for x in unmanged_applications:
	print(x)


# print(mac_app_store_apps)