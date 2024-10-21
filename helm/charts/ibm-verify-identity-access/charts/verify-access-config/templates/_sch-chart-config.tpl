{{/* vim: set filetype=mustache: */}}

{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019, 2024. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation
###############################################################################
*/}}


{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
*/ -}}

{{- define "iviaconfig.sch.chart.config.values" -}}
sch:
  chart:
    appName: "iviaconfig"
    config:
      servicename: "iviaconfig"
    metering:
      productName: "IBM Verify Identity Access"
      productID: "5725-V90"
      productVersion: "11.0.0.0"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
{{- end -}}
