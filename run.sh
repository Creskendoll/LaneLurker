#!/bin/bash

# *.love
cd "src"
zip -r ../"test_build".love *
cd ..
love test_build.love