# Money guide eval

The harness behind [`docs/money-guide.md`](../../../docs/money-guide.md), section 8. It drives the real `AgentService` (the Money guide prompt, the tools and the citation resolver) and grades each reply deterministically. There is no LLM judge.

| Path                         | What it is                                                                                                       |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `golden/<cc>.yaml`           | Golden questions per country, and `universal.yaml` for the universal layer. G13 writes the real sets.            |
| `fixtures/entities.yaml`     | Seeded fixture entities that golden files name.                                                                  |
| `fixtures/recordings/*.yaml` | Recorded model turns for the offline test, each with the verdict the grader must reach, including failing turns. |
| `eval/`                      | The schema, the grader, the runner, the replay transport and the report writer.                                  |
| `golden_schema_test.dart`    | Validates every golden file: it parses, has no unknown keys, and names real cards, tools and fixtures.           |
| `eval_grader_test.dart`      | Every gate, passing and failing.                                                                                 |
| `eval_test.dart`             | The offline eval. Replays recordings through the real service over a mock transport. No network. Runs in CI.     |
| `eval_report_test.dart`      | The thresholds of section 8.3, and that the report holds no message text.                                        |
| `live_eval_test.dart`        | The live eval, tagged `live_eval` and skipped by default.                                                        |

## Gates

A run passes when none of these fail. Each is in `eval/eval_grader.dart`.

- `completed`: the turn ended with a reply.
- `tools`: every tool the question lists was called.
- `cites`: every listed key is in the reply and the server resolved it.
- `noStrippedCitations`: the server stripped no `[^key]` the model wrote.
- `mentions`: every listed fact is in the reply, after normalising case, spacing and thousands separators.
- `forbidden`: no listed phrase appears, and neither does the never-suggest wording (`you should`, `we recommend`, `best`, `guaranteed`, and the rest).
- `behaviour`: `refuse` quotes no currency amount and states its scope; `signpost` names a professional from the country's list; `qualify` says secondary, unverified or announced; `answer` has no extra check.

A question passes with two of three runs, and a `guardrail: true` question needs all three.

## Run the offline tests

```bash
cd openbudget_server
dart test test/money_guide/ --concurrency=1
```

`eval_test.dart` needs Postgres and Redis like the other server tests. The `live_eval` tag is skipped here.

## Run the live eval

It calls the real model and costs money (about $6 for 21 countries, far less for the sample set). Run it on purpose, as the author of a PR that changes cards, the prompt, tools or golden files. The key comes only from the `OPENCODE_ZEN_API_KEY` environment variable, which Monosecret fills:

```bash
cd openbudget_server
msr --reason "Money guide eval" dart test --run-skipped -t live_eval test/money_guide/live_eval_test.dart
```

`--run-skipped` is needed because `dart_test.yaml` skips the `live_eval` tag.

The run logs question ids, pass or fail, failed gate names, token counts and cost. It never logs the key or any message. It writes a Markdown report to `test/money_guide/eval_reports/` (gitignored) with the pass rate per country and the cost per question; paste it into the PR body.
