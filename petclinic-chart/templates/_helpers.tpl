{{/*
Generate app name from Chart.name or override
*/}}
{{- define "petclinic-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate fully qualified release name
*/}}
{{- define "petclinic-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Base selector labels
*/}}
{{- define "petclinic-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "petclinic-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common app labels
*/}}
{{- define "petclinic-chart.labels" -}}
{{ include "petclinic-chart.selectorLabels" . }}
app.kubernetes.io/part-of: spring-petclinic
app.kubernetes.io/component: application
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Database-specific selector labels
*/}}
{{- define "petclinic-chart.dbSelectorLabels" -}}
{{ include "petclinic-chart.selectorLabels" . }}
{{- end }}

{{/*
Database-specific labels
*/}}
{{- define "petclinic-chart.dbLabels" -}}
{{ include "petclinic-chart.dbSelectorLabels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Service account name helper
*/}}
{{- define "petclinic-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "petclinic-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
