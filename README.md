# Representer

To understand the purpose of this project in the context of the exercism submission platform, there are a few documents to review:

- [Creating a Representer](https://github.com/exercism/automated-analysis/blob/master/docs/representers/getting-started.md)
- [Representer Interface](https://github.com/exercism/automated-analysis/blob/master/docs/representers/interface.md)
- [docker image build and deployment](https://github.com/exercism/automated-analysis/blob/master/docs/docker.md)

## Why

Code analysis is tough, and the programming required to create them is complex.  Initially the goal of the exercism platform was to provide automated analysis on a wide scale.  But while this proved to be successful at a small scale (for now), it also served to prove how complex they are.

So rather than attempting to provide automated analysis, we attempt to normalize submissions to distill the solutions to the general approaches taken, provide feedback on the normalized subset, then memoize the feedback so that when a recongnized solution pattern is submitted, feedback can be replayed from the previous submissions.

## Normalization

The role of this service is to take a code submission, and normalize it in the following ways:

- format using `mix format`, enforcing _do...end_ blocks
- removing comments
- normalizing `@doc` and `@moduledoc` documentation
- normalize module, variable, function names and maintain a mapping from the original to the placeholder names
  - this is done by analyzing the source using the ast representation to find the names to replace
  - then doing a textual find/replace on the source using the mapping

## Escript

> `lib/representer/cli.ex`

This is the entrypoint for an escript to process the relevant files from the command line.

## Docker

> Work to be done
