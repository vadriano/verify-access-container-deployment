{{/* vim: set filetype=mustache: */}}

{{/*
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation
###############################################################################
*/}}

{{/*
This chart relies on some of the help functions which are defined in the
main chart _helpers.tpl file.
*/}}

{{/*
The full name for this chart.  We need to truncate the length of the name due
to restrictions in the DNS.
*/}}

{{- define "openldap.name" -}}
{{- printf "%s-iviaopenldap" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Our openldap database details
*/}}

{{- define "openldap.domain" -}}
{{- printf "ibm.com" -}}
{{- end -}}

{{/*
The name of our persistent volume claim.
*/}}
{{- define "openldap.pvc.name" -}}
{{- if .Values.dataVolume.existingClaimName -}}
{{- printf "%s" .Values.dataVolume.existingClaimName -}}
{{- else }}
{{- printf "%s-pvc-ldp" .Release.Name -}}
{{- end }}
{{- end -}}
