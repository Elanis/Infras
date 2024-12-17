#!/usr/bin/env bash
set -euo pipefail

wg-meshconf init

wg-meshconf addpeer --address 192.168.1.1 --endpoint local.dysnomia.studio local.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.6 --endpoint carbon.dysnomia.studio carbon.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.7 --endpoint nitrogen.dysnomia.studio nitrogen.dysnomia.studio
wg-meshconf addpeer --address 192.168.1.8 --endpoint oxygen.dysnomia.studio oxygen.dysnomia.studio

wg-meshconf genconfig

wg-meshconf showpeers