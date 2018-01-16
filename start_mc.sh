#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function run_command()
{
    echo "$1"
    eval "$1"
}

run_command "addgroup -g $MCGID minecraft"
run_command "adduser -h /srv/minecraft -S -u $MCUID -G minecraft minecraft"

set +e
run_command "cp -R /srv/minecraft/config.override/* /srv/minecraft/config/"
run_command "cp -R /srv/minecraft/mods.override/* /srv/minecraft/mods/"
set -e

run_command "chown -R minecraft:minecraft /srv/minecraft"

echo "Starting server"

cd /srv/minecraft/
run_command "su -s $(which bash) -c \"$(which java) -server -d64 -XX:NewRatio=1 -XX:UseSSE=4 -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSIncrementalPacing -XX:+UseCMSCompactAtFullCollection -XX:+CMSScavengeBeforeRemark -XX:+UseParNewGC -XX:SurvivorRatio=4 -XX:NewSize=128m -XX:MaxNewSize=128m -XX:+DisableExplicitGC -XX:+AggressiveOpts -XX:MaxGCPauseMillis=50 -XX:+UseLargePages -XX:LargePageSizeInBytes=2m -XX:+UseStringCache -XX:CompileThreshold=500 -XX:+UseFastAccessorMethods -XX:+UseBiasedLocking -XX:+OptimizeStringConcat -Dsun.net.client.defaultConnectTimeout=1000 -Xmx${MCMEM}M -Xms${MCMEM}M -jar $(find . -name '*.jar' -type f -maxdepth 1 | grep -i 'forge') nogui\" minecraft"
