{{/*
Common labels
*/}}
{{- define "python-project.labels" -}}
helm.sh/chart: {{ include "python-project.chart" . | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/name: {{ include "python-project.name" . | quote }}
{{- end }}

{{- define "python-project.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "python-project.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "python-project.fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "python-project.selectorLabels" -}}
app.kubernetes.io/name: {{ include "python-project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
