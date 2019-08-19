#!/bin/bash
set -Eeuox pipefail

DEST=knative-serving.yaml

RELEASE=v0.6.0

BASEURL=https://raw.githubusercontent.com/openshift-knative/knative-serving-operator/${RELEASE}/deploy
$(dirname $0)/get_operator_config.sh $BASEURL $DEST

curl -f $BASEURL/crds/serving_v1alpha1_knativeserving_crd.yaml -o serving_v1alpha1_knativeserving_crd.yaml
cat serving_v1alpha1_knativeserving_crd.yaml >> $DEST; echo "---" >> $DEST
rm serving_v1alpha1_knativeserving_crd.yaml

sed -i.bak 's/namespace: default/namespace: kabanero/g' $DEST
rm $DEST.bak
