#!/bin/bash

# To use JSON::XS plugin copy these files into your Catalyst tree
# You must probably be the root for this operation

CATALISTROOT="/usr/local/share/perl/5.10.0/Catalyst/"

cp ./JSONXS_S.pm "${CATALISTROOT}Action/Serialize/JSONXS.pm"
chmod 444 "${CATALISTROOT}Action/Serialize/JSONXS.pm"
cp ./JSONXS_D.pm "${CATALISTROOT}Action/Deserialize/JSONXS.pm"
chmod 444 "${CATALISTROOT}Action/Deserialize/JSONXS.pm"

