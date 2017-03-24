## Overview

[Fluentd](http://fluentd.org/) input plugin that acts as sFlow collector.
sFlow parser is based on [NETWAYS/sflow](https://github.com/NETWAYS/sflow/).


## Installation

Use RubyGems:

```
fluent-gem install fluent-plugin-sflow
```

## Configuration

```
<source>
  @type sflow
  bind 0.0.0.0
  tag example.sflow
</source>

<match example.sflow>
  @type stdout
</match>
```

**bind**

IP address on which this plugin will accept sFlow. Default is "0.0.0.0".

**port**

UDP port number on which this plugin will accept sFlow. Default is 6343.
