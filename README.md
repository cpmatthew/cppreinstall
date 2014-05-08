cppreinstall
============

This script is written in bash and perl, and will help you prepare a server for cPanel installation.

Usage:
First run the script with bash: bash cpanel_preinstall.sh
It'll then run and check to see if perl is installed. If it isn't, then it will install perl for you.

Once that's done, you'll see a message saying to run it again with 'perl -x', which is what you'll need to do.

perl -x cpanel_preinstall.sh

That will then give you a menu for checking several options. If you wish to fix any issues, run it again with the --fix or -f flags.
