# Bucaneer

## Introduction

Brad is a plugable notification system composed of "sources" and "sinks". A source is simply a source of information, for example an RSS feed. A sink is an output of the information, for example a speech synthesizer.


## Ideas

* Thor bin file.
* Daemonizable.
* RSS source connected to Hudson.
* Reminder source (it's time for the foods, etc).
* Random source (nice work, Tom!)
* Vox sink.
* Sinatra/Rails web front-end.
* Rails front-end where sources and sink gems dynamically add their own configuration views (via Rails engines).
* SQLite storage (for sources, sinks, messages, configuration, etc).
