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
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
helm.sh/chart: {{ include "chart" . | quote }}
{{- end -}}

{{- define "default.config.oidc.connectors" -}}
  connectors:
  {{- range $connector := .connectors }}
  - id: {{ $connector.id }}
    connectorName: {{ $connector.connectorName }}
    connectorType: {{ $connector.connectorType }}
    connectorConfig: |-
    {{- (merge (fromYaml $connector.connectorConfig) (dict "redirectURI" (printf "https://dex.%s/callback" $.baseDomain))) | toYaml | nindent 6 }}
  {{- end }}
{{- end -}}

{{- define "default.config" -}}
{{- if .Values.defaultConfig -}}
dex-app:
  userConfig:
    configMap:
      values: |
        isWorkloadCluster: {{ ne .Values.managementCluster .Values.clusterID }}
        deployDexK8SAuthenticator: {{ eq .Values.defaultConfig.deployDexK8SAuthenticator true }}
        {{ if .Values.defaultConfig.oidc.expiry -}}
        oidc:
          expiry:
            {{- .Values.defaultConfig.oidc.expiry | toYaml |  nindent 12 -}}
        {{- end }}
    secret:
      values: |
        oidc:
{{- if .Values.defaultConfig.oidc.customer }}
          customer:
            {{- (include "default.config.oidc.connectors" (dict "connectors" .Values.defaultConfig.oidc.customer.connectors "baseDomain" .Values.baseDomain)) | nindent 12 }}
{{ end -}}
{{- if .Values.defaultConfig.oidc.giantswarm }}
          giantswarm:
            {{- (include "default.config.oidc.connectors" (dict "connectors" .Values.defaultConfig.oidc.giantswarm.connectors "baseDomain" .Values.baseDomain)) | nindent 12 }}
{{ end -}}
athena:
  userConfig:
    configMap:
      values: |-
        managementCluster:
          name: {{ .Values.managementCluster }}
ingress-nginx:
  enabled: true
{{- if .Values.defaultConfig.rbac }}
rbac-bootstrap:
  userConfig:
    configMap:
      values: |
        bindings:
        {{- .Values.defaultConfig.rbac | toYaml | nindent 8 }}
{{ end -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}
