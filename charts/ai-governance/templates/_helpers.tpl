{{- define "ai-governance.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "ai-governance.fullname" -}}
{{- printf "%s-%s" (include "ai-governance.name" .) .Release.Name -}}
{{- end -}}
