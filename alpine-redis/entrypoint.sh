#!/bin/sh

#Starting with no persistence.
su-exec default redis-server --save "" --appendonly no