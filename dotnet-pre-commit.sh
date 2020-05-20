#!/bin/bash

# If you want to easily move this hook between environments
# make sure that you create install.sh

# Color Codes:
#tput setaf 1 = red -> error
#tput setaf 2 = green -> good
#tput setaf 3 = amber -> Info

echo ""
echo "$(tput setaf 3)Running pre-commit hook...$(tput sgr 0)"
echo "$(tput setaf 3)You can omit this with '--no-verify'$(tput sgr 0)"

# Check for non-staged changes
git diff --quiet
hadNoNonStagedChanges=$?

if ! [ $hadNoNonStagedChanges -eq 0 ]
then
        echo "$(tput setaf 3)[INFO] Stashing non-staged changes$(tput sgr 0)"
        git stash --keep-index -u > /dev/null
fi

# Check if project builds - not this time
echo "$(tput setaf 3)[INFO] Does it compile?$(tput sgr 0)"
echo "$(tput setaf 2)[PASS] Who cares?!$(tput sgr 0)"

# Check formatting
echo "$(tput setaf 3)[INFO] Formatting staged changes...$(tput sgr 0)"

(dotnet.exe format > /dev/null)
git diff --quiet 
formatted=$?

echo "$(tput setaf 3)[INFO] Is well formatted?$(tput sgr 0)"

if [ $formatted -eq 0 ]
then
        echo "$(tput setaf 2)[PASS] Yes$(tput sgr 0)"
else
        echo "$(tput setaf 1)[WARN] No$(tput sgr 0)"
        echo "$(tput setaf 1)[WARN] Following files need formatting:$(tput sgr 0)"
        git diff --name-only
        echo ""
        echo "$(tput setaf 1)[WARN] Please run 'dotnet.exe format' to format the code.$(tput sgr 0)"
        echo ""
fi

echo "$(tput setaf 3)[INFO] Undoing formatting...$(tput sgr 0)"
git stash --keep-index > /dev/null
git stash drop > /dev/null

if ! [ $hadNoNonStagedChanges -eq 0 ]
then
        echo "$(tput setaf 3)[INFO] Scheduling stash pop of previously stashed non-staged changes...$(tput sgr 0)"
        sleep 1 && git stash pop --index > /dev/null &
fi

if [ $formatted -eq 0 ] 
then
        echo "$(tput setaf 2)[PASS]... done. Commiting changes...$(tput sgr 0)"
        echo ""
        exit 0
else
        echo "$(tput setaf 1)[WARN]... done.$(tput sgr 0)"
        echo "$(tput setaf 1)[WARN] Cancelling due to formatting issues.$(tput sgr 0)"
        echo ""
        exit 1
fi
