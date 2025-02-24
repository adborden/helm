{{/*
Expand the name of the chart.
*/}}
{{- define "wallabag.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wallabag.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "wallabag.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wallabag.labels" -}}
helm.sh/chart: {{ include "wallabag.chart" . }}
{{- range $key, $val := .Values.wallabag.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{ include "wallabag.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wallabag.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wallabag.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wallabag.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wallabag.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}



{{/*
Create the name of the service account to use
*/}}
{{- define "wallabag.configChecksum" -}}
{{- printf "%s-%s" (include (print $.Template.BasePath "/configmap.yaml") .) (include (print $.Template.BasePath "/secret.yaml") .) | sha256sum }}
{{- end }}

{{/*
Name of the wallabag secret
*/}}
{{- define "wallabag.secretName" -}}
{{- .Values.wallabag.secret.name | default (include "wallabag.fullname" .) }}
{{- end }}

{{/*
Container environment variables
*/}}
{{- define "wallabag.containerEnv" -}}
{{- if eq .Values.wallabag.database.driver "postgresql" }}
- name: SYMFONY__ENV__DATABASE_HOST
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: database-host
- name: SYMFONY__ENV__DATABASE_NAME
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: database-name
- name: SYMFONY__ENV__DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: database-password
- name: SYMFONY__ENV__DATABASE_PORT
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: database-port
- name: SYMFONY__ENV__DATABASE_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: database-username
{{- end }}
{{- if .Values.wallabag.email.enabled }}
- name: SYMFONY__ENV__FROM_EMAIL
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: email-from-email
- name: SYMFONY__ENV__MAILER_HOST
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: email-mailer-host
- name: SYMFONY__ENV__MAILER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: email-mailer-password
- name: SYMFONY__ENV__MAILER_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: email-mailer-username
{{- end }}
{{- if .Values.redis.enabled }}
- name: SYMFONY__ENV__REDIS_HOST
  value{{ printf "%s-redis-master" (include "wallabag.fullname" .)  | quote }}
- name: SYMFONY__ENV__REDIS_PASSWORD
  value: {{ .Values.redis.auth.password | quote }}
{{- end }}
- name: SYMFONY__ENV__SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "wallabag.secretName" . }}
      key: wallabag-secret
{{- end }}

