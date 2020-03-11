#!/bin/bash

rm sha_per_day.txt unbottled_count.txt file_count.txt dates.txt

if [ -e linuxbrew-core ]; then
    cd linuxbrew-core
    git fetch origin --force
    git reset --hard origin/master
    cd -
else
    git clone https://github.com/Homebrew/linuxbrew-core
fi

cd linuxbrew-core

paste <(git rev-list master --first-parent) <(git rev-list master --first-parent | xargs git show -s --format=%ct | awk '{ if (NR > 1) { print _n-int($1 / 86400)};_n=int($1 / 86400)}') | grep 1$ | cut -f1 > ../sha_per_day.txt

xargs git show -s --format=%ct < ../sha_per_day.txt > ../dates.txt

while read -r line;
do
    git checkout $line
    rg --files-without-match 'bottle :unneeded|depends_on :xcode|:x86_64_linux' Formula/ | wc -l >> ../unbottled_count.txt
    ls Formula/ | wc -l >> ../file_count.txt
done < ../sha_per_day.txt

cd -
