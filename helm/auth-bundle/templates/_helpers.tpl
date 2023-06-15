{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
When apps are created in the org namespace add a cluster prefix.
*/}}
{{- define "app.name" -}}
{{/*
for capi MCs and WCs this will be clusterId-appName
*/}}
{{- if hasPrefix "org-" .ns -}}
{{- printf "%s-%s" .cluster .app -}}
{{- else -}}
{{/*
for vintage MCs and WCs this will just be .app
*/}}
{{- .app -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels.common" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/part-of: {{ include "name" . | quote }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
giantswarm.io/cluster: {{ .Values.clusterID | quote }}
giantswarm.io/managed-by: {{ .Release.Name | quote }}
giantswarm.io/organization: {{ .Values.organization | quote }}
giantswarm.io/service-type: managed
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
helm.sh/chart: {{ include "chart" . | quote }}
{{- end -}}
