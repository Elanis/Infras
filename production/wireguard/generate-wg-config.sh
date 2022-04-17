#!/usr/bin/env bash
set -euo pipefail

wg-meshconf init

wg-meshconf addpeer --address 192.168.1.2 --endpoint helium.dysnomia helium.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.3 --endpoint lithium.dysnomia lithium.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.4 --endpoint beryllium.dysnomia beryllium.dysnomia.studio

wg-meshconf genconfig

wg-meshconf showpeers