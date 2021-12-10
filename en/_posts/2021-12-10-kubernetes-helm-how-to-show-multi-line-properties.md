---
layout: flexstart-blog-single
title: "Kubernetes Helm : how to show Multi-line Properties"
author: full
lang: en
ref: KubernetesHelmhowtoshowMultilineProperties
categories:
  - kubernetes
date: 2021-12-10T13:28:16.611Z
image: https://sergio.afanou.com/assets/images/image-midres-25.jpg
---
Working with Kubernetes Helm, I went to the documentation. The link to the documentation is [here](https://helm.sh/docs/chart_template_guide/accessing_files/). 

In Helm's v3 documentation, in the section **Accessing Files Inside Templates**, you have an example of 3 properties (toml) files; where each file has only one key/value pair.



The configmap.yaml looks like this. It contains one config.toml for simplicity.


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-config
data:
  {{- $files := .Files }}
  {{- range tuple "config.toml" }}
  {{ . }}: |-
    {{ $files.Get . }}
  {{- end }}
```

I was happy with it. Then I add a second line to the config.toml file.



config.toml
```


replicaCount=1
foo=bar
```


Then boom, I get an Error: 

```
INSTALLATION FAILED: YAML parse error on deploy/templates/configmap.yaml: error converting YAML to JSON: yaml: line 9: could not find expected ':'
```

Digging in this error, I found a solution.

## The solution

Helm will read in that file, but as it is a text __templating engine__,  It does not understand that I was trying to compose a YAML file.

As a consquence, it was not helping me in the error. 

That's actually why you will see so many, many templates in the wild with 

```{{ .thing | indent 8 }}``` 

or 

```{{ .otherThing | toYaml }}``` 

-- because you need to help Helm know in what context it is emitting the text.



So, in my specific case, I needed to indent the filter with a value of 4 because mycurrent template has two spaces for the key indent level, and two more spaces for the value block scalar


```
data:

  {{- $files := .Files }}
  {{- range tuple "config.toml" }}
  {{ . }}: |-
{{ $files.Get . | indent 4 }}
{{/* notice this ^^^ template expression is flush left,
because the 'indent' is handling whitespace, not the golang template itself */}}
  {{- end }}
```


I hope this quick post will help someone in his research.

Inpiration from [this post](https://stackoverflow.com/questions/70297885/helms-v3-example-doesnt-show-multi-line-properties-get-yaml-to-json-parse-err).

#helm #automation #docker #container