#!/usr/bin/env bash
set -euo pipefail

wg-meshconf init

wg-meshconf addpeer --address 192.168.1.2 --endpoint helium.dysnomia.studio helium.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.3 --endpoint lithium.dysnomia.studio lithium.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.4 --endpoint beryllium.dysnomia.studio beryllium.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.5 --endpoint bore.dysnomia.studio bore.dysnomia.studio

wg-meshconf genconfig

wg-meshconf showpeers